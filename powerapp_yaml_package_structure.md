# PowerApp YAML Package Structure

## 📦 Recommended Package Structure

```
powerapp-yaml/
├── powerapp_yaml/                  # Main package directory
│   ├── __init__.py                # Package initialization
│   ├── core/                      # Core handlers
│   │   ├── __init__.py
│   │   ├── base_handler.py        # Abstract base class
│   │   ├── yaml_handler.py        # Basic YAML handler
│   │   └── advanced_handler.py    # Advanced dataclass handler
│   ├── models/                    # Data models
│   │   ├── __init__.py
│   │   ├── enums.py              # PropertyKind, DataType enums
│   │   ├── properties.py         # CustomProperty, ComponentProperties
│   │   └── components.py         # ComponentDefinition, PowerAppYAML
│   ├── validation/                # Validation modules
│   │   ├── __init__.py
│   │   ├── rules.py              # Power App validation rules
│   │   └── validators.py         # Validation logic
│   ├── templates/                 # Component templates
│   │   ├── __init__.py
│   │   ├── basic/                # Basic templates
│   │   │   ├── __init__.py
│   │   │   ├── button.py
│   │   │   ├── input.py
│   │   │   └── label.py
│   │   ├── advanced/             # Advanced templates
│   │   │   ├── __init__.py
│   │   │   ├── card.py
│   │   │   ├── form.py
│   │   │   └── navigation.py
│   │   └── builder.py            # Template builder
│   ├── utils/                     # Utility functions
│   │   ├── __init__.py
│   │   ├── file_ops.py           # File operations
│   │   ├── formatters.py         # YAML/JSON formatters
│   │   └── helpers.py            # Helper functions
│   └── exceptions.py              # Custom exceptions
├── tests/                         # Test modules
│   ├── __init__.py
│   ├── conftest.py               # Pytest configuration
│   ├── test_core/                # Core handler tests
│   │   ├── __init__.py
│   │   ├── test_yaml_handler.py
│   │   └── test_advanced_handler.py
│   ├── test_models/              # Model tests
│   │   ├── __init__.py
│   │   ├── test_properties.py
│   │   └── test_components.py
│   ├── test_validation/          # Validation tests
│   │   ├── __init__.py
│   │   └── test_validators.py
│   ├── test_templates/           # Template tests
│   │   ├── __init__.py
│   │   └── test_builder.py
│   ├── fixtures/                 # Test fixtures
│   │   ├── sample_components/
│   │   │   ├── button.yaml
│   │   │   ├── input.yaml
│   │   │   └── complex.yaml
│   │   └── expected_outputs/
│   └── performance/              # Performance tests
│       ├── __init__.py
│       └── test_benchmarks.py
├── examples/                      # Usage examples
│   ├── __init__.py
│   ├── basic_usage.py
│   ├── advanced_usage.py
│   ├── template_generation.py
│   ├── validation_example.py
│   └── migration_guide.py
├── docs/                          # Documentation
│   ├── api/                      # API documentation
│   │   ├── core.md
│   │   ├── models.md
│   │   ├── validation.md
│   │   └── templates.md
│   ├── guides/                   # User guides
│   │   ├── getting_started.md
│   │   ├── power_app_rules.md
│   │   ├── template_creation.md
│   │   └── migration.md
│   ├── examples/                 # Example files
│   │   ├── basic_button.yaml
│   │   ├── complex_form.yaml
│   │   └── navigation_menu.yaml
│   └── README.md
├── scripts/                       # Utility scripts
│   ├── generate_templates.py
│   ├── validate_components.py
│   ├── convert_formats.py
│   └── performance_test.py
├── .github/                       # GitHub workflows
│   └── workflows/
│       ├── tests.yml
│       ├── publish.yml
│       └── docs.yml
├── setup.py                       # Package setup
├── setup.cfg                      # Setup configuration
├── pyproject.toml                 # Modern Python packaging
├── requirements.txt               # Runtime dependencies
├── requirements-dev.txt           # Development dependencies
├── requirements-test.txt          # Test dependencies
├── MANIFEST.in                    # Package manifest
├── README.md                      # Main README
├── CHANGELOG.md                   # Version history
├── LICENSE                        # License file
├── .gitignore                     # Git ignore
├── .pre-commit-config.yaml        # Pre-commit hooks
├── pytest.ini                     # Pytest configuration
├── tox.ini                        # Tox configuration
└── mkdocs.yml                     # Documentation configuration
```

