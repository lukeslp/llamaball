#!/bin/bash
# RAG System Startup Script for Ollama
# File Purpose: Start embedding and chat services using Ollama
# Primary Functions: Service orchestration, health checking, process management
# Inputs: Tier selection (1-3), optional configuration overrides
# Outputs: Running RAG system with monitoring and logging

TIER=${1:-2}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Starting Ollama RAG System (Tier $TIER)"

# Check if Ollama is running
if ! pgrep -x "ollama" > /dev/null; then
    echo "🔧 Starting Ollama service..."
    ollama serve &
    OLLAMA_PID=$!
    echo "📝 Ollama service PID: $OLLAMA_PID"
    echo $OLLAMA_PID > "$ROOT_DIR/logs/ollama.pid"
    
    # Wait for Ollama to be ready
    echo "⏳ Waiting for Ollama to start..."
    for i in {1..30}; do
        if curl -sf http://localhost:11434/api/version >/dev/null 2>&1; then
            echo "✅ Ollama service is ready"
            break
        fi
        sleep 1
    done
    
    if [ $i -eq 30 ]; then
        echo "❌ Ollama failed to start within 30 seconds"
        exit 1
    fi
else
    echo "✅ Ollama service is already running"
fi

# Set model names based on tier
case $TIER in
    1)
        echo "🎯 Starting Tier 1: High-Performance Setup"
        EMBED_MODEL="nomic-embed-text"
        CHAT_MODEL="llama3"
        ;;
    2)
        echo "🎯 Starting Tier 2: Balanced Setup"
        EMBED_MODEL="mxbai-embed-large"
        CHAT_MODEL="mistral"
        ;;
    3)
        echo "🎯 Starting Tier 3: Lightweight Setup"
        EMBED_MODEL="all-minilm"
        CHAT_MODEL="tinyllama"
        ;;
    *)
        echo "❌ Invalid tier: $TIER"
        echo "Usage: $0 [1|2|3]"
        exit 1
        ;;
esac

echo "📊 Using embedding model: $EMBED_MODEL"
echo "💬 Using chat model: $CHAT_MODEL"

# Create logs directory if it doesn't exist
mkdir -p "$ROOT_DIR/logs"

# Create a simple proxy server for embedding endpoint (port 8081)
cat > "$ROOT_DIR/logs/embedding_proxy.py" << EOF
#!/usr/bin/env python3
"""
Embedding Proxy Server for Ollama
Provides llamafile-compatible embedding endpoint using Ollama backend
"""
import json
import requests
from http.server import HTTPServer, BaseHTTPRequestHandler
import urllib.parse

class EmbeddingHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/embedding':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                request_data = json.loads(post_data.decode('utf-8'))
                text = request_data.get('content', '')
                
                # Call Ollama embedding API
                ollama_response = requests.post(
                    'http://localhost:11434/api/embeddings',
                    json={
                        'model': '${EMBED_MODEL}',
                        'prompt': text
                    }
                )
                
                if ollama_response.status_code == 200:
                    ollama_data = ollama_response.json()
                    embedding = ollama_data.get('embedding', [])
                    
                    # Return in llamafile-compatible format
                    response_data = {'embedding': embedding}
                    
                    self.send_response(200)
                    self.send_header('Content-type', 'application/json')
                    self.send_header('Access-Control-Allow-Origin', '*')
                    self.end_headers()
                    self.wfile.write(json.dumps(response_data).encode())
                else:
                    self.send_error(500, f"Ollama error: {ollama_response.status_code}")
                    
            except Exception as e:
                self.send_error(500, f"Error: {str(e)}")
        else:
            self.send_error(404, "Not found")
    
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(b'{"status": "ok"}')
        else:
            self.send_error(404, "Not found")
    
    def log_message(self, format, *args):
        pass  # Suppress default logging

if __name__ == '__main__':
    server = HTTPServer(('localhost', 8081), EmbeddingHandler)
    print("Embedding proxy server started on port 8081")
    server.serve_forever()
EOF

# Create a simple proxy server for chat endpoint (port 8080)
cat > "$ROOT_DIR/logs/chat_proxy.py" << EOF
#!/usr/bin/env python3
"""
Chat Proxy Server for Ollama
Provides llamafile-compatible chat endpoint using Ollama backend
"""
import json
import requests
from http.server import HTTPServer, BaseHTTPRequestHandler

class ChatHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/completion':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                request_data = json.loads(post_data.decode('utf-8'))
                prompt = request_data.get('prompt', '')
                max_tokens = request_data.get('n_predict', 512)
                temperature = request_data.get('temperature', 0.2)
                stop = request_data.get('stop', [])
                
                # Call Ollama generate API
                ollama_response = requests.post(
                    'http://localhost:11434/api/generate',
                    json={
                        'model': '${CHAT_MODEL}',
                        'prompt': prompt,
                        'stream': False,
                        'options': {
                            'num_predict': max_tokens,
                            'temperature': temperature,
                            'stop': stop
                        }
                    }
                )
                
                if ollama_response.status_code == 200:
                    ollama_data = ollama_response.json()
                    content = ollama_data.get('response', '')
                    
                    # Return in llamafile-compatible format
                    response_data = {'content': content}
                    
                    self.send_response(200)
                    self.send_header('Content-type', 'application/json')
                    self.send_header('Access-Control-Allow-Origin', '*')
                    self.end_headers()
                    self.wfile.write(json.dumps(response_data).encode())
                else:
                    self.send_error(500, f"Ollama error: {ollama_response.status_code}")
                    
            except Exception as e:
                self.send_error(500, f"Error: {str(e)}")
        else:
            self.send_error(404, "Not found")
    
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(b'{"status": "ok"}')
        else:
            self.send_error(404, "Not found")
    
    def log_message(self, format, *args):
        pass  # Suppress default logging

if __name__ == '__main__':
    server = HTTPServer(('localhost', 8080), ChatHandler)
    print("Chat proxy server started on port 8080")
    server.serve_forever()
EOF

# Start the proxy servers
echo "🌐 Starting embedding proxy server (port 8081)..."
python3 "$ROOT_DIR/logs/embedding_proxy.py" > "$ROOT_DIR/logs/embedding.log" 2>&1 &
EMBED_PID=$!
echo $EMBED_PID > "$ROOT_DIR/logs/embedding.pid"

echo "💬 Starting chat proxy server (port 8080)..."
python3 "$ROOT_DIR/logs/chat_proxy.py" > "$ROOT_DIR/logs/chat.log" 2>&1 &
CHAT_PID=$!
echo $CHAT_PID > "$ROOT_DIR/logs/chat.pid"

echo "📝 Embedding proxy PID: $EMBED_PID"
echo "📝 Chat proxy PID: $CHAT_PID"
echo "🌐 Embedding endpoint: http://localhost:8081"
echo "💬 Chat endpoint: http://localhost:8080"

# Wait for services to start
echo "🔍 Waiting for services to start..."
sleep 5

# Health check
EMBED_HEALTH=false
CHAT_HEALTH=false

for i in {1..10}; do
    if curl -sf http://localhost:8081/health >/dev/null 2>&1; then
        echo "✅ Embedding server: Online"
        EMBED_HEALTH=true
        break
    fi
    sleep 1
done

for i in {1..10}; do
    if curl -sf http://localhost:8080/health >/dev/null 2>&1; then
        echo "✅ Chat server: Online"
        CHAT_HEALTH=true
        break
    fi
    sleep 1
done

if [ "$EMBED_HEALTH" = true ] && [ "$CHAT_HEALTH" = true ]; then
    echo "🎉 RAG system started successfully!"
    echo "💡 Models in use:"
    echo "  📊 Embedding: $EMBED_MODEL (via Ollama)"
    echo "  💬 Chat: $CHAT_MODEL (via Ollama)"
    echo ""
    echo "🛑 Use 'scripts/stop-rag-system.sh' to stop"
    echo "🧪 Use 'scripts/test-rag-system.sh' to test"
else
    echo "❌ Some services failed to start. Check logs in $ROOT_DIR/logs/"
    exit 1
fi

# Function to cleanup on exit
cleanup() {
    echo "🛑 Shutting down RAG system..."
    kill $EMBED_PID $CHAT_PID 2>/dev/null || true
    if [ -f "$ROOT_DIR/logs/ollama.pid" ]; then
        OLLAMA_PID=$(cat "$ROOT_DIR/logs/ollama.pid")
        kill $OLLAMA_PID 2>/dev/null || true
        rm -f "$ROOT_DIR/logs/ollama.pid"
    fi
}

# Set up signal handlers
trap cleanup INT TERM

# Keep script running to maintain services
echo "🔄 RAG system is running. Press Ctrl+C to stop."
wait 