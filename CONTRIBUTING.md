# Contributing to Llamaball

Thank you for your interest in contributing to Llamaball! This guide will help you get started.

## 🎯 Project Philosophy

Llamaball is built with **accessibility and local privacy** as core principles. All contributions should align with these values:

- **Accessibility First**: Every feature must work with screen readers and keyboard navigation
- **Local Privacy**: All processing happens locally, no data leaves the user's machine
- **Developer-Friendly**: Code should be self-documenting with comprehensive type hints

## 🚀 Quick Start

### Development Setup

```bash
# Clone the repository
git clone https://github.com/lsteuber/llamaball.git
cd llamaball

# Create a virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install in development mode
pip install -e .[dev]

# Install pre-commit hooks
pre-commit install
```

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=llamaball --cov-report=html

# Run specific test file
pytest tests/test_core.py -v
```

### Code Quality

```bash
# Format code
black llamaball/
isort llamaball/

# Type checking
mypy llamaball/

# Run all quality checks
pre-commit run --all-files
```

## 📝 Development Guidelines

### Code Style

- **Python Version**: Support Python 3.8+
- **Formatting**: Use `black` with 88-character line length
- **Import Sorting**: Use `isort` with black profile
- **Type Hints**: All functions must have type hints
- **Docstrings**: Use Google-style docstrings

### Accessibility Requirements

1. **Screen Reader Support**: Use semantic markup in CLI output
2. **Keyboard Navigation**: No mouse-dependent features
3. **Clear Information Architecture**: Consistent command structure
4. **Descriptive Feedback**: Rich error messages and help text

### Documentation Standards

```python
def example_function(param: str, optional: bool = False) -> dict:
    """Brief description of what the function does.
    
    Args:
        param: Description of the parameter
        optional: Description of optional parameter
        
    Returns:
        Dictionary containing the result
        
    Raises:
        ValueError: When param is invalid
    """
    pass
```

## 🔧 Making Changes

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

### 2. Make Your Changes

- Write code following the guidelines above
- Add tests for new functionality
- Update documentation as needed
- Ensure accessibility compliance

### 3. Test Your Changes

```bash
# Run tests
pytest

# Test CLI functionality
llamaball --help
llamaball ingest test_data/
llamaball chat

# Test accessibility (if possible)
# Use screen reader or keyboard-only navigation
```

### 4. Commit Your Changes

```bash
# Stage your changes
git add .

# Commit with descriptive message
git commit -m "feat: add new search functionality"

# Push to your branch
git push origin feature/your-feature-name
```

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

## 🐛 Reporting Issues

### Bug Reports

When reporting bugs, please include:

1. **Environment**: OS, Python version, Ollama version
2. **Steps to Reproduce**: Clear, numbered steps
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happened
5. **Error Messages**: Full error output
6. **Accessibility Impact**: Does this affect screen readers?

### Feature Requests

For feature requests, please describe:

1. **Use Case**: Why is this feature needed?
2. **Accessibility Considerations**: How will this work with assistive technology?
3. **Privacy Impact**: Does this maintain local-only processing?
4. **Proposed Implementation**: Any ideas for how to implement it?

## 🎨 Accessibility Testing

### Screen Reader Testing

If you have access to screen readers, please test:

- NVDA (Windows)
- JAWS (Windows)
- VoiceOver (macOS)
- Orca (Linux)

### Keyboard Navigation Testing

- Test all functionality using only keyboard
- Ensure tab order is logical
- Verify all interactive elements are reachable

### Color and Contrast

- Ensure good contrast in terminal output
- Don't rely solely on color to convey information
- Test with high contrast themes

## 📋 Pull Request Process

1. **Fork** the repository
2. **Create** a feature branch
3. **Make** your changes following the guidelines
4. **Test** thoroughly including accessibility
5. **Submit** a pull request with:
   - Clear description of changes
   - Reference to related issues
   - Screenshots/demos if applicable
   - Accessibility testing results

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

## Testing
- [ ] Tests pass
- [ ] Manual testing completed
- [ ] Accessibility testing completed

## Accessibility Checklist
- [ ] Screen reader compatible
- [ ] Keyboard navigation works
- [ ] High contrast compatible
- [ ] Clear error messages

## Documentation
- [ ] Docstrings updated
- [ ] README updated if needed
- [ ] CHANGELOG updated
```

## 🏆 Recognition

Contributors will be recognized in:

- README.md acknowledgments
- CHANGELOG.md for significant contributions
- GitHub contributors list

## 📞 Getting Help

- **Issues**: Open a GitHub issue for bugs or questions
- **Discussions**: Use GitHub Discussions for general questions
- **Email**: Contact maintainers for security issues

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for helping make Llamaball better! 🦙✨ 