## 🎯 Package Design Principles

### 1. Separation of Concerns
- **Core**: Main handler logic
- **Models**: Data structures and types
- **Validation**: Business rules validation
- **Templates**: Reusable component templates
- **Utils**: Helper and utility functions

### 2. Extensibility
- Abstract base classes for easy extension
- Plugin-style template system
- Configurable validation rules

### 3. Type Safety
- Type hints throughout codebase
- Dataclasses for structured data
- Enums for constrained values

### 4. Testing Strategy
- Unit tests for each module
- Integration tests for workflows
- Performance benchmarks
- Test fixtures for consistency

## 📋 Core Package Files

### powerapp_yaml/__init__.py
```python
"""PowerApp YAML - Professional YAML handler for Power App components."""

__version__ = "1.0.0"
__author__ = "Your Name"
__email__ = "your.email@domain.com"

from .core.advanced_handler import AdvancedYAMLHandler
from .core.yaml_handler import BasicYAMLHandler
from .models.enums import PropertyKind, DataType
from .templates.builder import TemplateBuilder
from .validation.validators import ComponentValidator

# Convenience imports
YAMLHandler = AdvancedYAMLHandler  # Default to advanced handler

__all__ = [
    "YAMLHandler",
    "AdvancedYAMLHandler", 
    "BasicYAMLHandler",
    "PropertyKind",
    "DataType",
    "TemplateBuilder",
    "ComponentValidator"
]
```

### setup.py
```python
from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open("requirements.txt", "r", encoding="utf-8") as fh:
    requirements = [line.strip() for line in fh if line.strip() and not line.startswith("#")]

setup(
    name="powerapp-yaml",
    version="1.0.0",
    author="Your Name",
    author_email="your.email@domain.com",
    description="Professional YAML handler for Power App components",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/powerapp-yaml",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "Topic :: Text Processing :: Markup",
    ],
    python_requires=">=3.8",
    install_requires=requirements,
    extras_require={
        "dev": ["pytest>=6.0", "black", "flake8", "mypy"],
        "docs": ["mkdocs", "mkdocs-material"],
        "test": ["pytest", "pytest-cov", "pytest-benchmark"],
    },
    entry_points={
        "console_scripts": [
            "powerapp-yaml=powerapp_yaml.cli:main",
        ],
    },
    include_package_data=True,
    package_data={
        "powerapp_yaml": ["templates/basic/*.yaml", "templates/advanced/*.yaml"],
    },
)
```

### pyproject.toml
```toml
[build-system]
requires = ["setuptools>=45", "wheel", "setuptools_scm[toml]>=6.2"]
build-backend = "setuptools.build_meta"

[project]
name = "powerapp-yaml"
dynamic = ["version"]
description = "Professional YAML handler for Power App components"
readme = "README.md"
license = {file = "LICENSE"}
authors = [{name = "Your Name", email = "your.email@domain.com"}]
classifiers = [
    "Development Status :: 5 - Production/Stable",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
]
requires-python = ">=3.8"
dependencies = [
    "pyyaml>=6.0",
    "typing-extensions>=4.0.0; python_version<'3.10'",
]

[project.optional-dependencies]
dev = ["pytest>=6.0", "black", "flake8", "mypy", "pre-commit"]
docs = ["mkdocs", "mkdocs-material", "mkdocs-autoapi"]
test = ["pytest", "pytest-cov", "pytest-benchmark", "coverage"]

[project.urls]
Homepage = "https://github.com/yourusername/powerapp-yaml"
Documentation = "https://powerapp-yaml.readthedocs.io/"
Repository = "https://github.com/yourusername/powerapp-yaml"
"Bug Tracker" = "https://github.com/yourusername/powerapp-yaml/issues"

[project.scripts]
powerapp-yaml = "powerapp_yaml.cli:main"

[tool.setuptools_scm]

[tool.black]
line-length = 88
target-version = ['py38']

[tool.isort]
profile = "black"

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "-v --cov=powerapp_yaml --cov-report=html --cov-report=term"

[tool.coverage.run]
source = ["powerapp_yaml"]
omit = ["*/tests/*", "*/test_*"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
]
```

