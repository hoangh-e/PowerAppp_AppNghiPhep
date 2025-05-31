#!/usr/bin/env python3
"""
Script để implement package structure cho PowerApp YAML handlers.
Tự động tạo cấu trúc package và di chuyển code hiện tại.
"""

import os
import shutil
from pathlib import Path


def create_package_structure():
    """Tạo cấu trúc package directory"""
    
    base_dir = Path("powerapp_yaml_package")
    
    # Định nghĩa cấu trúc thư mục
    directories = [
        # Main package
        "powerapp_yaml",
        "powerapp_yaml/core",
        "powerapp_yaml/models", 
        "powerapp_yaml/validation",
        "powerapp_yaml/templates",
        "powerapp_yaml/templates/basic",
        "powerapp_yaml/templates/advanced",
        "powerapp_yaml/utils",
        
        # Tests
        "tests",
        "tests/test_core",
        "tests/test_models", 
        "tests/test_validation",
        "tests/test_templates",
        "tests/fixtures",
        "tests/fixtures/sample_components",
        "tests/fixtures/expected_outputs",
        "tests/performance",
        
        # Examples
        "examples",
        
        # Documentation
        "docs",
        "docs/api",
        "docs/guides", 
        "docs/examples",
        
        # Scripts
        "scripts",
        
        # CI/CD
        ".github",
        ".github/workflows"
    ]
    
    print("🚀 Tạo cấu trúc package...")
    
    # Tạo thư mục chính
    base_dir.mkdir(exist_ok=True)
    
    # Tạo tất cả thư mục con
    for directory in directories:
        dir_path = base_dir / directory
        dir_path.mkdir(parents=True, exist_ok=True)
        print(f"   ✅ Created: {dir_path}")
    
    return base_dir


def create_init_files(base_dir):
    """Tạo các file __init__.py"""
    
    init_files = [
        "powerapp_yaml/__init__.py",
        "powerapp_yaml/core/__init__.py",
        "powerapp_yaml/models/__init__.py",
        "powerapp_yaml/validation/__init__.py", 
        "powerapp_yaml/templates/__init__.py",
        "powerapp_yaml/templates/basic/__init__.py",
        "powerapp_yaml/templates/advanced/__init__.py",
        "powerapp_yaml/utils/__init__.py",
        "tests/__init__.py",
        "tests/test_core/__init__.py",
        "tests/test_models/__init__.py",
        "tests/test_validation/__init__.py",
        "tests/test_templates/__init__.py",
        "tests/performance/__init__.py",
        "examples/__init__.py"
    ]
    
    print("\n📝 Tạo __init__.py files...")
    
    for init_file in init_files:
        file_path = base_dir / init_file
        
        if "powerapp_yaml/__init__.py" in init_file:
            # Main package init
            content = '''"""PowerApp YAML - Professional YAML handler for Power App components."""

__version__ = "1.0.0"
__author__ = "PowerApp YAML Team"
__email__ = "team@powerapp-yaml.com"

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
'''
        else:
            # Standard empty init
            content = f'"""Module: {init_file.replace("/__init__.py", "").replace("/", ".")}"""'
        
        file_path.write_text(content, encoding="utf-8")
        print(f"   ✅ Created: {file_path}")


def migrate_existing_code(base_dir):
    """Di chuyển code hiện tại vào package structure"""
    
    print("\n🔄 Migrating existing code...")
    
    # Mapping files hiện tại -> vị trí mới
    file_migrations = {
        "final_yaml_handler.py": "powerapp_yaml/core/advanced_handler.py",
        "yaml_handler.py": "powerapp_yaml/core/yaml_handler.py",
        "demo_comparison.py": "examples/comparison_demo.py"
    }
    
    for source_file, target_file in file_migrations.items():
        if Path(source_file).exists():
            source_path = Path(source_file)
            target_path = base_dir / target_file
            
            # Copy content và modify imports if needed
            content = source_path.read_text(encoding="utf-8")
            
            # Update imports for new package structure
            if "advanced_handler.py" in target_file:
                content = content.replace(
                    "class FinalYAMLHandler:",
                    "class AdvancedYAMLHandler:"
                )
                content = content.replace(
                    "FinalYAMLHandler",
                    "AdvancedYAMLHandler"
                )
            
            target_path.write_text(content, encoding="utf-8")
            print(f"   ✅ Migrated: {source_file} -> {target_file}")
        else:
            print(f"   ⚠️  Not found: {source_file}")


