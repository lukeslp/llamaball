
## 🔐 Authentication Setup

1. Get your API key from https://ollama.com/settings
2. Set environment variable:
   ```bash
   export OLLAMA_API_KEY='your_api_key_here'
   ```

## 🚀 Building & Publishing Models

```bash
# Build and push all models
./build_and_push_models.sh

# Show what would be done
./build_and_push_models.sh --dry-run

# Get help
./build_and_push_models.sh --help
```

## 📦 Available Models

- `lukeslp/llamaball:1b` (Gemma 3 1B)
- `lukeslp/llamaball:4b` (Gemma 3 4B) 
- `lukeslp/llamaball:27b` (Gemma 3 27B)
- `lukeslp/llamaball:llama-1b` (Llama 3.2 1B)
- `lukeslp/llamaball:llama-3b` (Llama 3.2 3B)
- `lukeslp/llamaball:qwen-0.6b` (Qwen 3 0.6B)
- `lukeslp/llamaball:qwen-1.7b` (Qwen 3 1.7B)
- `lukeslp/llamaball:qwen-4b` (Qwen 3 4B)

## 🛠️ Manual Process

```bash
# Build model
ollama create -f Modelfiles/Modelfile.gemma3:4b llamaball:4b

# Copy to namespace
ollama cp llamaball:4b lukeslp/llamaball:4b

# Push to hub
ollama push lukeslp/llamaball:4b
``` 
# 🦙 Llamaball Model Building & Publishing Guide
 