## 🚀 Usage Examples

### Basic Usage
```python
from powerapp_yaml import YAMLHandler

# Simple component creation
handler = YAMLHandler()
handler.create_from_template("basic_button")
handler.save_to_file("my_button.yaml")
```

### Advanced Usage
```python
from powerapp_yaml import AdvancedYAMLHandler, TemplateBuilder, ComponentValidator

# Create custom template
builder = TemplateBuilder()
template = builder.create_card_template(
    title_property=True,
    content_property=True,
    actions=["save", "cancel"]
)

# Load and validate
handler = AdvancedYAMLHandler()
handler.load_from_string(template)

validator = ComponentValidator()
result = validator.validate(handler.data)
print(f"Valid: {result.is_valid}")
```

## 📦 Installation & Distribution

### Development Installation
```bash
# Clone repository
git clone https://github.com/yourusername/powerapp-yaml.git
cd powerapp-yaml

# Install in development mode
pip install -e .

# Install with dev dependencies
pip install -e ".[dev,test,docs]"
```

### Production Installation
```bash
# From PyPI (when published)
pip install powerapp-yaml

# From source
pip install git+https://github.com/yourusername/powerapp-yaml.git
```

### Building & Publishing
```bash
# Build package
python -m build

# Upload to TestPyPI
python -m twine upload --repository testpypi dist/*

# Upload to PyPI
python -m twine upload dist/*
```

## 🧪 Testing Strategy

### Test Structure
```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=powerapp_yaml

# Run performance tests
pytest tests/performance/

# Run specific test file
pytest tests/test_core/test_advanced_handler.py

# Run with specific markers
pytest -m "not slow"
```

### Continuous Integration
```yaml
# .github/workflows/tests.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.8", "3.9", "3.10", "3.11"]
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
    - name: Install dependencies
      run: |
        pip install -e ".[test]"
    - name: Run tests
      run: pytest
```

## 📚 Documentation Strategy

### API Documentation
- Auto-generated from docstrings
- Examples for each method
- Type annotations
- Usage patterns

### User Guides
- Getting started tutorial
- Power App component rules
- Template creation guide
- Migration from legacy handlers

### Examples Repository
- Real-world use cases
- Best practices
- Performance optimization
- Integration patterns

## 🎯 Benefits of This Structure

1. **Professional**: Follows Python packaging best practices
2. **Scalable**: Easy to add new features and modules
3. **Maintainable**: Clear separation of concerns
4. **Testable**: Comprehensive testing strategy
5. **Documented**: Multiple documentation layers
6. **Distributable**: Ready for PyPI publication
7. **CI/CD Ready**: GitHub Actions integration
8. **Type Safe**: Full type hint coverage
9. **Extensible**: Plugin architecture support
10. **Standards Compliant**: Follows PEP standards

## 🚀 Migration Path

1. **Phase 1**: Restructure existing code into package format
2. **Phase 2**: Add comprehensive tests and documentation
3. **Phase 3**: Implement CI/CD pipeline
4. **Phase 4**: Publish to PyPI
5. **Phase 5**: Add advanced features and plugins

This structure transforms your YAML handlers into a professional, distributable Python package ready for production use. 