def create_new_modules(base_dir):
    """Tạo các module mới cho package"""
    
    print("\n⚡ Creating new modules...")
    
    # 1. Enums module
    enums_content = '''"""Enums for PowerApp YAML components."""

from enum import Enum


class PropertyKind(str, Enum):
    """Enum cho PropertyKind"""
    INPUT = "Input"
    OUTPUT = "Output"
    EVENT = "Event"


class DataType(str, Enum):
    """Enum cho DataType"""
    TEXT = "Text"
    NUMBER = "Number"
    BOOLEAN = "Boolean"
    DATE_TIME = "Date and time"
    SCREEN = "Screen"
    RECORD = "Record"
    TABLE = "Table"
    IMAGE = "Image"
    VIDEO_AUDIO = "Video or audio"
    COLOR = "Color"
    CURRENCY = "Currency"


class ControlType(str, Enum):
    """Enum cho Control Types"""
    LABEL = "Label"
    BUTTON = "Classic/Button"
    TEXT_INPUT = "Classic/TextInput"
    RECTANGLE = "Rectangle"
    GROUP_CONTAINER = "GroupContainer"
    GALLERY = "Gallery"
    ICON = "Classic/Icon"
    IMAGE = "Image"
'''
    
    (base_dir / "powerapp_yaml/models/enums.py").write_text(enums_content, encoding="utf-8")
    print("   ✅ Created: enums.py")
    
    # 2. Base handler
    base_handler_content = '''"""Abstract base class for YAML handlers."""

from abc import ABC, abstractmethod
from typing import Dict, Any, Optional


class BaseYAMLHandler(ABC):
    """Abstract base class for all YAML handlers."""
    
    def __init__(self, data: Optional[Any] = None):
        self.data = data
    
    @abstractmethod
    def load_from_file(self, file_path: str) -> 'BaseYAMLHandler':
        """Load YAML data from file."""
        pass
    
    @abstractmethod
    def load_from_string(self, yaml_string: str) -> 'BaseYAMLHandler':
        """Load YAML data from string."""
        pass
    
    @abstractmethod
    def save_to_file(self, file_path: str) -> bool:
        """Save YAML data to file."""
        pass
    
    @abstractmethod
    def to_yaml_string(self) -> str:
        """Convert data to YAML string."""
        pass
    
    @abstractmethod
    def get_component_info(self) -> Dict[str, Any]:
        """Get component information."""
        pass
'''
    
    (base_dir / "powerapp_yaml/core/base_handler.py").write_text(base_handler_content, encoding="utf-8")
    print("   ✅ Created: base_handler.py")
    
    # 3. Template builder
    template_builder_content = '''"""Template builder for PowerApp components."""

from typing import Dict, Any, List, Optional
from ..models.enums import PropertyKind, DataType


class TemplateBuilder:
    """Builder class for creating PowerApp component templates."""
    
    def __init__(self):
        self.templates = {}
    
    def create_button_template(
        self,
        text_property: bool = True,
        variant_property: bool = True,
        on_click_event: bool = True
    ) -> str:
        """Create a button component template."""
        
        template = """
ComponentDefinitions:
  ButtonComponent:
    DefinitionType: CanvasComponent
    CustomProperties:"""
        
        if text_property:
            template += """
      Text:
        PropertyKind: Input
        DisplayName: Text
        Description: "Button text"
        DataType: Text
        Default: ="Click me" """
        
        if variant_property:
            template += """
      Variant:
        PropertyKind: Input
        DisplayName: Variant
        Description: "Button variant: Primary, Secondary, Danger"
        DataType: Text
        Default: ="Primary" """
        
        if on_click_event:
            template += """
      OnClick:
        PropertyKind: Event
        DisplayName: OnClick
        Description: "Button click event"
        ReturnType: None
        Default: =false """
        
        template += """
    Properties:
      Height: =App.Height
      Width: =App.Width
    Children:
      - 'Button.Main':
          Control: Classic/Button
          Properties:
            X: =Parent.X
            Y: =Parent.Y
            Width: =Parent.Width * 0.2
            Height: =Parent.Height * 0.06
            Text: =ButtonComponent.Text
            Fill: =RGBA(33, 150, 243, 1)
            Color: =RGBA(255, 255, 255, 1)
            OnSelect: =ButtonComponent.OnClick()
"""
        
        return template
    
    def create_card_template(
        self,
        title_property: bool = True,
        content_property: bool = True,
        actions: Optional[List[str]] = None
    ) -> str:
        """Create a card layout template."""
        
        actions = actions or []
        
        template = """
ComponentDefinitions:
  CardComponent:
    DefinitionType: CanvasComponent
    CustomProperties:"""
        
        if title_property:
            template += """
      Title:
        PropertyKind: Input
        DisplayName: Title
        Description: "Card title"
        DataType: Text
        Default: ="Card Title" """
        
        if content_property:
            template += """
      Content:
        PropertyKind: Input
        DisplayName: Content
        Description: "Card content"
        DataType: Text
        Default: ="Card content goes here..." """
        
        for action in actions:
            template += f"""
      On{action.capitalize()}:
        PropertyKind: Event
        DisplayName: On{action.capitalize()}
        Description: "{action.capitalize()} action event"
        ReturnType: None
        Default: =false """
        
        template += """
    Properties:
      Height: =App.Height
      Width: =App.Width
    Children:
      - 'Card.Container':
          Control: Rectangle
          Properties:
            X: =Parent.X
            Y: =Parent.Y
            Width: =Parent.Width * 0.4
            Height: =Parent.Height * 0.3
            Fill: =RGBA(255, 255, 255, 1)
            BorderColor: =RGBA(230, 230, 230, 1)
            BorderThickness: =1
            BorderRadius: =8
"""
        
        return template
'''
    
    (base_dir / "powerapp_yaml/templates/builder.py").write_text(template_builder_content, encoding="utf-8")
    print("   ✅ Created: template_builder.py")
    
    # 4. Validators
    validators_content = '''"""Validators for PowerApp components."""

from typing import Dict, Any, List
from dataclasses import dataclass
from ..models.enums import PropertyKind


@dataclass
class ValidationResult:
    """Result of component validation."""
    is_valid: bool
    errors: List[str]
    warnings: List[str]
    
    @property
    def total_errors(self) -> int:
        return len(self.errors)
    
    @property
    def total_warnings(self) -> int:
        return len(self.warnings)


class ComponentValidator:
    """Validator for PowerApp component structure."""
    
    def validate(self, data: Any) -> ValidationResult:
        """Validate component data structure."""
        errors = []
        warnings = []
        
        if not data:
            errors.append("No data provided")
            return ValidationResult(False, errors, warnings)
        
        # Convert to dict if needed
        if hasattr(data, 'to_dict'):
            data_dict = data.to_dict()
        elif hasattr(data, '__dict__'):
            data_dict = data.__dict__
        else:
            data_dict = data
        
        # Validate ComponentDefinitions
        if 'ComponentDefinitions' not in data_dict and 'component_definitions' not in data_dict:
            errors.append("Missing ComponentDefinitions")
            return ValidationResult(False, errors, warnings)
        
        # Get component definitions
        components = data_dict.get('ComponentDefinitions') or data_dict.get('component_definitions', {})
        
        for comp_name, component in components.items():
            comp_errors, comp_warnings = self._validate_component(comp_name, component)
            errors.extend(comp_errors)
            warnings.extend(comp_warnings)
        
        is_valid = len(errors) == 0
        return ValidationResult(is_valid, errors, warnings)
    
    def _validate_component(self, name: str, component: Any) -> tuple:
        """Validate individual component."""
        errors = []
        warnings = []
        
        # Convert to dict if needed
        if hasattr(component, 'to_dict'):
            comp_dict = component.to_dict()
        elif hasattr(component, '__dict__'):
            comp_dict = component.__dict__
        else:
            comp_dict = component
        
        # Check DefinitionType
        def_type = comp_dict.get('DefinitionType') or comp_dict.get('definition_type')
        if def_type != "CanvasComponent":
            errors.append(f"{name}: DefinitionType must be 'CanvasComponent'")
        
        # Check CustomProperties
        custom_props = comp_dict.get('CustomProperties') or comp_dict.get('custom_properties', {})
        for prop_name, prop_data in custom_props.items():
            prop_errors, prop_warnings = self._validate_property(name, prop_name, prop_data)
            errors.extend(prop_errors)
            warnings.extend(prop_warnings)
        
        return errors, warnings
    
    def _validate_property(self, comp_name: str, prop_name: str, prop_data: Any) -> tuple:
        """Validate custom property."""
        errors = []
        warnings = []
        
        # Convert to dict if needed
        if hasattr(prop_data, 'to_dict'):
            prop_dict = prop_data.to_dict()
        elif hasattr(prop_data, '__dict__'):
            prop_dict = prop_data.__dict__
        else:
            prop_dict = prop_data
        
        property_kind = prop_dict.get('PropertyKind') or prop_dict.get('property_kind')
        data_type = prop_dict.get('DataType') or prop_dict.get('data_type')
        return_type = prop_dict.get('ReturnType') or prop_dict.get('return_type')
        
        if property_kind == PropertyKind.EVENT.value:
            if data_type:
                warnings.append(f"{comp_name}.{prop_name}: Event properties should not have DataType")
            if not return_type:
                warnings.append(f"{comp_name}.{prop_name}: Event properties should have ReturnType")
        else:
            if not data_type:
                errors.append(f"{comp_name}.{prop_name}: Input/Output properties must have DataType")
        
        return errors, warnings
'''
    
    (base_dir / "powerapp_yaml/validation/validators.py").write_text(validators_content, encoding="utf-8")
    print("   ✅ Created: validators.py")


