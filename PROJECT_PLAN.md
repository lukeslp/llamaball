# 🦙 Llamaball Project Plan

**Project:** Doc Chat AI → Llamaball Package  
**Version:** 0.1.0  
**Status:** Active Development  
**Last Updated:** 2025-06-05

## 🎯 Project Objectives

### Primary Goals
1. **Accessibility-First RAG System**: Create a document chat system that prioritizes screen reader compatibility and keyboard navigation
2. **Local AI Privacy**: 100% local processing with no data leaving the user's machine
3. **Developer-Friendly Package**: Installable CLI and Python API with comprehensive documentation
4. **Production-Ready Features**: Rich statistics, error handling, and monitoring capabilities

### Secondary Goals
- **Multiple Model Support**: Configurable chat and embedding models
- **Rich CLI Experience**: Beautiful terminal interface with progress indicators
- **Comprehensive Documentation**: Self-describing code and extensive help
- **Easy Integration**: Drop-in replacement for existing document chat systems

## 🏗️ Current Architecture

### Package Structure
```
doc_chat_ai/
├── llamaball/              # Main package (✅ COMPLETED)
│   ├── __init__.py         # Package initialization
│   ├── cli.py              # Rich CLI with Typer + Rich
│   ├── core.py             # Core RAG functionality
│   ├── utils.py            # Utilities (markdown rendering)
│   └── README.md           # Comprehensive package docs
├── models/                 # Model configurations (✅ COMPLETED)
│   ├── Modelfile.gemma3:1b # Gemma 3 1B config
│   ├── Modelfile.qwen3:0.6b # Qwen3 configurations
│   ├── Modelfile.qwen3:1.7b
│   └── Modelfile.qwen3:4b
├── setup.py                # Package installation (✅ COMPLETED)
└── README.md               # Main project documentation (✅ COMPLETED)
```

### Technology Stack
- **CLI Framework**: Typer with Rich for enhanced UX
- **LLM Backend**: Ollama for local model inference
- **Embeddings**: nomic-embed-text (standardized across all tiers)
- **Vector Store**: SQLite with custom similarity search
- **UI/UX**: Rich terminal formatting, accessibility-focused
- **Installation**: setuptools with pip-installable package

## ✅ Completed Features

### 🖥️ CLI Interface
- [x] **Interactive Commands**: ingest, chat, stats, list, clear, version
- [x] **Short Flags**: All commands support `-h`, `-v`, `-d`, `-m`, etc.
- [x] **Rich Help System**: Comprehensive help with examples and tables
- [x] **Welcome Screen**: Attractive landing page when run without args
- [x] **Progress Indicators**: Real-time feedback during operations
- [x] **Error Handling**: Descriptive errors with suggested solutions
- [x] **Module Execution**: `python -m llamaball` and `llamaball` entry points
- [x] **Package Installation**: pip-installable with proper entry points
- [x] **Debug Mode**: Enhanced logging and debug output for troubleshooting

### 🔍 Document Processing
- [x] **Smart Ingestion**: Intelligent chunking and embedding generation
- [x] **File Type Support**: .txt, .md, .py, .json, .csv files
- [x] **Recursive Scanning**: Optional subdirectory processing
- [x] **Pattern Exclusion**: Configurable file filtering with fnmatch patterns
- [x] **Force Re-indexing**: Option to rebuild entire database
- [x] **Parallel Processing**: Multi-threaded embedding generation
- [x] **Skip Unchanged**: Efficient incremental updates based on mtime

### 💬 Chat System
- [x] **Interactive Chat**: Real-time conversation with documents
- [x] **Context Retrieval**: Top-K semantic search integration
- [x] **Chat Commands**: help, stats, clear, exit commands
- [x] **Session Management**: Conversation history and state
- [x] **Configurable Models**: Support for different chat models
- [x] **Tool Calling**: Python code execution and bash command support
- [x] **Markdown Rendering**: HTML output formatted for terminal display
- [x] **Error Recovery**: Graceful handling of model failures with fallbacks

### 📊 Database Management
- [x] **Statistics Dashboard**: Document counts, file types, sizes
- [x] **File Listing**: Searchable and sortable file inventory
- [x] **Database Clearing**: Safe deletion with backup options
- [x] **Multiple Formats**: Table, JSON, and plain text output

### ♿ Accessibility Features
- [x] **Screen Reader Support**: Semantic markup throughout
- [x] **Keyboard Navigation**: Full functionality via keyboard
- [x] **High Contrast Output**: Rich formatting with good contrast
- [x] **Clear Structure**: Predictable command patterns
- [x] **Descriptive Feedback**: Comprehensive error messages

### 🐍 Python API
- [x] **Core Functions**: ingest_files, search_embeddings, chat
- [x] **Type Hints**: Full typing support for IDE integration
- [x] **Docstrings**: Comprehensive function documentation
- [x] **Error Handling**: Proper exception management

