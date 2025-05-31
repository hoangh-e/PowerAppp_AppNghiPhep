import yaml
import json
from typing import Dict, Any, Optional, List, Union, Literal, ForwardRef
from pathlib import Path
from enum import Enum
from pydantic import BaseModel, Field, field_validator, ConfigDict
from pydantic.alias_generators import to_camel


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


class ButtonVariant(str, Enum):
    """Enum cho Button Variant"""
    PRIMARY = "Primary"
    SECONDARY = "Secondary"
    DANGER = "Danger"
    GHOST = "Ghost"
    OUTLINE = "Outline"


class ButtonSize(str, Enum):
    """Enum cho Button Size"""
    SMALL = "Small"
    MEDIUM = "Medium"
    LARGE = "Large"


class EventParameter(BaseModel):
    """Model cho event parameters"""
    model_config = ConfigDict(extra='allow')
    
    Description: str = Field(..., description="Mô tả parameter")
    DataType: DataType = Field(..., description="Kiểu dữ liệu")
    IsOptional: bool = Field(default=True, description="Parameter có optional không")
    Default: str = Field(default="", description="Giá trị mặc định")


class CustomProperty(BaseModel):
    """Model cho Custom Property"""
    model_config = ConfigDict(extra='allow')
    
    PropertyKind: PropertyKind = Field(..., description="Loại property")
    DisplayName: str = Field(..., description="Tên hiển thị")
    Description: str = Field(..., description="Mô tả property")
    DataType: Optional[DataType] = Field(None, description="Kiểu dữ liệu (không có cho Event)")
    Default: str = Field(default="", description="Giá trị mặc định")
    ReturnType: Optional[str] = Field(None, description="Return type cho Event")
    Parameters: Optional[Dict[str, EventParameter]] = Field(None, description="Parameters cho Event")
    
    @field_validator('DataType')
    @classmethod
    def validate_data_type(cls, v, info):
        """Validate DataType dựa trên PropertyKind"""
        if info.data.get('PropertyKind') == PropertyKind.EVENT:
            if v is not None:
                raise ValueError("Event properties không nên có DataType")
        else:
            if v is None:
                raise ValueError("Input/Output properties phải có DataType")
        return v


class ControlProperties(BaseModel):
    """Model cho Control Properties"""
    model_config = ConfigDict(extra='allow')
    
    # Position và Size - Bắt buộc
    X: Optional[str] = Field(None, description="Vị trí X")
    Y: Optional[str] = Field(None, description="Vị trí Y")
    Width: Optional[str] = Field(None, description="Chiều rộng")
    Height: Optional[str] = Field(None, description="Chiều cao")
    
    # Visual Properties
    Fill: Optional[str] = Field(None, description="Màu nền")
    Color: Optional[str] = Field(None, description="Màu chữ")
    BorderColor: Optional[str] = Field(None, description="Màu viền")
    BorderThickness: Optional[str] = Field(None, description="Độ dày viền")
    BorderRadius: Optional[str] = Field(None, description="Bo góc")
    
    # Text Properties
    Text: Optional[str] = Field(None, description="Nội dung text")
    Font: Optional[str] = Field(None, description="Font chữ")
    FontWeight: Optional[str] = Field(None, description="Độ đậm chữ")
    Size: Optional[str] = Field(None, description="Kích thước chữ")
    
    # Behavior Properties
    OnSelect: Optional[str] = Field(None, description="Sự kiện click")
    OnChange: Optional[str] = Field(None, description="Sự kiện thay đổi")
    OnVisible: Optional[str] = Field(None, description="Sự kiện hiển thị")
    DisplayMode: Optional[str] = Field(None, description="Chế độ hiển thị")
    Visible: Optional[str] = Field(None, description="Hiển thị hay không")
    
    # Icon Properties
    Icon: Optional[str] = Field(None, description="Icon")
    
    # Các properties khác sẽ được lưu trong extra fields


class Control(BaseModel):
    """Model cho Control"""
    model_config = ConfigDict(extra='allow')
    
    Control: str = Field(..., description="Loại control")
    Variant: Optional[str] = Field(None, description="Biến thể của control")
    ComponentName: Optional[str] = Field(None, description="Tên component (cho CanvasComponent)")
    Properties: Optional[ControlProperties] = Field(None, description="Properties của control")
    Children: Optional[List[Dict[str, ForwardRef('Control')]]] = Field(None, description="Controls con")


