"""PowerApp YAML - Professional YAML handler for Power App components."""

__version__ = "1.0.0"
__author__ = "PowerApp YAML Team"
__email__ = "team@powerapp-yaml.com"

from .core.advanced_handler import AdvancedYAMLHandler
from .core.yaml_handler import YAMLHandler as BasicYAMLHandler
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
