#!/bin/bash
# Quick Setup Script for Llamafile RAG System
# File Purpose: Automated setup for RAG-optimized llamafiles
# Primary Functions: Model download, configuration creation, system validation
# Inputs: Hardware tier selection (1-3), optional model preferences
# Outputs: Ready-to-run llamafile configuration for RAG applications

set -e

echo "🦙 Llamafile RAG System Quick Setup"
echo "==================================="

# Function to check available RAM
check_ram() {
    if command -v free >/dev/null 2>&1; then
        # Linux
        RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
    elif command -v vm_stat >/dev/null 2>&1; then
        # macOS
        RAM_BYTES=$(sysctl -n hw.memsize)
        RAM_GB=$((RAM_BYTES / 1024 / 1024 / 1024))
    else
        echo "⚠️  Cannot detect RAM. Please specify tier manually."
        RAM_GB=8
    fi
    echo "💾 Detected RAM: ${RAM_GB}GB"
}

# Function to recommend tier based on RAM
recommend_tier() {
    if [ "$RAM_GB" -ge 16 ]; then
        echo "🎯 Recommended: Tier 1 (High-Performance)"
        RECOMMENDED_TIER=1
    elif [ "$RAM_GB" -ge 8 ]; then
        echo "🎯 Recommended: Tier 2 (Balanced)"
        RECOMMENDED_TIER=2
    else
        echo "🎯 Recommended: Tier 3 (Lightweight)"
        RECOMMENDED_TIER=3
    fi
}

# Function to create directory structure
setup_directories() {
    echo "📁 Setting up directory structure..."
    mkdir -p models configs scripts logs
    cd models || exit 1
}

# Functions to pull models directly from Ollama for each tier
download_tier1_models() {
    echo "📦 Pulling Tier 1 models (High-Performance) from Ollama..."

    # Nomic Embed v1.5 for embeddings
    if ! ollama list | grep -q "nomic-embed-text"; then
        echo "⬇️  Pulling Nomic Embed v1.5 from Ollama..."
        ollama pull nomic-embed-text
    else
        echo "✅ Nomic Embed v1.5 already present in Ollama."
    fi

    # Llama 3 8B for chat
    if ! ollama list | grep -q "llama3"; then
        echo "⬇️  Pulling Llama 3 8B from Ollama..."
        ollama pull llama3
    else
        echo "✅ Llama 3 8B already present in Ollama."
    fi
}

download_tier2_models() {
    echo "📦 Pulling Tier 2 models (Balanced) from Ollama..."

    # mxbai-embed-large for embeddings
    if ! ollama list | grep -q "mxbai-embed-large"; then
        echo "⬇️  Pulling MXBai Embed Large from Ollama..."
        ollama pull mxbai-embed-large
    else
        echo "✅ MXBai Embed Large already present in Ollama."
    fi

    # Mistral for chat
    if ! ollama list | grep -q "mistral"; then
        echo "⬇️  Pulling Mistral from Ollama..."
        ollama pull mistral
    else
        echo "✅ Mistral already present in Ollama."
    fi
}

download_tier3_models() {
    echo "📦 Pulling Tier 3 models (Lightweight) from Ollama..."

    # all-minilm for embeddings
    if ! ollama list | grep -q "all-minilm"; then
        echo "⬇️  Pulling all-minilm from Ollama..."
        ollama pull all-minilm
    else
        echo "✅ all-minilm already present in Ollama."
    fi

    # tinyllama for chat
    if ! ollama list | grep -q "tinyllama"; then
        echo "⬇️  Pulling TinyLlama from Ollama..."
        ollama pull tinyllama
    else
        echo "✅ TinyLlama already present in Ollama."
    fi
}

# Function to check for Ollama binary and install if missing
setup_ollama_binary() {
    echo "🔧 Checking for Ollama binary..."
    if ! command -v ollama >/dev/null 2>&1; then
        echo "⬇️  Ollama not found. Installing Ollama..."
        # Install Ollama using official script (https://ollama.com/download)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install ollama
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            curl -fsSL https://ollama.com/install.sh | sh
        else
            echo "❌ Unsupported OS for automatic Ollama installation. Please install manually: https://ollama.com/download"
            exit 1
        fi
    else
        echo "✅ Ollama is already installed."
    fi
}

