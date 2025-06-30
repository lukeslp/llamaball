# 🦙 Llamaline Project Plan

**Project:** Llamaline - Your Friendly Document Chat Companion  
**Version:** 0.1.0  
**Status:** Ready to Rock & Roll  
**Last Updated:** 2025-01-06  
**Creator:** Luke Steuber (lukesteuber.com, assisted.site)

---

## 🎯 What We're Building Here

### The Big Picture
We're creating the most accessible, privacy-focused document chat system that actually works the way humans expect it to. No more sacrificing usability for features, no more choosing between privacy and functionality. Llamaline is proof that local AI can be both powerful and actually pleasant to use.

### Primary Goals (The Non-Negotiables)
1. **Accessibility Champion**: Every single feature works beautifully with screen readers and keyboard navigation
2. **Privacy Paradise**: Your documents never leave your machine - we're not in the data collection business
3. **Developer Delight**: Clean Python API with proper type hints and documentation that doesn't make you cry
4. **Production Polish**: Real statistics, intelligent error handling, and monitoring that actually helps

### Secondary Goals (The Nice-to-Haves That Are Actually Pretty Important)
- **Model Flexibility**: Support for multiple chat and embedding models because one size doesn't fit all
- **Terminal Excellence**: CLI interface that doesn't make you want to switch to a GUI
- **Documentation That Doesn't Suck**: Self-explaining code and help that actually helps
- **Easy Integration**: Drop it into your workflow without rewriting everything

## 🏗️ Current Architecture (How the Sausage Gets Made)

### Package Structure (The Real Deal)
```
doc_chat_ai/
├── llamaline/              # Main package (✅ WORKING)
│   ├── __init__.py         # Package setup and public API exports
│   ├── cli.py              # Rich CLI interface with Typer magic (34KB, 862 lines)
│   ├── core.py             # RAG engine and database operations (17KB, 452 lines)
│   ├── utils.py            # Helper functions and utilities (783B, 19 lines)
│   └── __main__.py         # Module execution support (281B, 13 lines)
├── models/                 # Ollama model configurations (✅ READY)
│   ├── Modelfile.gemma3:1b # Gemma 3 1B configuration
│   ├── Modelfile.qwen3:*   # Various Qwen3 configurations
│   └── README_LLAMAFILE_RAG.md # Model documentation
├── tests/                  # Test suite (🚧 STRUCTURE READY)
│   ├── __init__.py
│   └── test_core.py        # Basic test framework
├── archive/                # Legacy files (✅ ORGANIZED)
│   ├── legacy_scripts/     # Old setup/run scripts
│   ├── development_files/  # Temp files and artifacts
│   └── test_data/          # Unrelated test directories
├── venv/                   # Virtual environment (local)
├── pyproject.toml          # Modern Python packaging (✅ DONE)
├── setup.py                # Legacy compatibility (✅ DONE)
├── LICENSE                 # MIT License (✅ DONE)
├── CHANGELOG.md            # Version history (✅ DONE)
├── CONTRIBUTING.md         # Contributor guidelines (✅ DONE)
├── MANIFEST.in             # Package distribution control (✅ DONE)
├── README.md               # Main documentation (✅ UPDATED)
└── PROJECT_PLAN.md         # This document (✅ UPDATING)
```

### Technology Stack (Our Tools of Choice)
- **CLI Magic**: Typer + Rich for a terminal experience that doesn't suck
- **LLM Power**: Ollama for local model inference (privacy first!)
- **Embeddings**: nomic-embed-text (standardized and reliable)
- **Vector Storage**: SQLite with custom similarity search (simple but effective)
- **UI/UX**: Rich terminal formatting with accessibility baked in
- **Distribution**: Modern setuptools with pip-installable package

## ✅ What's Actually Working Right Now

### 🖥️ CLI Interface (The Face of the Operation)
- [x] **Core Commands**: ingest, chat, stats, list, clear, version
- [x] **Smart Flags**: Short flags everywhere (-h, -v, -d, -m, etc.)
- [x] **Helpful Help**: Rich help system with examples and tables
- [x] **Nice Landing**: Welcome screen when you run it without arguments
- [x] **Real Feedback**: Progress bars and status updates that actually update
- [x] **Smart Errors**: Error messages that tell you what went wrong AND how to fix it
- [x] **Multiple Entry Points**: Both `python -m llamaline` and `llamaline` work
- [x] **Pip Installation**: Installs cleanly with proper entry points
- [x] **Debug Mode**: Verbose logging when things get weird

