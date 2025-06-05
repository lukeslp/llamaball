#!/bin/bash
# Stop RAG System Script for Ollama
# File Purpose: Gracefully shutdown all RAG system components
# Primary Functions: Process termination, cleanup, service verification
# Inputs: Optional force flag for hard shutdown
# Outputs: Clean system state with all services stopped

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
FORCE=${1:-false}

echo "🛑 Stopping Ollama RAG System..."

# Function to safely kill a process by PID
safe_kill() {
    local pid=$1
    local name=$2
    local timeout=${3:-10}
    
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        echo "🔄 Stopping $name (PID: $pid)..."
        kill "$pid" 2>/dev/null
        
        # Wait for graceful shutdown
        local count=0
        while kill -0 "$pid" 2>/dev/null && [ $count -lt $timeout ]; do
            sleep 1
            count=$((count + 1))
        done
        
        # Force kill if still running
        if kill -0 "$pid" 2>/dev/null; then
            echo "⚠️  Force killing $name (PID: $pid)..."
            kill -9 "$pid" 2>/dev/null
        fi
        
        echo "✅ $name stopped"
    else
        echo "ℹ️  $name was not running"
    fi
}

# Stop embedding proxy server
if [ -f "$ROOT_DIR/logs/embedding.pid" ]; then
    EMBED_PID=$(cat "$ROOT_DIR/logs/embedding.pid" 2>/dev/null)
    safe_kill "$EMBED_PID" "Embedding proxy server"
    rm -f "$ROOT_DIR/logs/embedding.pid"
else
    echo "ℹ️  No embedding server PID file found"
fi

# Stop chat proxy server
if [ -f "$ROOT_DIR/logs/chat.pid" ]; then
    CHAT_PID=$(cat "$ROOT_DIR/logs/chat.pid" 2>/dev/null)
    safe_kill "$CHAT_PID" "Chat proxy server"
    rm -f "$ROOT_DIR/logs/chat.pid"
else
    echo "ℹ️  No chat server PID file found"
fi

# Stop Ollama service if we started it
if [ -f "$ROOT_DIR/logs/ollama.pid" ]; then
    OLLAMA_PID=$(cat "$ROOT_DIR/logs/ollama.pid" 2>/dev/null)
    safe_kill "$OLLAMA_PID" "Ollama service" 15
    rm -f "$ROOT_DIR/logs/ollama.pid"
else
    echo "ℹ️  Ollama service was not started by this system (external service)"
fi

# Fallback: kill by process name and pattern
echo "🔍 Cleaning up any remaining processes..."

# Kill any remaining Python proxy servers
pkill -f "embedding_proxy.py" 2>/dev/null && echo "✅ Killed remaining embedding proxy processes"
pkill -f "chat_proxy.py" 2>/dev/null && echo "✅ Killed remaining chat proxy processes"

# Force kill option
if [ "$FORCE" = "true" ] || [ "$FORCE" = "--force" ] || [ "$FORCE" = "-f" ]; then
    echo "🔨 Force mode: Killing all Ollama-related processes..."
    pkill -f "ollama" 2>/dev/null && echo "✅ Force killed Ollama processes"
fi

# Clean up temporary files
echo "🧹 Cleaning up temporary files..."
rm -f "$ROOT_DIR/logs/embedding_proxy.py" 2>/dev/null
rm -f "$ROOT_DIR/logs/chat_proxy.py" 2>/dev/null

# Verify services are stopped
echo "🔍 Verifying services are stopped..."

EMBED_STOPPED=true
CHAT_STOPPED=true
OLLAMA_RUNNING=false

# Check embedding endpoint
if curl -sf http://localhost:8081/health >/dev/null 2>&1; then
    echo "⚠️  Embedding server still responding on port 8081"
    EMBED_STOPPED=false
fi

# Check chat endpoint
if curl -sf http://localhost:8080/health >/dev/null 2>&1; then
    echo "⚠️  Chat server still responding on port 8080"
    CHAT_STOPPED=false
fi

# Check if Ollama is still running
if curl -sf http://localhost:11434/api/version >/dev/null 2>&1; then
    echo "ℹ️  Ollama service is still running (external service)"
    OLLAMA_RUNNING=true
fi

# Final status report
echo ""
echo "📊 Shutdown Status Report:"
echo "=========================="

if [ "$EMBED_STOPPED" = true ]; then
    echo "✅ Embedding proxy server: Stopped"
else
    echo "❌ Embedding proxy server: Still running"
fi

if [ "$CHAT_STOPPED" = true ]; then
    echo "✅ Chat proxy server: Stopped"
else
    echo "❌ Chat proxy server: Still running"
fi

if [ "$OLLAMA_RUNNING" = true ]; then
    echo "ℹ️  Ollama service: Running (external)"
else
    echo "✅ Ollama service: Stopped"
fi

# Check for any remaining processes
REMAINING_PROCS=$(pgrep -f "(embedding_proxy|chat_proxy)" 2>/dev/null | wc -l)
if [ "$REMAINING_PROCS" -gt 0 ]; then
    echo "⚠️  $REMAINING_PROCS remaining proxy processes found"
    echo "💡 Use '$0 --force' for hard shutdown"
else
    echo "✅ No remaining proxy processes"
fi

# Final cleanup check
if [ "$EMBED_STOPPED" = true ] && [ "$CHAT_STOPPED" = true ]; then
    echo ""
    echo "🎉 RAG system successfully stopped!"
    
    # Show log files location
    if [ -d "$ROOT_DIR/logs" ] && [ "$(ls -A "$ROOT_DIR/logs" 2>/dev/null)" ]; then
        echo "📁 Log files preserved in: $ROOT_DIR/logs/"
        echo "💡 Tip: View logs with 'tail -f logs/*.log'"
    fi
    
    exit 0
else
    echo ""
    echo "⚠️  Some services may still be running"
    echo "💡 Try: '$0 --force' for forceful shutdown"
    echo "🔍 Or check manually with: 'ps aux | grep -E \"(embedding|chat)_proxy\"'"
    exit 1
fi 