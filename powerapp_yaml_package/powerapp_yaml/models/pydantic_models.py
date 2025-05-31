"""Pydantic models for PowerApp YAML components."""

from typing import Dict, Any, List, Optional, Union
from pydantic import BaseModel, Field, ConfigDict
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


class CustomProperty(BaseModel):
    """Pydantic model for custom property."""
    model_config = ConfigDict(
        str_strip_whitespace=True,
        validate_assignment=True,
        extra='forbid'
    )
    
    property_kind: PropertyKind = Field(alias="PropertyKind")
    display_name: str = Field(alias="DisplayName")
    description: str = Field(alias="Description")
    default: str = Field(alias="Default")
    data_type: Optional[DataType] = Field(default=None, alias="DataType")
    return_type: Optional[str] = Field(default=None, alias="ReturnType")
    parameters: Optional[Dict[str, Any]] = Field(default=None, alias="Parameters")


class ComponentProperties(BaseModel):
    """Pydantic model for component properties."""
    model_config = ConfigDict(extra='allow')  # Allow Height, Width, etc.
    
    height: str = Field(alias="Height", default="=App.Height")
    width: str = Field(alias="Width", default="=App.Width")


class ComponentDefinition(BaseModel):
    """Pydantic model for component definition."""
    model_config = ConfigDict(
        validate_assignment=True,
        extra='forbid'
    )
    
    definition_type: str = Field(alias="DefinitionType")
    custom_properties: Dict[str, CustomProperty] = Field(alias="CustomProperties")
    properties: ComponentProperties = Field(alias="Properties")
    children: List[Dict[str, Any]] = Field(default_factory=list, alias="Children")


class PowerAppYAML(BaseModel):
    """Pydantic model for PowerApp YAML structure."""
    model_config = ConfigDict(
        validate_assignment=True,
        extra='forbid'
    )
    
    component_definitions: Dict[str, ComponentDefinition] = Field(alias="ComponentDefinitions")


class ValidationResult(BaseModel):
    """Pydantic model for validation result."""
    model_config = ConfigDict(
        frozen=True  # Immutable result
    )
    
    is_valid: bool
    errors: List[str] = Field(default_factory=list)
    warnings: List[str] = Field(default_factory=list)
    
    @property
    def total_errors(self) -> int:
        return len(self.errors)
    
    @property
    def total_warnings(self) -> int:
        return len(self.warnings) 