# Function to setup llamafile binary
setup_llamafile_binary() {
    echo "🔧 Checking for llamafile binary..."
    if ! command -v llamafile >/dev/null 2>&1; then
        echo "⬇️  llamafile not found. Downloading..."
        
        # Detect platform and architecture
        case "$(uname -s)" in
            Darwin)
                PLATFORM="macos"
                if [ "$(uname -m)" = "arm64" ]; then
                    ARCH="arm64"
                else
                    ARCH="amd64"
                fi
                ;;
            Linux)
                PLATFORM="linux"
                if [ "$(uname -m)" = "aarch64" ]; then
                    ARCH="arm64"
                else
                    ARCH="amd64"
                fi
                ;;
            *)
                echo "❌ Unsupported platform: $(uname -s)"
                echo "Debug Info:"
                echo "  PLATFORM: ${PLATFORM:-unset}"
                echo "  ARCH: ${ARCH:-unset}"
                uname -a
                exit 1
                ;;
        esac

        echo "Debug: Downloading llamafile for PLATFORM=${PLATFORM}, ARCH=${ARCH}"
        curl -L -o llamafile "https://github.com/Mozilla-Ocho/llamafile/releases/latest/download/llamafile-${PLATFORM}-${ARCH}"
        if [ $? -ne 0 ]; then
            echo "❌ Failed to download llamafile binary. Please check your network connection and the URL."
            exit 1
        fi
        chmod +x llamafile
        LLAMAFILE_PATH="./llamafile"
        echo "Debug: llamafile downloaded and made executable at $LLAMAFILE_PATH"
    else
        LLAMAFILE_PATH="/usr/local/bin/llamafile"
        echo "Debug: Using system llamafile at $LLAMAFILE_PATH"
    fi
}

# Function to create configuration files
create_tier1_configs() {
    echo "Debug: Entering create_tier1_configs"
    cd ../configs || { echo "❌ Failed to cd to ../configs"; exit 1; }
    
    # Embedding server config
    echo "Debug: Creating embedding-tier1.args"
    cat > embedding-tier1.args << 'EOF'
-m
../models/nomic-embed-text-v1.5.Q4_K_M.gguf
--port
8081
--host
0.0.0.0
--embedding
--nobrowser
-c
8192
-b
8192
--rope-scaling
yarn
--rope-freq-scale
0.75
-ngl
99
...
EOF

    # Chat server config
    echo "Debug: Creating chat-tier1.args"
    cat > chat-tier1.args << 'EOF'
-m
../models/Meta-Llama-3-8B-Instruct.Q4_K_M.llamafile
--port
8080
--host
0.0.0.0
--chat-template
llama3
-c
8192
-ngl
35
-n
-1
--temp
0.2
--repeat-penalty
1.1
...
EOF
    echo "Debug: Tier 1 config files created"
}

create_tier2_configs() {
    echo "Debug: Entering create_tier2_configs"
    cd ../configs || { echo "❌ Failed to cd to ../configs"; exit 1; }
    
    # Embedding server config
    echo "Debug: Creating embedding-tier2.args"
    cat > embedding-tier2.args << 'EOF'
-m
../models/mxbai-embed-large-v1.Q4_K_M.gguf
--port
8081
--host
0.0.0.0
--embedding
--nobrowser
-c
1024
-b
1024
-ngl
20
...
EOF

    # Chat server config
    cat > chat-tier2.args << 'EOF'
-m
../models/mistral-7b-instruct-v0.2.Q4_K_M.llamafile
--port
8080
--host
0.0.0.0
-c
4096
-ngl
25
--temp
0.2
--repeat-penalty
1.1
-n
-1
...
EOF
}

