"""Pydantic-based YAML handler for PowerApp components."""

import yaml
import json
from typing import Dict, Any, Optional
from pathlib import Path
from datetime import datetime

from ..models.pydantic_models import (
    PowerAppYAML, 
    ComponentDefinition, 
    CustomProperty,
    ComponentProperties,
    PropertyKind,
    DataType,
    ValidationResult
)


class PydanticYAMLHandler:
    """Pydantic-based YAML handler với validation và type safety."""
    
    def __init__(self, data: Optional[PowerAppYAML] = None):
        self.data = data
        self.created_at = datetime.now().isoformat()
    
    def load_from_file(self, file_path: str) -> 'PydanticYAMLHandler':
        """Load YAML data từ file với Pydantic validation."""
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                yaml_data = yaml.safe_load(file)
            
            # Parse với Pydantic validation
            self.data = PowerAppYAML.model_validate(yaml_data)
            print(f"✅ Pydantic: Đã load và validate thành công từ: {file_path}")
            return self
        except Exception as e:
            print(f"❌ Pydantic: Lỗi khi load file: {e}")
            return self
            
    def load_from_string(self, yaml_string: str) -> 'PydanticYAMLHandler':
        """Load YAML data từ string với Pydantic validation."""
        try:
            yaml_data = yaml.safe_load(yaml_string)
            self.data = PowerAppYAML.model_validate(yaml_data)
            print("✅ Pydantic: Đã load và validate thành công từ string")
            return self
        except Exception as e:
            print(f"❌ Pydantic: Lỗi khi parse YAML: {e}")
            return self
            
    def save_to_file(self, file_path: str) -> bool:
        """Save YAML data ra file."""
        try:
            if not self.data:
                raise ValueError("No data to save")
                
            # Convert Pydantic model to dict với alias
            export_data = self.data.model_dump(by_alias=True)
            
            with open(file_path, 'w', encoding='utf-8') as file:
                yaml.dump(export_data, file, default_flow_style=False, 
                         allow_unicode=True, sort_keys=False, indent=2)
            print(f"✅ Pydantic: Đã save thành công ra: {file_path}")
            return True
        except Exception as e:
            print(f"❌ Pydantic: Lỗi khi save file: {e}")
            return False
            
    def to_yaml_string(self) -> str:
        """Convert data thành YAML string."""
        try:
            if not self.data:
                return ""
            export_data = self.data.model_dump(by_alias=True)
            return yaml.dump(export_data, default_flow_style=False, 
                           allow_unicode=True, sort_keys=False, indent=2)
        except Exception as e:
            print(f"❌ Pydantic: Lỗi khi convert sang YAML: {e}")
            return ""
            
    def to_json_string(self, indent: int = 2) -> str:
        """Convert data thành JSON string."""
        try:
            if not self.data:
                return ""
            return self.data.model_dump_json(by_alias=True, indent=indent)
        except Exception as e:
            print(f"❌ Pydantic: Lỗi khi convert sang JSON: {e}")
            return ""
            
    def get_component_info(self) -> Dict[str, Any]:
        """Lấy thông tin component với Pydantic data."""
        if not self.data:
            return {'error': 'No data loaded'}
            
        components = self.data.component_definitions
        return {
            'components': list(components.keys()),
            'total_components': len(components),
            'structure': {name: self._get_component_structure(comp) 
                         for name, comp in components.items()}
        }
        
    def _get_component_structure(self, component: ComponentDefinition) -> Dict[str, Any]:
        """Phân tích cấu trúc của component với Pydantic."""
        structure = {
            'type': component.definition_type,
            'custom_properties': len(component.custom_properties),
            'children': len(component.children)
        }
        
        # Phân tích property types
        structure['property_types'] = {}
        for prop_name, prop_data in component.custom_properties.items():
            if prop_data.data_type:
                prop_type = prop_data.data_type.value
                structure['property_types'][prop_type] = structure['property_types'].get(prop_type, 0) + 1
                
        return structure
        
    def create_sample_button_component(self) -> 'PydanticYAMLHandler':
        """Tạo sample component với Pydantic models."""
        
        # Tạo custom properties
        text_prop = CustomProperty(
            PropertyKind="Input",
            DisplayName="Text",
            Description="Text hiển thị trên button",
            DataType="Text",
            Default="=\"Button\""
        )
        
        onclick_prop = CustomProperty(
            PropertyKind="Event",
            DisplayName="OnClick",
            Description="Sự kiện khi click button",
            ReturnType="None",
            Default="=false"
        )
        
        # Tạo component properties
        props = ComponentProperties(
            Height="=App.Height",
            Width="=App.Width"
        )
        
        # Tạo component definition
        component = ComponentDefinition(
            DefinitionType="CanvasComponent",
            CustomProperties={
                "Text": text_prop,
                "OnClick": onclick_prop
            },
            Properties=props,
            Children=[{
                "Button.Main": {
                    "Control": "Classic/Button",
                    "Properties": {
                        "X": "=Parent.X",
                        "Y": "=Parent.Y",
                        "Width": "=Parent.Width * 0.2",
                        "Height": "=Parent.Height * 0.06",
                        "Text": "=SampleButtonComponent.Text",
                        "Fill": "=RGBA(33, 150, 243, 1)",
                        "Color": "=RGBA(255, 255, 255, 1)",
                        "OnSelect": "=SampleButtonComponent.OnClick()"
                    }
                }
            }]
        )
        
        # Tạo PowerApp YAML
        self.data = PowerAppYAML(
            ComponentDefinitions={
                "SampleButtonComponent": component
            }
        )
        
        print("✅ Pydantic: Đã tạo sample ButtonComponent với Pydantic models")
        return self
        
    def validate_component_structure(self) -> ValidationResult:
        """Validate component structure với Pydantic."""
        if not self.data:
            return ValidationResult(
                is_valid=False,
                errors=["No data to validate"],
                warnings=[]
            )
        
        errors = []
        warnings = []
        
        for comp_name, component in self.data.component_definitions.items():
            # Validate DefinitionType
            if component.definition_type != "CanvasComponent":
                errors.append(f"{comp_name}: DefinitionType must be 'CanvasComponent'")
            
            # Validate custom properties
            for prop_name, prop_data in component.custom_properties.items():
                if prop_data.property_kind == PropertyKind.EVENT:
                    if prop_data.data_type:
                        warnings.append(f"{comp_name}.{prop_name}: Event properties should not have DataType")
                    if not prop_data.return_type:
                        warnings.append(f"{comp_name}.{prop_name}: Event properties should have ReturnType")
                else:
                    if not prop_data.data_type:
                        errors.append(f"{comp_name}.{prop_name}: Input/Output properties must have DataType")
        
        return ValidationResult(
            is_valid=len(errors) == 0,
            errors=errors,
            warnings=warnings
        )
        
    def get_stats(self) -> Dict[str, Any]:
        """Lấy thống kê handler."""
        return {
            'handler_type': 'PydanticYAMLHandler',
            'created_at': self.created_at,
            'has_data': self.data is not None,
            'data_valid': self.data is not None,
            'pydantic_version': '2.x'
        }
        
    def __str__(self) -> str:
        """String representation."""
        if self.data:
            info = self.get_component_info()
            return f"PydanticYAMLHandler - Components: {info.get('total_components', 0)}"
        return "PydanticYAMLHandler - Empty"
        
    def __repr__(self) -> str:
        return self.__str__() 