### 🛠️ Model Configurations
- [x] **Gemma 3 1B**: Production-ready configuration
- [x] **Qwen3 Series**: 0.6B, 1.7B, and 4B variants
- [x] **Standardized Embedding**: nomic-embed-text across all configs
- [x] **Template Optimization**: Consistent prompt formatting

## 🔧 Recent Updates (2025-06-05)

### CLI Package Debugging & Fixes
- **Fixed Module Execution**: Added `__main__.py` to enable `python -m llamaball`
- **Package Initialization**: Added proper `__init__.py` with version and API exports
- **Entry Points**: Verified console script installation and functionality
- **Error Handling**: Improved exception handling in CLI commands
- **Exclude Patterns**: Implemented fnmatch-based file exclusion in ingest
- **Status Context**: Fixed progress indicator context manager usage
- **Chat Response Parsing**: Enhanced Ollama API response handling for consistency
- **Debug Logging**: Added comprehensive debug mode for troubleshooting
- **API Compatibility**: Updated tool calling format for latest Ollama API

### Dynamic Model & Parameter Control
- **Model Discovery**: Added `/api/tags` endpoint integration to fetch available Ollama models
- **Live Model Switching**: Implemented `/model <name>` command for chat session model changes
- **Parameter Adjustment**: Added commands for temperature, max tokens, top-p, top-k, repeat penalty
- **Session State Management**: Created `ChatSession` class to track conversation and settings
- **Rich Model Display**: Added formatted table showing model names, sizes, families, and parameters
- **Real-time Configuration**: All model parameters can be changed mid-conversation
- **Status Monitoring**: Added `/status` command to view current model and parameter settings

### New Chat Commands (Interactive Session)
- ✅ `/models` - List all available Ollama models with details
- ✅ `/model <name>` - Switch to a different chat model instantly  
- ✅ `/temp <0.0-2.0>` - Adjust response creativity/randomness
- ✅ `/tokens <1-8192>` - Change maximum response length
- ✅ `/topk <1-20>` - Modify document retrieval count
- ✅ `/topp <0.0-1.0>` - Adjust nucleus sampling parameter
- ✅ `/penalty <0.0-2.0>` - Change repetition penalty
- ✅ `/status` - Display current model and parameter configuration
- ✅ `/commands` - Show all available chat commands

### New CLI Commands & Options
- ✅ `llamaball models` - Dedicated command for model management
- ✅ `llamaball models <name>` - Show specific model details
- ✅ `llamaball models --format json|plain` - Different output formats
- ✅ `llamaball chat --list-models` - List models from chat command
- ✅ `llamaball chat -c <model>` - Specify chat model directly
- ✅ `llamaball chat --temperature <0.0-2.0>` - Set temperature from CLI
- ✅ `llamaball chat --max-tokens <1-8192>` - Set max tokens from CLI
- ✅ `llamaball chat --top-p <0.0-1.0>` - Set nucleus sampling from CLI
- ✅ `llamaball chat --top-k-sampling <int>` - Set top-K sampling from CLI
- ✅ `llamaball chat --repeat-penalty <0.0-2.0>` - Set repeat penalty from CLI

### Verified Functionality
- ✅ `llamaball --help` - Main CLI help and welcome screen
- ✅ `llamaball version` - Version information display
- ✅ `llamaball stats` - Database statistics with proper formatting
- ✅ `llamaball ingest test/ --exclude "*.tmp,*.log"` - File ingestion with patterns
- ✅ `llamaball chat --debug` - Interactive chat with context retrieval
- ✅ Package imports: `import llamaball` works correctly
- ✅ Module execution: Both `python -m llamaball` and `llamaball` work
- ✅ **Dynamic Model Control** - Change models and parameters during chat
- ✅ **Model Listing** - View all available models with size/parameter info  
- ✅ **Parameter Tuning** - Real-time adjustment of generation parameters
- ✅ **CLI Model Control** - Set models and parameters directly from command line
- ✅ **Dedicated Models Command** - `llamaball models` for model management
- ✅ **CLI Parameter Override** - `--temperature 0.1 --max-tokens 200` work correctly
- ✅ **Model Details Display** - `llamaball models <name>` shows specific model info
- ✅ **Format Options** - `--format json|plain|table` output variants
- ✅ **List Models Integration** - `llamaball chat --list-models` displays and exits
- ✅ **Interactive Status** - `/status` command shows all current configuration

## 🚧 Outstanding Tasks

### High Priority
- [ ] **Testing Suite**: Comprehensive unit and integration tests
- [ ] **Performance Optimization**: Batch processing and caching
- [ ] **Error Recovery**: Graceful handling of model/network failures
- [ ] **Configuration Validation**: Startup checks for model availability

### Medium Priority
- [ ] **Advanced Search**: Filtering, faceted search, metadata queries
- [ ] **Export Features**: Save conversations, export search results
- [ ] **Plugin System**: Extensible file type support
- [ ] **Batch Operations**: Multi-document processing workflows