class ComponentProperties(BaseModel):
    """Model cho Component Properties"""
    model_config = ConfigDict(extra='allow')
    
    Height: str = Field(default="=App.Height", description="Chiều cao component")
    Width: str = Field(default="=App.Width", description="Chiều rộng component")


class ComponentDefinition(BaseModel):
    """Model cho Component Definition"""
    model_config = ConfigDict(extra='allow')
    
    DefinitionType: Literal["CanvasComponent"] = Field(default="CanvasComponent")
    CustomProperties: Dict[str, CustomProperty] = Field(default_factory=dict)
    Properties: ComponentProperties = Field(default_factory=ComponentProperties)
    Children: List[Dict[str, Control]] = Field(default_factory=list)


class PowerAppYAML(BaseModel):
    """Model chính cho PowerApp YAML"""
    model_config = ConfigDict(extra='allow')
    
    ComponentDefinitions: Optional[Dict[str, ComponentDefinition]] = Field(None)
    Screens: Optional[Dict[str, Any]] = Field(None)


class PydanticYAMLHandler:
    """Pydantic-based YAML Handler cho Power App components"""
    
    def __init__(self, data: Optional[PowerAppYAML] = None):
        self.data = data
        
    def load_from_file(self, file_path: str) -> 'PydanticYAMLHandler':
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
            
    def load_from_string(self, yaml_string: str) -> 'PydanticYAMLHandler':
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
        
    def create_sample_button_component(self) -> 'PydanticYAMLHandler':
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
        
        # Create button control properties
        button_props = ControlProperties(
            X="=Parent.X",
            Y="=Parent.Y", 
            Width="=Parent.Width * 0.16",
            Height="=Parent.Height * 0.055",
            Text="=SampleButtonComponent.Text",
            Fill="=RGBA(227, 242, 253, 1)",
            Color="=RGBA(33, 150, 243, 1)",
            OnSelect="=SampleButtonComponent.OnClick()"
        )
        
        # Create button control
        button_control = Control(
            Control="Classic/Button",
            Properties=button_props
        )
        
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
        print("✅ Đã tạo sample ButtonComponent với Pydantic")
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
            
            # Check Children controls
            for child_dict in component.Children:
                for child_name, child_control in child_dict.items():
                    if not child_control.Control:
                        errors.append(f"{comp_name}.{child_name}: Thiếu Control type")
                    
                    # Check positioning
                    if child_control.Properties:
                        required_props = ['X', 'Y', 'Width', 'Height']
                        missing_props = []
                        for prop in required_props:
                            if not getattr(child_control.Properties, prop, None):
                                missing_props.append(prop)
                        if missing_props:
                            warnings.append(f"{comp_name}.{child_name}: Thiếu properties: {missing_props}")
        
        return {
            'valid': len(errors) == 0,
            'errors': errors,
            'warnings': warnings,
            'total_errors': len(errors),
            'total_warnings': len(warnings)
        }
        
    def create_from_template(self, template_name: str = "basic_button") -> 'PydanticYAMLHandler':
        """Tạo component từ template có sẵn"""
        
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
            return self
            
        return self.load_from_string(templates[template_name])
        
    def __str__(self) -> str:
        """String representation"""
        if self.data and self.data.ComponentDefinitions:
            total = len(self.data.ComponentDefinitions)
            return f"PydanticYAMLHandler - Components: {total} (Validated)"
        return "PydanticYAMLHandler - Empty"
        
    def __repr__(self) -> str:
        return self.__str__()


# Test function
def test_pydantic_yaml_handler():
    """Test Pydantic YAML Handler"""
    print("🧪 Testing PydanticYAMLHandler...")
    
    # Test 1: Tạo sample component
    print("\n1. Tạo sample component với Pydantic:")
    handler = PydanticYAMLHandler().create_sample_button_component()
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
    print(yaml_output[:300] + "..." if len(yaml_output) > 300 else yaml_output)
    
    # Test 5: Save to file
    print("\n5. Save to file:")
    handler.save_to_file("pydantic_test_output.yaml")
    
    # Test 6: Template test
    print("\n6. Test template:")
    template_handler = PydanticYAMLHandler().create_from_template("basic_button")
    print(template_handler)
    template_handler.save_to_file("template_test_output.yaml")
    
    return handler


if __name__ == "__main__":
    test_pydantic_yaml_handler() 