def create_config_files(base_dir):
    """Tạo các file configuration"""
    
    print("\n⚙️  Creating configuration files...")
    
    # 1. setup.py
    setup_py_content = '''from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open("requirements.txt", "r", encoding="utf-8") as fh:
    requirements = [line.strip() for line in fh if line.strip() and not line.startswith("#")]

setup(
    name="powerapp-yaml",
    version="1.0.0",
    author="PowerApp YAML Team",
    author_email="team@powerapp-yaml.com",
    description="Professional YAML handler for Power App components",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/powerapp/powerapp-yaml",
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
        "dev": ["pytest>=6.0", "black", "flake8", "mypy", "pre-commit"],
        "docs": ["mkdocs", "mkdocs-material", "mkdocs-autoapi"],
        "test": ["pytest", "pytest-cov", "pytest-benchmark", "coverage"],
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
'''
    
    (base_dir / "setup.py").write_text(setup_py_content, encoding="utf-8")
    print("   ✅ Created: setup.py")
    
    # 2. requirements.txt
    requirements_content = '''pyyaml>=6.0
typing-extensions>=4.0.0; python_version<"3.10"
'''
    
    (base_dir / "requirements.txt").write_text(requirements_content, encoding="utf-8")
    print("   ✅ Created: requirements.txt")
    
    # 3. pyproject.toml
    pyproject_content = '''[build-system]
requires = ["setuptools>=45", "wheel", "setuptools_scm[toml]>=6.2"]
build-backend = "setuptools.build_meta"

[project]
name = "powerapp-yaml"
dynamic = ["version"]
description = "Professional YAML handler for Power App components"
readme = "README.md"
license = {file = "LICENSE"}
authors = [{name = "PowerApp YAML Team", email = "team@powerapp-yaml.com"}]
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
Homepage = "https://github.com/powerapp/powerapp-yaml"
Documentation = "https://powerapp-yaml.readthedocs.io/"
Repository = "https://github.com/powerapp/powerapp-yaml"
"Bug Tracker" = "https://github.com/powerapp/powerapp-yaml/issues"

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
'''
    
    (base_dir / "pyproject.toml").write_text(pyproject_content, encoding="utf-8")
    print("   ✅ Created: pyproject.toml")
    
    # 4. README.md
    readme_content = '''# PowerApp YAML

Professional YAML handler for Power App components with validation, templates, and type safety.

## Features

- ✅ Type-safe YAML handling with dataclasses
- ✅ Built-in Power App component validation
- ✅ Template system for common components
- ✅ Multiple export formats (YAML, JSON)
- ✅ Performance optimized
- ✅ Extensible architecture

## Quick Start

```python
from powerapp_yaml import YAMLHandler

# Create handler
handler = YAMLHandler()

# Create from template
handler.create_from_template("basic_button")

# Save to file
handler.save_to_file("my_button.yaml")

# Validate
validation = handler.validate_component_structure()
print(f"Valid: {validation.is_valid}")
```

## Installation

```bash
pip install powerapp-yaml
```

## Documentation

See [docs/](docs/) for comprehensive documentation.

## License

MIT License - see LICENSE file for details.
'''
    
    (base_dir / "README.md").write_text(readme_content, encoding="utf-8")
    print("   ✅ Created: README.md")