### 🔍 Document Processing (The Smart Stuff)
- [x] **Intelligent Ingestion**: Chunking that actually makes sense
- [x] **File Type Support**: .txt, .md, .py, .json, .csv files
- [x] **Recursive Magic**: Scan subdirectories when you want to
- [x] **Pattern Filtering**: Exclude files with fnmatch patterns
- [x] **Force Rebuild**: Nuclear option when you need a fresh start
- [x] **Parallel Processing**: Multi-threaded embedding generation
- [x] **Skip Unchanged**: Only reprocess files that actually changed

### 💬 Chat System (Where the Magic Happens)
- [x] **Interactive Chat**: Real-time conversations with your documents
- [x] **Context Retrieval**: Top-K semantic search that finds relevant stuff
- [x] **Chat Commands**: Built-in help, stats, and control commands
- [x] **Session Management**: Conversation history that persists
- [x] **Configurable Models**: Switch models without losing your mind
- [x] **Tool Support**: Python code execution and bash commands
- [x] **Markdown Rendering**: Formatted output that looks good in the terminal
- [x] **Error Recovery**: Graceful handling when models have bad days

### 📊 Database Management (The Organized Stuff)
- [x] **Statistics Dashboard**: Document counts, file types, sizes
- [x] **File Listing**: Searchable and sortable file inventory
- [x] **Database Clearing**: Safe deletion with backup options
- [x] **Multiple Formats**: Table, JSON, and plain text output

### ♿ Accessibility Features (The Important Stuff)
- [x] **Screen Reader Support**: Semantic markup throughout
- [x] **Keyboard Navigation**: Everything works without a mouse
- [x] **High Contrast Output**: Terminal formatting that doesn't hurt
- [x] **Clear Structure**: Predictable command patterns
- [x] **Descriptive Feedback**: Error messages that actually help

### 🐍 Python API (For the Developers)
- [x] **Core Functions**: ingest_files, search_embeddings, chat
- [x] **Type Hints**: Full typing support for happy IDEs
- [x] **Documentation**: Comprehensive docstrings
- [x] **Error Handling**: Proper exception management

### 🛠️ Model Configurations (The Brains)
- [x] **Gemma 3 1B**: Production-ready configuration
- [x] **Qwen3 Series**: 0.6B, 1.7B, and 4B variants
- [x] **Standardized Embedding**: nomic-embed-text across all configs
- [x] **Template Optimization**: Consistent prompt formatting

## 🔧 Recent Updates (What's Been Happening)

### Dynamic Model & Parameter Control (The Flexible Stuff)
- **Model Discovery**: Live fetching of available Ollama models
- **Hot Swapping**: Change models mid-conversation without restarting
- **Parameter Tweaking**: Adjust temperature, tokens, and other settings on the fly
- **Session State**: Tracks conversation and settings across the chat session
- **Rich Display**: Pretty tables showing model details and parameters
- **Real-time Config**: All settings can be changed while chatting
- **Status Monitoring**: See current configuration with `/status` command

### New Chat Commands (The Interactive Goodies)
- ✅ `/models` - List all available Ollama models with details
- ✅ `/model <n>` - Switch to a different chat model instantly  
- ✅ `/temp <0.0-2.0>` - Adjust response creativity/randomness
- ✅ `/tokens <1-8192>` - Change maximum response length
- ✅ `/topk <1-20>` - Modify document retrieval count
- ✅ `/topp <0.0-1.0>` - Adjust nucleus sampling parameter
- ✅ `/penalty <0.0-2.0>` - Change repetition penalty
- ✅ `/status` - Display current model and parameter configuration
- ✅ `/commands` - Show all available chat commands

