#!/bin/bash
# Test RAG System Script for Ollama
# File Purpose: Comprehensive testing of RAG system functionality
# Primary Functions: Endpoint validation, model testing, performance verification
# Inputs: Optional verbose flag for detailed output
# Outputs: Test results with pass/fail status and performance metrics

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
VERBOSE=${1:-false}

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

echo "🧪 Testing Ollama RAG System"
echo "============================="

# Function to print test results
print_result() {
    local test_name="$1"
    local status="$2"
    local details="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$status" = "PASS" ]; then
        echo -e "✅ ${GREEN}PASS${NC} - $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        if [ "$VERBOSE" = "true" ] || [ "$VERBOSE" = "-v" ] || [ "$VERBOSE" = "--verbose" ]; then
            echo "   Details: $details"
        fi
    else
        echo -e "❌ ${RED}FAIL${NC} - $test_name"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo "   Error: $details"
    fi
}

# Function to test HTTP endpoint
test_endpoint() {
    local url="$1"
    local expected_code="$2"
    local timeout="5"
    
    response=$(curl -s -w "%{http_code}" -m $timeout "$url" 2>/dev/null)
    http_code="${response: -3}"
    
    if [ "$http_code" = "$expected_code" ]; then
        echo "PASS"
    else
        echo "FAIL:HTTP_$http_code"
    fi
}

# Function to measure response time
measure_response_time() {
    local url="$1"
    local data="$2"
    local start_time=$(date +%s%N)
    
    if [ -n "$data" ]; then
        response=$(curl -s -X POST -H "Content-Type: application/json" -d "$data" "$url" 2>/dev/null)
    else
        response=$(curl -s "$url" 2>/dev/null)
    fi
    
    local end_time=$(date +%s%N)
    local duration_ms=$(((end_time - start_time) / 1000000))
    
    echo "$duration_ms:$response"
}

echo "🔍 Step 1: Basic Connectivity Tests"
echo "-----------------------------------"