def create_example_files(base_dir):
    """Tạo các file example"""
    
    print("\n📚 Creating example files...")
    
    # Basic usage example
    basic_example = '''#!/usr/bin/env python3
"""Basic usage example for PowerApp YAML."""

from powerapp_yaml import YAMLHandler

def main():
    """Basic usage demonstration."""
    
    # Create handler
    handler = YAMLHandler()
    print("Created handler:", handler)
    
    # Create from template
    handler.create_from_template("basic_button")
    print("Created from template")
    
    # Get component info
    info = handler.get_component_info()
    print(f"Components: {info['total_components']}")
    
    # Save to file
    handler.save_to_file("example_button.yaml")
    print("Saved to file")
    
    # Convert to JSON
    json_output = handler.to_json_string()
    print(f"JSON length: {len(json_output)} characters")

if __name__ == "__main__":
    main()
'''
    
    (base_dir / "examples/basic_usage.py").write_text(basic_example, encoding="utf-8")
    print("   ✅ Created: basic_usage.py")
    
    # Advanced example
    advanced_example = '''#!/usr/bin/env python3
"""Advanced usage example for PowerApp YAML."""

from powerapp_yaml import AdvancedYAMLHandler, TemplateBuilder, ComponentValidator

def main():
    """Advanced usage demonstration."""
    
    # Template builder
    builder = TemplateBuilder()
    template = builder.create_card_template(
        title_property=True,
        content_property=True,
        actions=["save", "cancel"]
    )
    
    # Load template
    handler = AdvancedYAMLHandler()
    handler.load_from_string(template)
    print("Loaded custom template")
    
    # Validate
    validator = ComponentValidator()
    result = validator.validate(handler.data)
    print(f"Validation: {result.is_valid}")
    print(f"Errors: {result.total_errors}")
    print(f"Warnings: {result.total_warnings}")
    
    # Export multiple formats
    handler.save_to_file("advanced_card.yaml")
    
    json_output = handler.to_json_string()
    with open("advanced_card.json", "w", encoding="utf-8") as f:
        f.write(json_output)
    
    print("Exported to YAML and JSON")

if __name__ == "__main__":
    main()
'''
    
    (base_dir / "examples/advanced_usage.py").write_text(advanced_example, encoding="utf-8")
    print("   ✅ Created: advanced_usage.py")


