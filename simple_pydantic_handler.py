import yaml
import json
from typing import Dict, Any, Optional, List, Union
from pathlib import Path
from enum import Enum
from pydantic import BaseModel, Field, ConfigDict


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
    """Model cho Custom Property"""
    model_config = ConfigDict(extra='allow')
    
    PropertyKind: PropertyKind = Field(..., description="Loại property")
    DisplayName: str = Field(..., description="Tên hiển thị")
    Description: str = Field(..., description="Mô tả property")
    DataType: Optional[DataType] = Field(None, description="Kiểu dữ liệu")
    Default: str = Field(default="", description="Giá trị mặc định")
    ReturnType: Optional[str] = Field(None, description="Return type cho Event")


class ComponentProperties(BaseModel):
    """Model cho Component Properties"""
    model_config = ConfigDict(extra='allow')
    
    Height: str = Field(default="=App.Height", description="Chiều cao component")
    Width: str = Field(default="=App.Width", description="Chiều rộng component")


class ComponentDefinition(BaseModel):
    """Model cho Component Definition"""
    model_config = ConfigDict(extra='allow')
    
    DefinitionType: str = Field(default="CanvasComponent")
    CustomProperties: Dict[str, CustomProperty] = Field(default_factory=dict)
    Properties: ComponentProperties = Field(default_factory=ComponentProperties)
    Children: List[Dict[str, Any]] = Field(default_factory=list)


class PowerAppYAML(BaseModel):
    """Model chính cho PowerApp YAML"""
    model_config = ConfigDict(extra='allow')
    
    ComponentDefinitions: Optional[Dict[str, ComponentDefinition]] = Field(None)
    Screens: Optional[Dict[str, Any]] = Field(None)


