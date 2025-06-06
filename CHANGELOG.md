# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Modern packaging with pyproject.toml
- Comprehensive development tooling configuration
- Package distribution readiness

## [0.1.0] - 2025-01-06

### Added
- ✅ **Interactive CLI** with rich formatting and accessibility features
- ✅ **Python API** for programmatic use
- ✅ **Dynamic Model Control** - Change models and parameters during chat
- ✅ **Model Listing** - View all available models with size/parameter info  
- ✅ **Parameter Tuning** - Real-time adjustment of generation parameters
- ✅ **CLI Model Control** - Set models and parameters directly from command line
- ✅ **Dedicated Models Command** - `llamaball models` for model management
- ✅ **Document Processing** - Smart ingestion with chunking and embeddings
- ✅ **Chat System** - Interactive conversation with documents
- ✅ **Database Management** - Statistics, listing, and clearing
- ✅ **Accessibility Features** - Screen reader support, keyboard navigation
- ✅ **Tool Calling** - Python code execution and bash command support
- ✅ **Markdown Rendering** - HTML output formatted for terminal display
- ✅ **Model Configurations** - Gemma 3 1B and Qwen3 series configurations

### Core Commands
- `llamaball ingest` - Document ingestion with exclude patterns
- `llamaball chat` - Interactive chat with dynamic model switching
- `llamaball stats` - Database statistics and file management
- `llamaball list` - File listing with search and sort options
- `llamaball clear` - Database clearing with backup options
- `llamaball models` - Model management and configuration
- `llamaball version` - Version and system information

### Interactive Chat Commands
- `/models` - List all available Ollama models with details
- `/model <name>` - Switch to a different chat model instantly  
- `/temp <0.0-2.0>` - Adjust response creativity/randomness
- `/tokens <1-8192>` - Change maximum response length
- `/topk <1-20>` - Modify document retrieval count
- `/topp <0.0-1.0>` - Adjust nucleus sampling parameter
- `/penalty <0.0-2.0>` - Change repetition penalty
- `/status` - Display current model and parameter configuration
- `/commands` - Show all available chat commands

### Technical Features
- **100% Local Processing** - All data stays on your machine
- **Multiple File Types** - .txt, .md, .py, .json, .csv support
- **Vector Search** - Fast semantic similarity search
- **Error Recovery** - Graceful handling of model failures with fallbacks
- **Progress Indicators** - Real-time feedback during operations
- **Debug Mode** - Enhanced logging and troubleshooting support

### Package Structure
- **CLI Interface** (`llamaball.cli`) - Rich terminal interface
- **Core Functionality** (`llamaball.core`) - RAG system implementation
- **Utilities** (`llamaball.utils`) - Helper functions and markdown rendering
- **Model Configurations** (`models/`) - Ollama model configurations
- **Entry Points** - Both `llamaball` command and `python -m llamaball` 