### CLI Enhancements (The Command Line Love)
- ✅ `llamaline models` - Dedicated model management command
- ✅ `llamaline models <n>` - Show specific model details
- ✅ `llamaline models --format json|plain` - Different output formats
- ✅ `llamaline chat --list-models` - List models from chat command
- ✅ `llamaline chat -c <model>` - Specify chat model directly
- ✅ `llamaline chat --temperature <0.0-2.0>` - Set temperature from CLI
- ✅ `llamaline chat --max-tokens <1-8192>` - Set max tokens from CLI
- ✅ Various parameter flags for direct CLI control

## 🚧 What's Still on the TODO List

### High Priority (The Must-Haves)
- [ ] **PyPI Publication**: Get this baby onto PyPI for easy installation
- [ ] **CI/CD Pipeline**: GitHub Actions for automated testing and publishing
- [ ] **Documentation Site**: Proper docs hosting (MkDocs or Sphinx)
- [ ] **Package Name Fix**: Update any remaining references from llamaball to llamaline

### Medium Priority (The Should-Haves)
- [ ] **Testing Suite**: Comprehensive unit and integration tests
- [ ] **Performance Tuning**: Batch processing and intelligent caching
- [ ] **Advanced Search**: Filtering, faceted search, metadata queries
- [ ] **Export Features**: Save conversations, export search results

### Low Priority (The Nice-to-Haves)
- [ ] **Plugin System**: Extensible file type support
- [ ] **Web Interface**: Optional web UI for GUI lovers
- [ ] **Analytics**: Usage metrics and search patterns (local only!)
- [ ] **Cloud Sync**: Optional backup/sync capabilities (with explicit consent)

### Technical Improvements (The Under-the-Hood Stuff)
- [ ] **Configuration Management**: Centralized config system
- [ ] **Logging Improvements**: Structured logging with proper levels
- [ ] **Memory Optimization**: More efficient embedding storage and retrieval
- [ ] **Error Recovery**: Even better graceful failure handling

## 🔧 Current Configuration (The Settings)

### Default Settings (What You Get Out of the Box)
- **Database**: `.clai.db` (SQLite file in your working directory)
- **Embedding Model**: `nomic-embed-text:latest`
- **Chat Model**: `llama3.2:1b` (configurable via CHAT_MODEL env var)
- **Provider**: `ollama` (local inference only)
- **Top-K Retrieval**: 3 documents per query
- **Max Tokens**: 8191 per chunk