class SimplePydanticYAMLHandler:
    """Simplified Pydantic-based YAML Handler cho Power App components"""
    
    def __init__(self, data: Optional[PowerAppYAML] = None):
        self.data = data
        
    def load_from_file(self, file_path: str) -> 'SimplePydanticYAMLHandler':
        """Load YAML data từ file với validation"""
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                raw_data = yaml.safe_load(file)
                self.data = PowerAppYAML.model_validate(raw_data)
            print(f"✅ Đã load và validate thành công từ: {file_path}")
            return self
        except Exception as e:
            print(f"❌ Lỗi khi load/validate file: {e}")
            return self
            
    def load_from_string(self, yaml_string: str) -> 'SimplePydanticYAMLHandler':
        """Load YAML data từ string với validation"""
        try:
            raw_data = yaml.safe_load(yaml_string)
            self.data = PowerAppYAML.model_validate(raw_data)
            print("✅ Đã load và validate thành công từ string")
            return self
        except Exception as e:
            print(f"❌ Lỗi khi parse/validate YAML: {e}")
            return self
            
    def save_to_file(self, file_path: str) -> bool:
        """Save YAML data ra file"""
        if not self.data:
            print("❌ Không có data để save")
            return False
            
        try:
            # Convert Pydantic model về dict, loại bỏ None values
            data_dict = self.data.model_dump(exclude_none=True, by_alias=True)
            
            with open(file_path, 'w', encoding='utf-8') as file:
                yaml.dump(data_dict, file, default_flow_style=False, 
                         allow_unicode=True, sort_keys=False, indent=2)
            print(f"✅ Đã save thành công ra: {file_path}")
            return True
        except Exception as e:
            print(f"❌ Lỗi khi save file: {e}")
            return False
            
    def to_yaml_string(self) -> str:
        """Convert data thành YAML string"""
        if not self.data:
            return ""
            
        try:
            data_dict = self.data.model_dump(exclude_none=True, by_alias=True)
            return yaml.dump(data_dict, default_flow_style=False, 
                           allow_unicode=True, sort_keys=False, indent=2)
        except Exception as e:
            print(f"❌ Lỗi khi convert sang YAML: {e}")
            return ""
            
    def to_json_string(self) -> str:
        """Convert data thành JSON string"""
        if not self.data:
            return ""
            
        try:
            return self.data.model_dump_json(exclude_none=True, indent=2)
        except Exception as e:
            print(f"❌ Lỗi khi convert sang JSON: {e}")
            return ""
            
    def get_component_info(self) -> Dict[str, Any]:
        """Lấy thông tin component từ validated data"""
        if not self.data or not self.data.ComponentDefinitions:
            return {'error': 'Không có ComponentDefinitions'}
            
        components = self.data.ComponentDefinitions
        return {
            'components': list(components.keys()),
            'total_components': len(components),
            'structure': {name: self._get_component_structure(comp) 
                         for name, comp in components.items()}
        }
        
    def _get_component_structure(self, component: ComponentDefinition) -> Dict[str, Any]:
        """Phân tích cấu trúc của component"""
        structure = {
            'type': component.DefinitionType,
            'custom_properties': len(component.CustomProperties),
            'children': len(component.Children)
        }
        
        if component.CustomProperties:
            structure['property_types'] = {}
            structure['property_kinds'] = {}
            
            for prop_name, prop_data in component.CustomProperties.items():
                # Count by DataType
                if prop_data.DataType:
                    data_type = prop_data.DataType.value
                    if data_type not in structure['property_types']:
                        structure['property_types'][data_type] = 0
                    structure['property_types'][data_type] += 1
                
                # Count by PropertyKind
                kind = prop_data.PropertyKind.value
                if kind not in structure['property_kinds']:
                    structure['property_kinds'][kind] = 0
                structure['property_kinds'][kind] += 1
                
        return structure
        
    def create_sample_button_component(self) -> 'SimplePydanticYAMLHandler':
        """Tạo sample ButtonComponent với Pydantic models"""
        
        # Create custom properties
        custom_props = {
            "Text": CustomProperty(
                PropertyKind=PropertyKind.INPUT,
                DisplayName="Text",
                Description="Text hiển thị trên button",
                DataType=DataType.TEXT,
                Default='="Button"'
            ),
            "Variant": CustomProperty(
                PropertyKind=PropertyKind.INPUT,
                DisplayName="Variant", 
                Description="Loại button: Primary, Secondary, Danger",
                DataType=DataType.TEXT,
                Default='="Primary"'
            ),
            "IsDisabled": CustomProperty(
                PropertyKind=PropertyKind.INPUT,
                DisplayName="IsDisabled",
                Description="Button bị disable",
                DataType=DataType.BOOLEAN,
                Default="=false"
            ),
            "OnClick": CustomProperty(
                PropertyKind=PropertyKind.EVENT,
                DisplayName="OnClick",
                Description="Sự kiện khi click button",
                ReturnType="None",
                Default="=false"
            )
        }
        
        # Create button control as dict (không dùng strict typing để tránh lỗi)
        button_control = {
            "Control": "Classic/Button",
            "Properties": {
                "X": "=Parent.X",
                "Y": "=Parent.Y", 
                "Width": "=Parent.Width * 0.16",
                "Height": "=Parent.Height * 0.055",
                "Text": "=SampleButtonComponent.Text",
                "Fill": "=RGBA(227, 242, 253, 1)",
                "Color": "=RGBA(33, 150, 243, 1)",
                "OnSelect": "=SampleButtonComponent.OnClick()"
            }
        }
        
        # Create component definition
        component_def = ComponentDefinition(
            DefinitionType="CanvasComponent",
            CustomProperties=custom_props,
            Properties=ComponentProperties(),
            Children=[{"Button.Container": button_control}]
        )
        
        # Create PowerApp YAML
        power_app = PowerAppYAML(
            ComponentDefinitions={"SampleButtonComponent": component_def}
        )
        
        self.data = power_app
        print("✅ Đã tạo sample ButtonComponent với Simple Pydantic")
        return self
        
    def validate_component_structure(self) -> Dict[str, Any]:
        """Validate cấu trúc component theo Power App rules"""
        if not self.data or not self.data.ComponentDefinitions:
            return {'valid': False, 'errors': ['Không có ComponentDefinitions']}
            
        errors = []
        warnings = []
        
        for comp_name, component in self.data.ComponentDefinitions.items():
            # Check DefinitionType
            if component.DefinitionType != "CanvasComponent":
                errors.append(f"{comp_name}: DefinitionType phải là 'CanvasComponent'")
            
            # Check CustomProperties
            for prop_name, prop in component.CustomProperties.items():
                if prop.PropertyKind == PropertyKind.EVENT:
                    if prop.DataType:
                        warnings.append(f"{comp_name}.{prop_name}: Event không nên có DataType")
                    if not prop.ReturnType:
                        warnings.append(f"{comp_name}.{prop_name}: Event nên có ReturnType")
                else:
                    if not prop.DataType:
                        errors.append(f"{comp_name}.{prop_name}: Input/Output phải có DataType")
            
            # Check Children controls - simple validation
            for child_dict in component.Children:
                for child_name, child_control in child_dict.items():
                    if isinstance(child_control, dict):
                        if not child_control.get('Control'):
                            errors.append(f"{comp_name}.{child_name}: Thiếu Control type")
                        
                        # Check positioning
                        props = child_control.get('Properties', {})
                        required_props = ['X', 'Y', 'Width', 'Height']
                        missing_props = [p for p in required_props if not props.get(p)]
                        if missing_props:
                            warnings.append(f"{comp_name}.{child_name}: Thiếu properties: {missing_props}")
        
        return {
            'valid': len(errors) == 0,
            'errors': errors,
            'warnings': warnings,
            'total_errors': len(errors),
            'total_warnings': len(warnings)
        }
    
    def create_from_template(self, template_name: str = "basic_button") -> 'SimplePydanticYAMLHandler':
        """Tạo component từ template có sẵn với triple quotes"""
        
        templates = {
            "basic_button": """
ComponentDefinitions:
  BasicButtonComponent:
    DefinitionType: CanvasComponent
    CustomProperties:
      Text:
        PropertyKind: Input
        DisplayName: Text
        Description: "Text hiển thị trên button"
        DataType: Text
        Default: ="Click me"
      OnClick:
        PropertyKind: Event
        DisplayName: OnClick
        Description: "Sự kiện khi click button"
        ReturnType: None
        Default: =false
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
            Text: =BasicButtonComponent.Text
            Fill: =RGBA(33, 150, 243, 1)
            Color: =RGBA(255, 255, 255, 1)
            OnSelect: =BasicButtonComponent.OnClick()
""",
            "input_field": """
ComponentDefinitions:
  InputFieldComponent:
    DefinitionType: CanvasComponent
    CustomProperties:
      Placeholder:
        PropertyKind: Input
        DisplayName: Placeholder
        Description: "Placeholder text"
        DataType: Text
        Default: ="Enter text..."
      Value:
        PropertyKind: Input
        DisplayName: Value
        Description: "Input value"
        DataType: Text
        Default: =""
      OnChange:
        PropertyKind: Event
        DisplayName: OnChange
        Description: "Sự kiện khi giá trị thay đổi"
        ReturnType: None
        Default: =false
    Properties:
      Height: =App.Height
      Width: =App.Width
    Children:
      - 'Input.Field':
          Control: Classic/TextInput
          Properties:
            X: =Parent.X
            Y: =Parent.Y
            Width: =Parent.Width * 0.3
            Height: =Parent.Height * 0.05
            HintText: =InputFieldComponent.Placeholder
            Default: =InputFieldComponent.Value
            OnChange: =InputFieldComponent.OnChange()
"""
        }
        
        if template_name not in templates:
            print(f"❌ Template '{template_name}' không tồn tại")
            available_templates = list(templates.keys())
            print(f"Available templates: {available_templates}")
            return self
            
        return self.load_from_string(templates[template_name])
    
    def get_raw_data(self) -> Dict[str, Any]:
        """Lấy raw data để debug"""
        if self.data:
            return self.data.model_dump(exclude_none=True)
        return {}
        
    def __str__(self) -> str:
        """String representation"""
        if self.data and self.data.ComponentDefinitions:
            total = len(self.data.ComponentDefinitions)
            return f"SimplePydanticYAMLHandler - Components: {total} (Validated)"
        return "SimplePydanticYAMLHandler - Empty"
        
    def __repr__(self) -> str:
        return self.__str__()