create_tier3_configs() {
    cd ../configs || exit 1
    
    # Embedding server config
    cat > embedding-tier3.args << 'EOF'
-m
../models/all-MiniLM-L6-v2.Q4_K_M.gguf
--port
8081
--host
0.0.0.0
--embedding
--nobrowser
-c
512
-b
512
-ngl
10
...
EOF

    # Chat server config
    cat > chat-tier3.args << 'EOF'
-m
../models/TinyLlama-1.1B-Chat-v1.0.Q5_K_M.llamafile
--port
8080
--host
0.0.0.0
-c
2048
-ngl
15
--temp
0.7
--repeat-penalty
1.1
-n
-1
...
EOF
}

# Function to create startup scripts
create_startup_scripts() {
    cd ../scripts || exit 1
    
    # Main startup script
    cat > start-rag-system.sh << 'EOF'
#!/bin/bash
# RAG System Startup Script

TIER=${1:-2}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Starting RAG System (Tier $TIER)"

# Kill any existing processes
pkill -f "llamafile.*embedding" || true
pkill -f "llamafile.*chat" || true
sleep 2

cd "$ROOT_DIR" || exit 1

case $TIER in
    1)
        echo "🎯 Starting Tier 1: High-Performance Setup"
        ../models/llamafile --config configs/embedding-tier1.args > logs/embedding.log 2>&1 &
        EMBED_PID=$!
        sleep 5
        ../models/Meta-Llama-3-8B-Instruct.Q4_K_M.llamafile --config configs/chat-tier1.args > logs/chat.log 2>&1 &
        CHAT_PID=$!
        ;;
    2)
        echo "🎯 Starting Tier 2: Balanced Setup"
        ../models/llamafile --config configs/embedding-tier2.args > logs/embedding.log 2>&1 &
        EMBED_PID=$!
        sleep 5
        ../models/mistral-7b-instruct-v0.2.Q4_K_M.llamafile --config configs/chat-tier2.args > logs/chat.log 2>&1 &
        CHAT_PID=$!
        ;;
    3)
        echo "🎯 Starting Tier 3: Lightweight Setup"
        ../models/llamafile --config configs/embedding-tier3.args > logs/embedding.log 2>&1 &
        EMBED_PID=$!
        sleep 5
        ../models/TinyLlama-1.1B-Chat-v1.0.Q5_K_M.llamafile --config configs/chat-tier3.args > logs/chat.log 2>&1 &
        CHAT_PID=$!
        ;;
    *)
        echo "❌ Invalid tier: $TIER"
        echo "Usage: $0 [1|2|3]"
        exit 1
        ;;
esac

echo "📝 Embedding server PID: $EMBED_PID"
echo "📝 Chat server PID: $CHAT_PID"
echo "🌐 Embedding endpoint: http://localhost:8081"
echo "💬 Chat endpoint: http://localhost:8080"

# Save PIDs
echo $EMBED_PID > "$ROOT_DIR/logs/embedding.pid"
echo $CHAT_PID > "$ROOT_DIR/logs/chat.pid"

# Health check
echo "🔍 Waiting for services to start..."
sleep 10

if curl -sf http://localhost:8081/health >/dev/null 2>&1; then
    echo "✅ Embedding server: Online"
else
    echo "❌ Embedding server: Failed to start"
fi

if curl -sf http://localhost:8080/health >/dev/null 2>&1; then
    echo "✅ Chat server: Online"
else
    echo "❌ Chat server: Failed to start"
fi

echo "🎉 RAG system started successfully!"
echo "💡 Use 'scripts/stop-rag-system.sh' to stop"

# Keep script running
trap 'kill $EMBED_PID $CHAT_PID' INT TERM
wait
EOF

    # Stop script
    cat > stop-rag-system.sh << 'EOF'
#!/bin/bash
# Stop RAG System

echo "🛑 Stopping RAG System..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Kill processes by PID if available
if [ -f "$ROOT_DIR/logs/embedding.pid" ]; then
    EMBED_PID=$(cat "$ROOT_DIR/logs/embedding.pid")
    kill "$EMBED_PID" 2>/dev/null || true
    rm -f "$ROOT_DIR/logs/embedding.pid"
fi