### Environment Variables (The Tweakable Bits)
- `CHAT_MODEL`: Your preferred chat model
- `OLLAMA_ENDPOINT`: Where Ollama lives (default: http://localhost:11434)
- `LLAMALINE_DB`: Database file location
- `LLAMALINE_LOG_LEVEL`: How chatty the logs should be

## 📋 What You Need to Run This Thing

### Dependencies (The Required Stuff)
- **Python**: 3.8+ (we've tested on 3.11)
- **Core Packages**: typer[all], rich, ollama, numpy, tiktoken
- **UI Packages**: prompt_toolkit, markdown-it-py
- **External**: Ollama server for model inference

### System Requirements (The Hardware Stuff)
- **Memory**: 4GB minimum, 8GB+ recommended for larger models
- **Storage**: 2GB for package + models (varies by model size)
- **OS**: macOS, Linux, Windows (with WSL for best experience)

## 🎨 Design Principles (Our North Star)

### Accessibility First (Non-Negotiable)
1. **Screen Reader Friendship**: Semantic markup everywhere
2. **Keyboard Mastery**: No mouse required for any feature
3. **Clear Information Architecture**: Consistent command structure
4. **Helpful Feedback**: Error messages that actually help solve problems

### Local Privacy (Our Promise)
1. **No Phone Home**: All processing happens on your machine
2. **Data Sovereignty**: You own and control all your data
3. **Transparent Processing**: Clear indication of what data gets used
4. **Secure by Default**: No telemetry, no usage tracking, no surprise data collection

### Developer Experience (Because We Care)
1. **Self-Documenting**: Code includes purpose and I/O in file headers
2. **Type Safety**: Full type hints for excellent IDE support
3. **Consistent API**: Predictable function signatures and return values
4. **Extensible Design**: Architecture that welcomes plugins and extensions

## 🧪 Testing Strategy (Quality Assurance)

### Unit Tests (The Foundation) - TODO
- Core functionality: embedding generation, search, chat
- CLI command parsing and validation
- Database operations and data integrity
- Error handling and edge case management

### Integration Tests (The Real World) - TODO
- End-to-end ingestion workflows
- Chat session management and persistence
- Multi-model compatibility testing
- Performance benchmarks and load testing

### Accessibility Tests (The Important Stuff) - TODO
- Screen reader compatibility verification
- Keyboard navigation testing
- Color contrast validation
- Text-to-speech friendliness

## 📈 How We Measure Success

### Technical Metrics (The Numbers)
- **Ingestion Speed**: Documents processed per second
- **Search Accuracy**: Relevant results in top-K retrievals
- **Response Time**: Chat latency and overall throughput
- **Memory Efficiency**: RAM usage during operations

### User Experience Metrics (The Human Stuff)
- **Accessibility Score**: Screen reader compatibility rating
- **Documentation Quality**: Help completeness and clarity
- **Error Recovery**: Graceful failure handling effectiveness
- **Setup Time**: Time from install to first successful chat

### Adoption Metrics (The Community)
- **Package Downloads**: PyPI installation statistics
- **Community Feedback**: GitHub issues and feature requests
- **Documentation Usage**: README and help command access patterns
- **Integration Examples**: Third-party usage and extensions

## 🔄 Release Planning (The Roadmap)

### v0.1.0 (Package Distribution Ready) - CURRENT
- ✅ Core package functionality working
- ✅ Rich CLI interface with accessibility features
- ✅ Dynamic model control and parameter adjustment
- ✅ Modern packaging (pyproject.toml)
- ✅ Clean repository organization
- ✅ Comprehensive documentation
- [ ] PyPI publication

### v0.1.1 (Polish & Distribution) - NEXT
- [ ] CI/CD pipeline setup
- [ ] Test coverage improvements
- [ ] Documentation site deployment
- [ ] Performance optimizations
- [ ] Bug fixes from initial feedback

### v0.2.0 (Feature Expansion) - FUTURE
- [ ] Advanced search capabilities
- [ ] Export and import functionality
- [ ] Plugin architecture foundation
- [ ] Enhanced error handling and recovery

### v1.0.0 (Production Ready) - LONG TERM
- [ ] Comprehensive testing coverage
- [ ] Full accessibility certification
- [ ] Performance benchmarking
- [ ] Enterprise-ready features

## 🤝 Contributing Guidelines (Join the Fun)

### Code Standards (The Rules)
1. **Accessibility**: If it doesn't work with a screen reader, it doesn't ship
2. **Documentation**: Every function needs docstrings, type hints, and purpose comments
3. **Testing**: New features require corresponding tests (no exceptions)
4. **Consistency**: Follow established patterns and conventions

### Review Process (Quality Control)
1. **Technical Review**: Code quality and architecture assessment
2. **Accessibility Review**: Screen reader and keyboard testing
3. **Documentation Review**: Help text and README updates
4. **Performance Review**: Memory and speed impact evaluation

## 📜 Legal and Attribution

**MIT License** by Luke Steuber  
- Website: lukesteuber.com, assisted.site  
- Email: luke@lukesteuber.com  
- Bluesky: @lukesteuber.com  
- LinkedIn: https://www.linkedin.com/in/lukesteuber/  
- GitHub: lukeslp  

### Support the Project
- 💰 [Tip jar](https://usefulai.lemonsqueezy.com/buy/bf6ce1bd-85f5-4a09-ba10-191a670f74af) - Coffee fuel for late-night coding  
- 📖 [Substack](https://lukesteuber.substack.com/) - Project updates and insights  

---

**🎯 Mission**: Build the most accessible, privacy-focused document chat system that doesn't make you want to throw your computer out the window. We're proving that local AI can be both powerful and actually usable by everyone.

**🌟 Vision**: A world where talking to your documents is as natural as talking to a friend, where privacy is protected by default, and where accessibility isn't an afterthought but a core feature.

*Built with ❤️ by humans who believe technology should serve people, not the other way around.* 