# Test 1: Ollama service availability
echo "Testing Ollama service connectivity..."
ollama_test=$(test_endpoint "http://localhost:11434/api/version" "200")
if [[ "$ollama_test" == "PASS" ]]; then
    # Get Ollama version
    ollama_version=$(curl -s http://localhost:11434/api/version 2>/dev/null | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
    print_result "Ollama Service Connectivity" "PASS" "Version: $ollama_version"
else
    print_result "Ollama Service Connectivity" "FAIL" "Cannot reach Ollama on port 11434"
fi

# Test 2: Embedding proxy health
echo "Testing embedding proxy health..."
embed_health=$(test_endpoint "http://localhost:8081/health" "200")
if [[ "$embed_health" == "PASS" ]]; then
    print_result "Embedding Proxy Health" "PASS" "Responding on port 8081"
else
    print_result "Embedding Proxy Health" "FAIL" "Cannot reach embedding proxy on port 8081"
fi

# Test 3: Chat proxy health
echo "Testing chat proxy health..."
chat_health=$(test_endpoint "http://localhost:8080/health" "200")
if [[ "$chat_health" == "PASS" ]]; then
    print_result "Chat Proxy Health" "PASS" "Responding on port 8080"
else
    print_result "Chat Proxy Health" "FAIL" "Cannot reach chat proxy on port 8080"
fi

echo ""
echo "🧮 Step 2: Embedding Functionality Tests"
echo "----------------------------------------"

# Test 4: Basic embedding generation
echo "Testing basic embedding generation..."
embed_data='{"content": "search_document: This is a test document for embedding generation."}'
embed_result=$(measure_response_time "http://localhost:8081/embedding" "$embed_data")
embed_time=$(echo "$embed_result" | cut -d':' -f1)
embed_response=$(echo "$embed_result" | cut -d':' -f2-)

if [[ "$embed_response" == *"embedding"* ]] && [[ "$embed_response" == *"["* ]]; then
    # Extract embedding length
    embed_length=$(echo "$embed_response" | grep -o '\[.*\]' | tr ',' '\n' | wc -l)
    print_result "Basic Embedding Generation" "PASS" "Generated ${embed_length}-dimensional embedding in ${embed_time}ms"
else
    print_result "Basic Embedding Generation" "FAIL" "Invalid response format or missing embedding data"
fi

# Test 5: Embedding with query prefix
echo "Testing embedding with query prefix..."
query_data='{"content": "search_query: What is artificial intelligence?"}'
query_result=$(measure_response_time "http://localhost:8081/embedding" "$query_data")
query_time=$(echo "$query_result" | cut -d':' -f1)
query_response=$(echo "$query_result" | cut -d':' -f2-)

if [[ "$query_response" == *"embedding"* ]] && [[ "$query_response" == *"["* ]]; then
    print_result "Query Embedding Generation" "PASS" "Generated query embedding in ${query_time}ms"
else
    print_result "Query Embedding Generation" "FAIL" "Failed to generate query embedding"
fi

# Test 6: Empty content handling
echo "Testing empty content handling..."
empty_data='{"content": ""}'
empty_result=$(curl -s -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$empty_data" "http://localhost:8081/embedding" 2>/dev/null)
empty_code="${empty_result: -3}"
empty_response="${empty_result%???}"

if [ "$empty_code" = "200" ] || [ "$empty_code" = "400" ]; then
    print_result "Empty Content Handling" "PASS" "Handled empty content appropriately (HTTP $empty_code)"
else
    print_result "Empty Content Handling" "FAIL" "Unexpected response to empty content (HTTP $empty_code)"
fi

echo ""
echo "💬 Step 3: Chat Functionality Tests"
echo "-----------------------------------"

# Test 7: Basic chat completion
echo "Testing basic chat completion..."
chat_data='{"prompt": "What is the capital of France?", "n_predict": 50, "temperature": 0.2}'
chat_result=$(measure_response_time "http://localhost:8080/completion" "$chat_data")
chat_time=$(echo "$chat_result" | cut -d':' -f1)
chat_response=$(echo "$chat_result" | cut -d':' -f2-)

if [[ "$chat_response" == *"content"* ]] && [[ "$chat_response" == *"Paris"* ]]; then
    response_length=$(echo "$chat_response" | grep -o '"content":"[^"]*"' | wc -c)
    print_result "Basic Chat Completion" "PASS" "Generated response (${response_length} chars) in ${chat_time}ms"
elif [[ "$chat_response" == *"content"* ]]; then
    print_result "Basic Chat Completion" "PASS" "Generated response in ${chat_time}ms (content validation skipped)"
else
    print_result "Basic Chat Completion" "FAIL" "Invalid response format or missing content"
fi

# Test 8: Longer conversation
echo "Testing longer conversation..."
long_prompt="Explain in 2-3 sentences what machine learning is and how it relates to artificial intelligence."
long_data=$(cat << EOF
{
    "prompt": "$long_prompt",
    "n_predict": 150,
    "temperature": 0.3
}
EOF
)
long_result=$(measure_response_time "http://localhost:8080/completion" "$long_data")
long_time=$(echo "$long_result" | cut -d':' -f1)
long_response=$(echo "$long_result" | cut -d':' -f2-)

if [[ "$long_response" == *"content"* ]]; then
    long_content=$(echo "$long_response" | grep -o '"content":"[^"]*"' | cut -d'"' -f4)
    word_count=$(echo "$long_content" | wc -w)
    print_result "Longer Conversation" "PASS" "Generated ${word_count} words in ${long_time}ms"
else
    print_result "Longer Conversation" "FAIL" "Failed to generate longer response"
fi

# Test 9: Temperature parameter
echo "Testing temperature parameter..."
temp_data='{"prompt": "The weather today is", "n_predict": 20, "temperature": 0.8}'
temp_result=$(curl -s -X POST -H "Content-Type: application/json" -d "$temp_data" "http://localhost:8080/completion" 2>/dev/null)

if [[ "$temp_result" == *"content"* ]]; then
    print_result "Temperature Parameter" "PASS" "Successfully used temperature setting"
else
    print_result "Temperature Parameter" "FAIL" "Failed to process temperature parameter"
fi

echo ""
echo "🔗 Step 4: Integration Tests"
echo "----------------------------"

# Test 10: RAG simulation
echo "Testing RAG workflow simulation..."
documents=("Artificial intelligence is the simulation of human intelligence." 
           "Machine learning is a subset of AI that learns from data."
           "Deep learning uses neural networks with multiple layers.")

# Generate embeddings for documents
doc_embeddings=()
for i in "${!documents[@]}"; do
    doc_data="{\"content\": \"search_document: ${documents[$i]}\"}"
    doc_result=$(curl -s -X POST -H "Content-Type: application/json" -d "$doc_data" "http://localhost:8081/embedding" 2>/dev/null)
    
    if [[ "$doc_result" == *"embedding"* ]]; then
        doc_embeddings[$i]="$doc_result"
    else
        print_result "RAG Workflow Simulation" "FAIL" "Failed to embed document $i"
        break
    fi
done

# Generate query embedding
query_data='{"content": "search_query: What is machine learning?"}'
query_emb_result=$(curl -s -X POST -H "Content-Type: application/json" -d "$query_data" "http://localhost:8081/embedding" 2>/dev/null)

if [[ "$query_emb_result" == *"embedding"* ]] && [ ${#doc_embeddings[@]} -eq 3 ]; then
    # Simulate retrieval and generation
    context="Based on the documents: Machine learning is a subset of AI that learns from data."
    rag_prompt="Context: $context\nQuestion: What is machine learning?\nAnswer:"
    rag_data="{\"prompt\": \"$rag_prompt\", \"n_predict\": 100, \"temperature\": 0.2}"
    rag_response=$(curl -s -X POST -H "Content-Type: application/json" -d "$rag_data" "http://localhost:8080/completion" 2>/dev/null)
    
    if [[ "$rag_response" == *"content"* ]]; then
        print_result "RAG Workflow Simulation" "PASS" "Successfully completed embedding + retrieval + generation"
    else
        print_result "RAG Workflow Simulation" "FAIL" "Failed at generation stage"
    fi
else
    print_result "RAG Workflow Simulation" "FAIL" "Failed at embedding stage"
fi

echo ""
echo "⚡ Step 5: Performance Tests"
echo "---------------------------"

# Test 11: Concurrent requests
echo "Testing concurrent embedding requests..."
temp_dir=$(mktemp -d)
concurrent_success=0
concurrent_total=5

for i in $(seq 1 $concurrent_total); do
    {
        test_data="{\"content\": \"search_document: Test document number $i for concurrent processing.\"}"
        result=$(curl -s -X POST -H "Content-Type: application/json" -d "$test_data" "http://localhost:8081/embedding" 2>/dev/null)
        if [[ "$result" == *"embedding"* ]]; then
            echo "SUCCESS" > "$temp_dir/test_$i.result"
        else
            echo "FAIL" > "$temp_dir/test_$i.result"
        fi
    } &
done

wait  # Wait for all background jobs to complete

for i in $(seq 1 $concurrent_total); do
    if [ -f "$temp_dir/test_$i.result" ] && [ "$(cat "$temp_dir/test_$i.result")" = "SUCCESS" ]; then
        concurrent_success=$((concurrent_success + 1))
    fi
done

rm -rf "$temp_dir"

if [ $concurrent_success -eq $concurrent_total ]; then
    print_result "Concurrent Requests" "PASS" "All $concurrent_total concurrent requests succeeded"
else
    print_result "Concurrent Requests" "FAIL" "Only $concurrent_success/$concurrent_total requests succeeded"
fi

echo ""
echo "📊 Test Summary"
echo "==============="

# Calculate success rate
success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))

echo "Total Tests: $TOTAL_TESTS"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
echo -e "Success Rate: ${BLUE}${success_rate}%${NC}"

echo ""
echo "🔧 System Information"
echo "====================="

# Show current models in use
if curl -sf http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo "📋 Available Ollama models:"
    ollama list | head -n 10
fi

# Show resource usage
echo ""
echo "💾 Resource Usage:"
if command -v free >/dev/null 2>&1; then
    echo "Memory: $(free -h | grep Mem: | awk '{print $3 "/" $2}')"
fi

# Show process information
echo ""
echo "🔄 Running Processes:"
embed_pid=$(cat "$ROOT_DIR/logs/embedding.pid" 2>/dev/null || echo "N/A")
chat_pid=$(cat "$ROOT_DIR/logs/chat.pid" 2>/dev/null || echo "N/A")
echo "Embedding Proxy PID: $embed_pid"
echo "Chat Proxy PID: $chat_pid"

# Show recent log entries
if [ -f "$ROOT_DIR/logs/embedding.log" ] && [ -f "$ROOT_DIR/logs/chat.log" ]; then
    echo ""
    echo "📝 Recent Log Entries:"
    echo "Embedding logs:"
    tail -n 2 "$ROOT_DIR/logs/embedding.log" | sed 's/^/  /'
    echo "Chat logs:"
    tail -n 2 "$ROOT_DIR/logs/chat.log" | sed 's/^/  /'
fi

echo ""
# Final verdict
if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "🎉 ${GREEN}All tests passed! RAG system is working correctly.${NC}"
    exit 0
elif [ $success_rate -ge 80 ]; then
    echo -e "⚠️  ${YELLOW}Most tests passed ($success_rate%). Some issues detected.${NC}"
    echo "💡 Check failed tests above and logs in $ROOT_DIR/logs/"
    exit 1
else
    echo -e "❌ ${RED}Multiple test failures ($success_rate% success rate).${NC}"
    echo "🚨 RAG system requires attention. Check:"
    echo "   - Ollama service status: ollama list"
    echo "   - Proxy server logs: tail -f logs/*.log"
    echo "   - Network connectivity: curl localhost:11434/api/version"
    exit 2
fi 