if [ -f "$ROOT_DIR/logs/chat.pid" ]; then
    CHAT_PID=$(cat "$ROOT_DIR/logs/chat.pid")
    kill "$CHAT_PID" 2>/dev/null || true
    rm -f "$ROOT_DIR/logs/chat.pid"
fi

# Fallback: kill by process name
pkill -f "llamafile.*embedding" || true
pkill -f "llamafile.*chat" || true

echo "✅ RAG system stopped"
EOF

    # Test script
    cat > test-rag-system.sh << 'EOF'
#!/bin/bash
# Test RAG System

echo "🧪 Testing RAG System..."

# Test embedding endpoint
echo "📊 Testing embedding endpoint..."
EMBED_RESPONSE=$(curl -s -X POST http://localhost:8081/embedding \
  -H "Content-Type: application/json" \
  -d '{"content": "search_document: What is artificial intelligence?"}' || echo "FAIL")

if [[ "$EMBED_RESPONSE" == *"embedding"* ]]; then
    echo "✅ Embedding server: Working"
else
    echo "❌ Embedding server: Failed"
fi

# Test chat endpoint
echo "💬 Testing chat endpoint..."
CHAT_RESPONSE=$(curl -s -X POST http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d '{"prompt": "What is the capital of France?", "n_predict": 50}' || echo "FAIL")

if [[ "$CHAT_RESPONSE" == *"content"* ]]; then
    echo "✅ Chat server: Working"
else
    echo "❌ Chat server: Failed"
fi

echo "🎯 Test complete!"
EOF

    chmod +x *.sh
}

# Function to create example integration
create_example_integration() {
    cd "$ROOT_DIR" || exit 1
    
    cat > example-rag-client.py << 'EOF'
#!/usr/bin/env python3
"""
Example RAG Client for Llamafile Setup
File Purpose: Demonstrates integration with llamafile RAG system
Primary Functions: Document embedding, similarity search, chat completion
Inputs: User queries and documents
Outputs: RAG-enhanced responses with source attribution
"""

import requests
import json
import numpy as np
from typing import List, Tuple
import time

class LlamafileRAGClient:
    def __init__(self, embedding_url="http://localhost:8081", chat_url="http://localhost:8080"):
        self.embedding_url = embedding_url
        self.chat_url = chat_url
        
    def embed_text(self, text: str, prefix: str = "search_document") -> np.ndarray:
        """Generate embedding for text using llamafile embedding server"""
        payload = {
            "content": f"{prefix}: {text}",
            "n_predict": 0
        }
        
        response = requests.post(f"{self.embedding_url}/embedding", json=payload)
        response.raise_for_status()
        
        embedding = response.json()["embedding"]
        return np.array(embedding, dtype=np.float32)
    
    def chat_complete(self, messages: List[dict]) -> str:
        """Generate chat completion using llamafile chat server"""
        # Simple prompt formatting (adjust based on your model)
        prompt = ""
        for msg in messages:
            if msg["role"] == "system":
                prompt += f"System: {msg['content']}\n"
            elif msg["role"] == "user":
                prompt += f"User: {msg['content']}\n"
            elif msg["role"] == "assistant":
                prompt += f"Assistant: {msg['content']}\n"
        
        prompt += "Assistant: "
        
        payload = {
            "prompt": prompt,
            "n_predict": 512,
            "temperature": 0.2,
            "stop": ["\n\nUser:", "\n\nSystem:"]
        }
        
        response = requests.post(f"{self.chat_url}/completion", json=payload)
        response.raise_for_status()
        
        return response.json()["content"].strip()
    
    def semantic_search(self, query: str, documents: List[str], top_k: int = 3) -> List[Tuple[str, float]]:
        """Perform semantic search using embeddings"""
        query_embedding = self.embed_text(query, "search_query")
        
        # Embed all documents
        doc_embeddings = []
        for doc in documents:
            doc_emb = self.embed_text(doc, "search_document")
            doc_embeddings.append(doc_emb)
        
        # Calculate similarities
        similarities = []
        for i, doc_emb in enumerate(doc_embeddings):
            similarity = np.dot(query_embedding, doc_emb) / (
                np.linalg.norm(query_embedding) * np.linalg.norm(doc_emb)
            )
            similarities.append((documents[i], float(similarity)))
        
        # Sort by similarity and return top_k
        similarities.sort(key=lambda x: x[1], reverse=True)
        return similarities[:top_k]
    
    def rag_query(self, query: str, documents: List[str], top_k: int = 3) -> str:
        """Perform RAG query: retrieve relevant docs and generate response"""
        # Retrieve relevant documents
        relevant_docs = self.semantic_search(query, documents, top_k)
        
        # Build context from relevant documents
        context = "Relevant information:\n"
        for doc, score in relevant_docs:
            context += f"- {doc} (relevance: {score:.3f})\n"
        
        # Generate response with context
        messages = [
            {
                "role": "system", 
                "content": "You are a helpful assistant. Use the provided context to answer questions accurately."
            },
            {
                "role": "user",
                "content": f"{context}\n\nQuestion: {query}"
            }
        ]
        
        response = self.chat_complete(messages)
        return response

def main():
    """Example usage of the RAG client"""
    print("🦙 Llamafile RAG Client Example")
    print("================================")
    
    # Initialize client
    client = LlamafileRAGClient()
    
    # Example documents
    documents = [
        "Artificial intelligence is the simulation of human intelligence in machines.",
        "Machine learning is a subset of AI that enables computers to learn from data.",
        "Neural networks are computing systems inspired by biological neural networks.",
        "Deep learning uses neural networks with multiple layers to model complex patterns.",
        "Natural language processing enables computers to understand human language."
    ]
    
    # Example query
    query = "What is machine learning?"
    
    print(f"🔍 Query: {query}")
    print(f"📚 Searching through {len(documents)} documents...")
    
    try:
        # Perform RAG query
        response = client.rag_query(query, documents, top_k=2)
        print(f"\n🤖 Response:\n{response}")
        
    except requests.exceptions.ConnectionError:
        print("❌ Error: Cannot connect to llamafile servers.")
        print("💡 Make sure to start the RAG system first with: scripts/start-rag-system.sh")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()
EOF

    chmod +x example-rag-client.py
}