### Low Priority
- [ ] **Web Interface**: Optional web UI for non-CLI users
- [ ] **Cloud Sync**: Optional backup/sync capabilities
- [ ] **Advanced Analytics**: Usage metrics and search patterns
- [ ] **Model Management**: Automatic updates and version control

### Technical Debt
- [ ] **Legacy Script Migration**: Fully deprecate doc_chat_ollama.py
- [ ] **Configuration Management**: Centralized config system
- [ ] **Logging Improvements**: Structured logging with levels
- [ ] **Memory Optimization**: Efficient embedding storage and retrieval

## 🔧 Current Configuration

### Default Settings
- **Database**: `.clai.db` (SQLite)
- **Embedding Model**: `nomic-embed-text:latest`
- **Chat Model**: `llama3.2:1b` (env: CHAT_MODEL)
- **Provider**: `ollama` (local inference)
- **Top-K Retrieval**: 3 documents
- **Max Tokens**: 8191 per chunk

### Environment Variables
- `CHAT_MODEL`: Default chat model
- `OLLAMA_ENDPOINT`: Ollama server URL
- `LLAMABALL_DB`: Default database path
- `LLAMABALL_LOG_LEVEL`: Logging verbosity

## 📋 Installation Requirements

### Dependencies
- **Python**: 3.8+ (development tested on 3.11)
- **Core Packages**: typer[all], rich, ollama, numpy, tiktoken
- **UI Packages**: prompt_toolkit, markdown-it-py
- **External**: Ollama server for model inference

### System Requirements
- **Memory**: 4GB minimum, 8GB+ recommended
- **Storage**: 2GB for package + models (varies by model size)
- **OS**: macOS, Linux, Windows (with WSL)

## 🎨 Design Principles

### Accessibility First
1. **Screen Reader Compatibility**: All output uses semantic markup
2. **Keyboard Navigation**: No mouse-dependent features
3. **Clear Information Architecture**: Consistent command structure
4. **Descriptive Feedback**: Rich error messages and help text

### Local Privacy
1. **No External Calls**: All processing happens locally
2. **Data Sovereignty**: User controls all data and models
3. **Transparent Processing**: Clear indication of what data is used
4. **Secure by Default**: No telemetry or usage tracking

### Developer Experience
1. **Self-Documenting**: Code includes purpose and I/O in comments
2. **Type Safety**: Full type hints for IDE support
3. **Consistent API**: Predictable function signatures and returns
4. **Extensible Design**: Plugin-friendly architecture

## 🧪 Testing Strategy

### Unit Tests (TODO)
- Core functionality: embedding, search, chat
- CLI command parsing and validation
- Database operations and migrations
- Error handling and edge cases

### Integration Tests (TODO)
- End-to-end ingestion workflows
- Chat session management
- Multi-model compatibility
- Performance benchmarks

### Accessibility Tests (TODO)
- Screen reader compatibility verification
- Keyboard navigation testing
- Color contrast validation
- Text-to-speech friendliness

## 📈 Success Metrics

### Technical Metrics
- **Ingestion Speed**: Documents per second processed
- **Search Accuracy**: Relevant results in top-K retrievals
- **Response Time**: Chat latency and throughput
- **Memory Efficiency**: RAM usage during operations

### User Experience Metrics
- **Accessibility Score**: Screen reader compatibility rating
- **Documentation Coverage**: Help completeness and clarity
- **Error Recovery**: Graceful failure handling
- **Setup Time**: Time from install to first successful chat

### Adoption Metrics
- **Package Downloads**: PyPI installation statistics
- **Community Feedback**: GitHub issues and feature requests
- **Documentation Usage**: README and help command access
- **Integration Examples**: Third-party usage patterns

## 🔄 Release Planning

### v0.1.0 (Current)
- ✅ Core package functionality
- ✅ Rich CLI interface
- ✅ Comprehensive documentation
- ✅ Basic accessibility features

### v0.2.0 (Next)
- [ ] Comprehensive testing suite
- [ ] Performance optimizations
- [ ] Advanced search capabilities
- [ ] Plugin architecture foundation

### v1.0.0 (Future)
- [ ] Production stability
- [ ] Full accessibility certification
- [ ] Comprehensive monitoring
- [ ] Enterprise-ready features

## 🤝 Contributing Guidelines

### Code Standards
1. **Accessibility**: All features must support screen readers
2. **Documentation**: Every function needs docstrings and type hints
3. **Testing**: New features require corresponding tests
4. **Consistency**: Follow established patterns and conventions

### Review Process
1. **Technical Review**: Code quality and architecture assessment
2. **Accessibility Review**: Screen reader and keyboard testing
3. **Documentation Review**: Help text and README updates
4. **Performance Review**: Memory and speed impact evaluation

---

**🎯 Mission**: Build the most accessible, privacy-focused document chat system available, empowering users with local AI while maintaining the highest standards of usability and technical excellence. 