"""Validators for PowerApp components."""

from typing import Dict, Any, List, Tuple
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
        errors: List[str] = []
        warnings: List[str] = []
        
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
    
    def _validate_component(self, name: str, component: Any) -> Tuple[List[str], List[str]]:
        """Validate individual component."""
        errors: List[str] = []
        warnings: List[str] = []
        
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
    
    def _validate_property(self, comp_name: str, prop_name: str, prop_data: Any) -> Tuple[List[str], List[str]]:
        """Validate custom property."""
        errors: List[str] = []
        warnings: List[str] = []
        
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