# Main execution
main() {
    echo "🔍 Checking system requirements..."
    check_ram
    recommend_tier
    
    # Get user preference for tier
    echo ""
    read -p "🎯 Select tier (1/2/3) [default: $RECOMMENDED_TIER]: " SELECTED_TIER
    SELECTED_TIER=${SELECTED_TIER:-$RECOMMENDED_TIER}
    
    if [[ ! "$SELECTED_TIER" =~ ^[123]$ ]]; then
        echo "❌ Invalid tier selection. Using recommended tier: $RECOMMENDED_TIER"
        SELECTED_TIER=$RECOMMENDED_TIER
    fi
    
    echo "📋 Setting up Tier $SELECTED_TIER configuration..."
    
    # Setup
    setup_directories
    setup_llamafile_binary
    
    # Download models based on tier
    case $SELECTED_TIER in
        1) download_tier1_models; create_tier1_configs ;;
        2) download_tier2_models; create_tier2_configs ;;
        3) download_tier3_models; create_tier3_configs ;;
    esac
    
    # Create scripts and examples
    create_startup_scripts
    create_example_integration
    
    # Final setup
    ROOT_DIR="$(pwd)"
    cd "$ROOT_DIR" || exit 1
    
    echo ""
    echo "🎉 Setup complete!"
    echo "==================="
    echo "📁 Project structure:"
    echo "  models/     - Downloaded model files"
    echo "  configs/    - Configuration files"
    echo "  scripts/    - Startup and management scripts"
    echo "  logs/       - Runtime logs"
    echo ""
    echo "🚀 To start your RAG system:"
    echo "  ./scripts/start-rag-system.sh $SELECTED_TIER"
    echo ""
    echo "🧪 To test your system:"
    echo "  ./scripts/test-rag-system.sh"
    echo ""
    echo "🐍 To try the Python example:"
    echo "  python3 example-rag-client.py"
    echo ""
    echo "📖 For more information, see: llamafile-rag-setup.md"
}

# Run main function
main "$@" 