# Test function
def test_simple_pydantic_yaml_handler():
    """Test Simple Pydantic YAML Handler"""
    print("🧪 Testing SimplePydanticYAMLHandler...")
    
    # Test 1: Tạo sample component
    print("\n1. Tạo sample component với Simple Pydantic:")
    handler = SimplePydanticYAMLHandler().create_sample_button_component()
    print(handler)
    
    # Test 2: Validation
    print("\n2. Validate component structure:")
    validation = handler.validate_component_structure()
    print(json.dumps(validation, indent=2, ensure_ascii=False))
    
    # Test 3: Thông tin component
    print("\n3. Thông tin component:")
    info = handler.get_component_info()
    print(json.dumps(info, indent=2, ensure_ascii=False))
    
    # Test 4: Export YAML
    print("\n4. Export YAML:")
    yaml_output = handler.to_yaml_string()
    print(yaml_output[:400] + "..." if len(yaml_output) > 400 else yaml_output)
    
    # Test 5: Save to file
    print("\n5. Save to file:")
    handler.save_to_file("simple_pydantic_test_output.yaml")
    
    # Test 6: Template test
    print("\n6. Test template:")
    template_handler = SimplePydanticYAMLHandler().create_from_template("basic_button")
    print(template_handler)
    template_handler.save_to_file("simple_template_test_output.yaml")
    
    # Test 7: Load file gốc
    print("\n7. Load và validate ButtonComponent.yaml:")
    try:
        original_handler = SimplePydanticYAMLHandler().load_from_file("src/Components/ButtonComponent.yaml")
        print(original_handler)
        validation = original_handler.validate_component_structure()
        print(f"Validation result: {validation['valid']} - Errors: {validation['total_errors']}, Warnings: {validation['total_warnings']}")
        if validation['errors']:
            print("Errors:", validation['errors'][:2])  # Show first 2 errors
        if validation['warnings']:
            print("Warnings:", validation['warnings'][:2])  # Show first 2 warnings
    except Exception as e:
        print(f"❌ Lỗi validation: {e}")
    
    return handler


if __name__ == "__main__":
    test_simple_pydantic_yaml_handler() 