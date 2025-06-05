# doc_chat_ai

Document Chat CLI for local document Q&A with vector search and LLMs (Ollama or OpenAI).

## Features
- Ingests text, markdown, code, JSON, and CSV files from a directory
- Chunks documents, stores in a local SQLite vector DB with embeddings
- Supports both Ollama and OpenAI for embeddings and chat
- Interactive chat mode with context retrieval from your documents
- Function-calling: run Python or Bash code from chat

## Installation
- Python 3.8+
- `pip install typer numpy tiktoken tqdm markdown-it-py prompt_toolkit ollama openai`
- For Ollama: [Ollama must be installed and running](https://ollama.com/)
- For OpenAI: Set `OPENAI_API_KEY` in your environment

## Usage
### Ingest documents
- Ollama: `python doc_chat_ollama.py ingest --dir PATH [--db PATH] [--model MODEL_NAME]`
- OpenAI: `python doc_chat_openai.py ingest --dir PATH [--db PATH] [--model MODEL_NAME]`

### Chat with your documents
- Ollama: `python doc_chat_ollama.py chat [--db PATH] [--model MODEL_NAME] [--topk N]`
- OpenAI: `python doc_chat_openai.py chat [--db PATH] [--model MODEL_NAME] [--topk N]`

### Other commands
- `stats` — Show document and embedding counts
- `list-files` — List all ingested files
- `clear-db` — Reset the database

## Project Structure
- `doc_chat_ollama.py`: Ollama-based CLI
- `doc_chat_openai.py`: OpenAI-based CLI

## License
MIT
