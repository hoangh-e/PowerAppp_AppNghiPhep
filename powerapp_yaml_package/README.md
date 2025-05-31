# PowerApp YAML

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
