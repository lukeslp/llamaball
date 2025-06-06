# 🦙 Llamaball

**Accessible document chat and RAG system powered by Ollama**

[![PyPI version](https://badge.fury.io/py/llamaball.svg)](https://badge.fury.io/py/llamaball)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive toolkit for document ingestion, embedding generation, and conversational AI interactions with your local documents. Built with accessibility and local privacy as core principles.

## ✨ Features

- **🏠 100% Local Processing**: All data stays on your machine
- **♿ Accessibility First**: Screen reader support, keyboard navigation, clear structure
- **🖥️ Rich CLI**: Beautiful terminal interface with progress indicators
- **📚 Smart Document Parsing**: Intelligent chunking for optimal embeddings with support for PDFs, DOCX, and spreadsheets
- **🔍 Semantic Search**: Fast vector similarity search
- **💬 Interactive Chat**: Natural conversations with your documents
- **📊 Database Management**: Comprehensive statistics and file management
- **🎛️ Dynamic Model Control**: Change models and parameters during chat
- **🔧 Developer-Friendly**: Full Python API with type hints

## 🚀 Quick Start

### Installation

```bash
# Install from PyPI
pip install llamaball

# Or install with development dependencies
pip install llamaball[dev]
```

### Prerequisites

Llamaball requires [Ollama](https://ollama.ai/) to be installed and running:

1. Install Ollama from [ollama.ai](https://ollama.ai/)
2. Pull some models:
   ```bash
   ollama pull llama3.2:1b
   ollama pull nomic-embed-text
   ```

### Basic Usage

```bash
# Ingest documents from current directory
llamaball ingest .

# Start interactive chat
llamaball chat

# View statistics
llamaball stats

# List all files in database
llamaball list

# Get help
llamaball --help
```

## 📋 CLI Commands

### Document Management

```bash
# Ingest files with options
llamaball ingest ./docs --recursive --exclude "*.tmp,*.log"

# Force re-indexing
llamaball ingest ./docs --force

# View database statistics
llamaball stats --format table

# List files with search
llamaball list --search "python" --sort-by size
```

### Interactive Chat

```bash
# Start chat with specific model
llamaball chat --model llama3.2:3b

# Set parameters from CLI
llamaball chat --temperature 0.1 --max-tokens 200

# Enable debug mode
llamaball chat --debug
```

### Model Management

```bash
# List available models
llamaball models

# Show specific model details
llamaball models llama3.2:1b

# List models in JSON format
llamaball models --format json
```

## 💬 Interactive Chat Commands

Once in chat mode, use these commands:

- `/models` - List all available Ollama models
- `/model <name>` - Switch to a different chat model
- `/temp <0.0-2.0>` - Adjust response creativity
- `/tokens <1-8192>` - Change maximum response length
- `/topk <1-20>` - Modify document retrieval count
- `/status` - Display current configuration
- `/help` - Show all chat commands
- `/exit` - Exit chat mode

## 🐍 Python API

```python
from llamaball import core

# Ingest documents
core.ingest_files("./docs", recursive=True, exclude_patterns=["*.tmp"])

# Search embeddings  
results = core.search_embeddings(query="search term", top_k=5)

# Chat with documents
response = core.chat(
    user_input="What is this about?", 
    history=[],
    model="llama3.2:1b"
)

# Get database statistics
stats = core.get_stats()
print(f"Total documents: {stats['total_files']}")
```

## ⚙️ Configuration

### Environment Variables

- `CHAT_MODEL`: Default chat model (default: `llama3.2:1b`)
- `OLLAMA_ENDPOINT`: Ollama server endpoint (default: `http://localhost:11434`)
- `LLAMABALL_DB`: Database path (default: `.clai.db`)
- `LLAMABALL_LOG_LEVEL`: Logging level (default: `INFO`)

### Supported File Types

- **Text**: `.txt`, `.md`, `.rst`
- **Code**: `.py`, `.js`, `.html`, `.css`, `.json`
- **Data**: `.csv`, `.tsv`, `.xlsx`, `.xls`
- **Documents**: `.pdf`, `.docx`

## ♿ Accessibility Features

- **Screen Reader Support**: Semantic markup and clear structure
- **Keyboard Navigation**: Full CLI functionality via keyboard
- **High Contrast Output**: Rich terminal formatting with good contrast
- **Clear Error Messages**: Descriptive feedback with suggested solutions
- **Progress Indicators**: Real-time feedback during operations
- **Consistent Layout**: Predictable command structure

## 🧪 Development

### Setup

```bash
# Clone repository
git clone https://github.com/lsteuber/llamaball.git
cd llamaball

# Install in development mode
pip install -e .[dev]

# Install pre-commit hooks
pre-commit install
```

### Testing

```bash
# Run tests
pytest

# Run with coverage
pytest --cov=llamaball --cov-report=html

# Type checking
mypy llamaball/

# Code formatting
black llamaball/
isort llamaball/
```

### Building

```bash
# Build package
python -m build

# Upload to PyPI (maintainers only)
python -m twine upload dist/*
```

## 📁 Project Structure

```
llamaball/
├── llamaball/              # Main package
│   ├── __init__.py         # Package initialization
│   ├── cli.py              # CLI interface  
│   ├── core.py             # Core RAG functionality
│   ├── utils.py            # Utilities and helpers
│   └── __main__.py         # Module execution support
├── models/                 # Ollama model configurations
│   ├── Modelfile.gemma3:1b
│   ├── Modelfile.qwen3:*   # Various Qwen3 configurations
│   └── README_LLAMAFILE_RAG.md
├── tests/                  # Test suite
├── docs/                   # Documentation (planned)
├── pyproject.toml          # Modern Python packaging
├── CHANGELOG.md            # Version history
└── README.md               # This file
```

## 🔒 Privacy & Security

- **Local First**: All processing happens on your machine
- **No Telemetry**: No usage data or analytics collected
- **Data Sovereignty**: You control all data and models
- **Transparent**: Open source with clear data handling

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. **Accessibility**: All features must support screen readers
2. **Documentation**: Comprehensive docstrings and type hints
3. **Testing**: New features require corresponding tests
4. **Consistency**: Follow established patterns and conventions

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on [Ollama](https://ollama.ai/) for local AI inference
- Powered by [Typer](https://typer.tiangolo.com/) and [Rich](https://rich.readthedocs.io/) for CLI
- Inspired by accessibility-first design principles

---

**🎯 Mission**: Build the most accessible, privacy-focused document chat system available, empowering users with local AI while maintaining the highest standards of usability and technical excellence.

---

**About the Author**

Project by [Luke Steuber](https://lukesteuber.com) (<https://assisted.site/>).
Tip jar: <https://usefulai.lemonsqueezy.com/buy/bf6ce1bd-85f5-4a09-ba10-191a670f74af>
Substack: <https://lukesteuber.substack.com/>
GitHub: [lukeslp](https://github.com/lukeslp)
Contact: <luke@lukesteuber.com> · [LinkedIn](https://www.linkedin.com/in/lukesteuber/)