def create_test_files(base_dir):
    """Tạo các file test cơ bản"""
    
    print("\n🧪 Creating test files...")
    
    # Test for advanced handler
    test_advanced = '''"""Tests for AdvancedYAMLHandler."""

import pytest
from powerapp_yaml.core.advanced_handler import AdvancedYAMLHandler


class TestAdvancedYAMLHandler:
    """Test cases for AdvancedYAMLHandler."""
    
    def test_creation(self):
        """Test handler creation."""
        handler = AdvancedYAMLHandler()
        assert handler is not None
        assert handler.data is None
    
    def test_sample_component(self):
        """Test sample component creation."""
        handler = AdvancedYAMLHandler()
        handler.create_sample_button_component()
        
        assert handler.data is not None
        info = handler.get_component_info()
        assert info['total_components'] == 1
        assert 'SampleButtonComponent' in info['components']
    
    def test_yaml_export(self):
        """Test YAML export."""
        handler = AdvancedYAMLHandler()
        handler.create_sample_button_component()
        
        yaml_output = handler.to_yaml_string()
        assert len(yaml_output) > 0
        assert 'ComponentDefinitions' in yaml_output
    
    def test_validation(self):
        """Test component validation."""
        handler = AdvancedYAMLHandler()
        handler.create_sample_button_component()
        
        validation = handler.validate_component_structure()
        assert validation['valid'] is True
        assert validation['total_errors'] == 0
'''
    
    (base_dir / "tests/test_core/test_advanced_handler.py").write_text(test_advanced, encoding="utf-8")
    print("   ✅ Created: test_advanced_handler.py")
    
    # Test configuration
    conftest = '''"""Pytest configuration and fixtures."""

import pytest
from pathlib import Path


@pytest.fixture
def sample_yaml_data():
    """Sample YAML data for testing."""
    return """
ComponentDefinitions:
  TestComponent:
    DefinitionType: CanvasComponent
    CustomProperties:
      TestProperty:
        PropertyKind: Input
        DisplayName: TestProperty
        Description: "Test property"
        DataType: Text
        Default: ="Test"
    Properties:
      Height: =App.Height
      Width: =App.Width
    Children: []
"""


@pytest.fixture
def temp_yaml_file(tmp_path, sample_yaml_data):
    """Create temporary YAML file for testing."""
    file_path = tmp_path / "test.yaml"
    file_path.write_text(sample_yaml_data, encoding="utf-8")
    return file_path
'''
    
    (base_dir / "tests/conftest.py").write_text(conftest, encoding="utf-8")
    print("   ✅ Created: conftest.py")


def main():
    """Main function để implement package structure"""
    
    print("🎉 POWERAPP YAML PACKAGE IMPLEMENTATION")
    print("=" * 50)
    
    # 1. Tạo cấu trúc thư mục
    base_dir = create_package_structure()
    
    # 2. Tạo __init__.py files
    create_init_files(base_dir)
    
    # 3. Di chuyển code hiện tại
    migrate_existing_code(base_dir)
    
    # 4. Tạo modules mới
    create_new_modules(base_dir)
    
    # 5. Tạo config files
    create_config_files(base_dir)
    
    # 6. Tạo examples
    create_example_files(base_dir)
    
    # 7. Tạo tests
    create_test_files(base_dir)
    
    print("\n🎯 PACKAGE IMPLEMENTATION COMPLETED!")
    print("=" * 50)
    print(f"📁 Package created in: {base_dir.absolute()}")
    print("\n🚀 Next steps:")
    print("1. cd powerapp_yaml_package")
    print("2. pip install -e .")
    print("3. python examples/basic_usage.py")
    print("4. pytest tests/")
    print("5. python -c 'from powerapp_yaml import YAMLHandler; print(\"Success!\")'")
    
    return base_dir


if __name__ == "__main__":
    main() 