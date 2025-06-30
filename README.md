# 🦙 Llamaline

**Your friendly neighborhood accessible document chat companion - because talking to your files should be as easy as talking to your best friend!**

[![PyPI version](https://badge.fury.io/py/llamaline.svg)](https://badge.fury.io/py/llamaline)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

*A delightfully accessible toolkit for chatting with your documents, powered by local AI and built with love for everyone who believes privacy and usability should go hand in hand.*

## 🌟 What Makes Llamaline Special?

Llamaline isn't just another document chat tool - it's your personal AI librarian that actually cares about accessibility! Built from the ground up to work beautifully with screen readers, keyboard navigation, and a terminal interface that doesn't make you want to pull your hair out.

### ✨ The Good Stuff

- **🏠 Everything Stays Home**: Your documents never leave your machine. We're not interested in your data, promise!
- **♿ Accessibility Champion**: Screen readers welcome! Keyboard warriors rejoice! We actually tested this stuff.
- **🖥️ Terminal That Doesn't Suck**: Beautiful CLI that gives you real-time feedback without the bloat
- **📚 Smart Document Whisperer**: Knows how to break up your docs into chunks that actually make sense
- **🔍 Find Stuff Fast**: Vector search that gets you the right answers, not just random matches
- **💬 Chat Like a Human**: Natural conversations with your documents - no robot speak required
- **📊 Know Your Data**: See what's in your database without squinting at raw SQL
- **🎛️ Change Your Mind**: Switch models and tweak settings mid-conversation like the indecisive genius you are
- **🔧 Developer Happy**: Full Python API with type hints because we respect your IDE

## 🚀 Getting Started (The Actually Easy Way)

### Prerequisites - The Boring But Necessary Stuff

You'll need [Ollama](https://ollama.ai/) running on your machine. Don't worry, it's easier than assembling IKEA furniture:

1. Grab Ollama from [ollama.ai](https://ollama.ai/)
2. Pull some models (these are good starting points):
   ```bash
   ollama pull llama3.2:1b        # Fast and nimble
   ollama pull nomic-embed-text   # The embedding wizard
   ```

### Installation - One Command and You're Done

```bash
# The standard way
pip install llamaline

# If you want to tinker under the hood
pip install llamaline[dev]
```

### First Steps - Let's Make Some Magic

```bash
# Teach llamaline about your documents
llamaline ingest .

# Start chatting with your files
llamaline chat

# See what you've got
llamaline stats

# Need help? We've got you covered
llamaline --help
```

## 🎮 Command Central

### Document Wrangling

```bash
# Ingest everything in a folder (with style)
llamaline ingest ./docs --recursive --exclude "*.tmp,*.log"

# Force rebuild everything (when you're feeling destructive)
llamaline ingest ./docs --force

# See what you've accomplished
llamaline stats --format table

# Find specific files
llamaline list --search "python" --sort-by size
```

### Chat Time

```bash
# Start with your favorite model
llamaline chat --model llama3.2:3b

# Be specific about what you want
llamaline chat --temperature 0.1 --max-tokens 200

# Debug mode (for when things get weird)
llamaline chat --debug
```

### Model Management

```bash
# See what models you've got
llamaline models

# Get the details on a specific model
llamaline models llama3.2:1b

# JSON output (because sometimes you need data, not pretty tables)
llamaline models --format json
```

## 🗣️ Chat Commands That Actually Make Sense

Once you're in chat mode, these commands are your new best friends:

- `/models` - Show me what I can play with
- `/model <name>` - Switch to a different brain
- `/temp <0.0-2.0>` - Make it more creative (or less crazy)
- `/tokens <1-8192>` - How much can it say at once?
- `/topk <1-20>` - How many documents should it consider?
- `/status` - What's happening right now?
- `/help` - I forgot what I'm doing
- `/exit` - Time to touch grass

## 🐍 Python API (For the Code-Inclined)

```python
from llamaline import core

# Feed it your documents
core.ingest_files("./docs", recursive=True, exclude_patterns=["*.tmp"])

# Find relevant stuff  
results = core.search_embeddings(query="what is this about?", top_k=5)

# Have a conversation
response = core.chat(
    user_input="Explain this like I'm 5", 
    history=[],
    model="llama3.2:1b"
)

# Get the stats (knowledge is power)
stats = core.get_stats()
print(f"You've got {stats['total_files']} files indexed!")
```

## ⚙️ Configuration (Make It Yours)

### Environment Variables (The Tweakable Bits)

- `CHAT_MODEL`: Your go-to chat model (default: `llama3.2:1b`)
- `OLLAMA_ENDPOINT`: Where Ollama lives (default: `http://localhost:11434`)
- `LLAMALINE_DB`: Where to keep your database (default: `.clai.db`)
- `LLAMALINE_LOG_LEVEL`: How chatty should the logs be? (default: `INFO`)

### File Types We're Friends With

- **Text Files**: `.txt`, `.md`, `.rst` - the classics
- **Code**: `.py`, `.js`, `.html`, `.css`, `.json` - we speak developer
- **Data**: `.csv`, `.tsv` - spreadsheet refugees welcome
- **Documents**: `.pdf` - coming soon to a release near you!

## ♿ Accessibility - We Actually Mean It

- **Screen Reader BFFs**: Proper semantic markup throughout
- **Keyboard Masters**: Everything works without touching a mouse
- **High Contrast**: Terminal output that doesn't hurt your eyes
- **Clear Communication**: Error messages that actually help
- **Progress Updates**: Know what's happening in real-time
- **Consistent Patterns**: Learn once, use everywhere

## 🛠️ For the Tinkerers

### Development Setup

```bash
# Get the source
git clone https://github.com/lukeslp/llamaline.git
cd llamaline

# Install for hacking
pip install -e .[dev]

# Set up the pre-commit hooks
pre-commit install
```

### Testing (Because Breaking Things Is Fun)

```bash
# Run the tests
pytest

# See how much you've covered
pytest --cov=llamaline --cov-report=html

# Check your types
mypy llamaline/

# Make it pretty
black llamaline/
isort llamaline/
```

## 📁 What's In The Box

```
doc_chat_ai/
├── llamaline/              # The main package
│   ├── __init__.py         # Package setup and public API
│   ├── cli.py              # Command-line interface magic
│   ├── core.py             # The RAG engine that makes it all work
│   ├── utils.py            # Helper functions and utilities
│   └── __main__.py         # Makes `python -m llamaline` work
├── models/                 # Ollama model configurations
├── tests/                  # Test suite (because bugs are not features)
├── archive/                # Old stuff we can't bear to delete
├── pyproject.toml          # Modern Python packaging
├── CHANGELOG.md            # What changed and when
├── README.md               # You are here!
└── PROJECT_PLAN.md         # The master plan
```

## 🔒 Privacy & Security (The Important Stuff)

- **Local First**: Your data never calls home
- **No Snooping**: We don't collect usage data because that's creepy
- **You're In Control**: Your machine, your models, your data
- **Transparent**: Open source means no hidden surprises

## 🤝 Want to Help Out?

We love contributors! Check out [CONTRIBUTING.md](CONTRIBUTING.md) for the details, but here are the highlights:

1. **Accessibility Matters**: If it doesn't work with a screen reader, it doesn't ship
2. **Document Everything**: Future you will thank present you
3. **Test Your Stuff**: New features need tests (your future debugger will thank you)
4. **Keep It Consistent**: Follow the patterns we've established

## 📜 The Legal Bits

MIT License by Luke Steuber (lukesteuber.com, assisted.site)
- Email: luke@lukesteuber.com
- Bluesky: @lukesteuber.com
- LinkedIn: https://www.linkedin.com/in/lukesteuber/
- GitHub: lukeslp

See [LICENSE](LICENSE) for the full legal text.

## 🙏 Props and Thanks

- Built on [Ollama](https://ollama.ai/) for keeping AI local and awesome
- Powered by [Typer](https://typer.tiangolo.com/) and [Rich](https://rich.readthedocs.io/) for CLI excellence
- Inspired by the belief that accessible software is better software

## 💡 Support the Project

Love what we're building? Consider:
- 🌟 Starring the repo
- 🐛 Reporting bugs (they're free!)
- 💰 [Tip jar](https://usefulai.lemonsqueezy.com/buy/bf6ce1bd-85f5-4a09-ba10-191a670f74af) for coffee fuel
- 📖 [Substack](https://lukesteuber.substack.com/) for project updates

---

**🎯 Mission**: Build the most accessible, privacy-focused document chat system that doesn't make you want to throw your computer out the window. We're here to prove that local AI can be both powerful and actually usable by everyone.

*Built with ❤️ by humans who believe technology should serve people, not the other way around.*
