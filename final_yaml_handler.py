import yaml
import json
from typing import Dict, Any, Optional, List, Union
from pathlib import Path
from enum import Enum
from dataclasses import dataclass, field
from datetime import datetime


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


@dataclass
class CustomProperty:
    """Dataclass cho Custom Property"""
    property_kind: PropertyKind
    display_name: str
    description: str
    data_type: Optional[DataType] = None
    default_value: str = ""
    return_type: Optional[str] = None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for YAML export"""
        result = {
            "PropertyKind": self.property_kind.value,
            "DisplayName": self.display_name,
            "Description": self.description,
            "Default": self.default_value
        }
        if self.data_type:
            result["DataType"] = self.data_type.value
        if self.return_type:
            result["ReturnType"] = self.return_type
        return result
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'CustomProperty':
        """Create from dictionary"""
        return cls(
            property_kind=PropertyKind(data["PropertyKind"]),
            display_name=data["DisplayName"],
            description=data["Description"],
            data_type=DataType(data["DataType"]) if data.get("DataType") else None,
            default_value=data.get("Default", ""),
            return_type=data.get("ReturnType")
        )


@dataclass
class ComponentProperties:
    """Dataclass cho Component Properties"""
    height: str = "=App.Height"
    width: str = "=App.Width"
    
    def to_dict(self) -> Dict[str, str]:
        return {"Height": self.height, "Width": self.width}
    
    @classmethod
    def from_dict(cls, data: Dict[str, str]) -> 'ComponentProperties':
        return cls(
            height=data.get("Height", "=App.Height"),
            width=data.get("Width", "=App.Width")
        )


@dataclass
class ComponentDefinition:
    """Dataclass cho Component Definition"""
    definition_type: str = "CanvasComponent"
    custom_properties: Dict[str, CustomProperty] = field(default_factory=dict)
    properties: ComponentProperties = field(default_factory=ComponentProperties)
    children: List[Dict[str, Any]] = field(default_factory=list)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for YAML export"""
        return {
            "DefinitionType": self.definition_type,
            "CustomProperties": {name: prop.to_dict() for name, prop in self.custom_properties.items()},
            "Properties": self.properties.to_dict(),
            "Children": self.children
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'ComponentDefinition':
        """Create from dictionary"""
        custom_props = {}
        for name, prop_data in data.get("CustomProperties", {}).items():
            custom_props[name] = CustomProperty.from_dict(prop_data)
        
        return cls(
            definition_type=data.get("DefinitionType", "CanvasComponent"),
            custom_properties=custom_props,
            properties=ComponentProperties.from_dict(data.get("Properties", {})),
            children=data.get("Children", [])
        )


@dataclass
class PowerAppYAML:
    """Dataclass cho PowerApp YAML"""
    component_definitions: Optional[Dict[str, ComponentDefinition]] = None
    screens: Optional[Dict[str, Any]] = None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for YAML export"""
        result = {}
        if self.component_definitions:
            result["ComponentDefinitions"] = {
                name: comp.to_dict() for name, comp in self.component_definitions.items()
            }
        if self.screens:
            result["Screens"] = self.screens
        return result
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'PowerAppYAML':
        """Create from dictionary"""
        component_defs = None
        if "ComponentDefinitions" in data:
            component_defs = {}
            for name, comp_data in data["ComponentDefinitions"].items():
                component_defs[name] = ComponentDefinition.from_dict(comp_data)
        
        return cls(
            component_definitions=component_defs,
            screens=data.get("Screens")
        )


class FinalYAMLHandler:
    """Final YAML Handler using dataclasses - Compatible and robust"""
    
    def __init__(self, data: Optional[PowerAppYAML] = None):
        self.data = data
        self.created_at = datetime.now()
        
    def load_from_file(self, file_path: str) -> 'FinalYAMLHandler':
        """Load YAML data từ file với validation"""
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                raw_data = yaml.safe_load(file)
                self.data = PowerAppYAML.from_dict(raw_data)
            print(f"✅ Đã load thành công từ: {file_path}")
            return self
        except Exception as e:
            print(f"❌ Lỗi khi load file: {e}")
            return self
            
    def load_from_string(self, yaml_string: str) -> 'FinalYAMLHandler':
        """Load YAML data từ string với validation"""
        try:
            raw_data = yaml.safe_load(yaml_string)
            self.data = PowerAppYAML.from_dict(raw_data)
            print("✅ Đã load thành công từ string")
            return self
        except Exception as e:
            print(f"❌ Lỗi khi parse YAML: {e}")
            return self
            
    def save_to_file(self, file_path: str) -> bool:
        """Save YAML data ra file"""
        if not self.data:
            print("❌ Không có data để save")
            return False
            
        try:
            data_dict = self.data.to_dict()
            
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
            data_dict = self.data.to_dict()
            return yaml.dump(data_dict, default_flow_style=False, 
                           allow_unicode=True, sort_keys=False, indent=2)
        except Exception as e:
            print(f"❌ Lỗi khi convert sang YAML: {e}")
            return ""
            
    def to_json_string(self, indent: int = 2) -> str:
        """Convert data thành JSON string"""
        if not self.data:
            return ""
            
        try:
            data_dict = self.data.to_dict()
            return json.dumps(data_dict, indent=indent, ensure_ascii=False)
        except Exception as e:
            print(f"❌ Lỗi khi convert sang JSON: {e}")
            return ""
            
    def get_component_info(self) -> Dict[str, Any]:
        """Lấy thông tin component từ data"""
        if not self.data or not self.data.component_definitions:
            return {'error': 'Không có ComponentDefinitions'}
            
        components = self.data.component_definitions
        return {
            'components': list(components.keys()),
            'total_components': len(components),
            'structure': {name: self._get_component_structure(comp) 
                         for name, comp in components.items()}
        }
        
    def _get_component_structure(self, component: ComponentDefinition) -> Dict[str, Any]:
        """Phân tích cấu trúc của component"""
        structure = {
            'type': component.definition_type,
            'custom_properties': len(component.custom_properties),
            'children': len(component.children)
        }
        
        if component.custom_properties:
            structure['property_types'] = {}
            structure['property_kinds'] = {}
            
            for prop_name, prop_data in component.custom_properties.items():
                # Count by DataType
                if prop_data.data_type:
                    data_type = prop_data.data_type.value
                    if data_type not in structure['property_types']:
                        structure['property_types'][data_type] = 0
                    structure['property_types'][data_type] += 1
                
                # Count by PropertyKind
                kind = prop_data.property_kind.value
                if kind not in structure['property_kinds']:
                    structure['property_kinds'][kind] = 0
                structure['property_kinds'][kind] += 1
                
        return structure
        
    def create_sample_button_component(self) -> 'FinalYAMLHandler':
        """Tạo sample ButtonComponent với dataclasses"""
        
        # Create custom properties
        custom_props = {
            "Text": CustomProperty(
                property_kind=PropertyKind.INPUT,
                display_name="Text",
                description="Text hiển thị trên button",
                data_type=DataType.TEXT,
                default_value='="Button"'
            ),
            "Variant": CustomProperty(
                property_kind=PropertyKind.INPUT,
                display_name="Variant", 
                description="Loại button: Primary, Secondary, Danger",
                data_type=DataType.TEXT,
                default_value='="Primary"'
            ),
            "IsDisabled": CustomProperty(
                property_kind=PropertyKind.INPUT,
                display_name="IsDisabled",
                description="Button bị disable",
                data_type=DataType.BOOLEAN,
                default_value="=false"
            ),
            "OnClick": CustomProperty(
                property_kind=PropertyKind.EVENT,
                display_name="OnClick",
                description="Sự kiện khi click button",
                return_type="None",
                default_value="=false"
            )
        }
        
        # Create button control
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
            definition_type="CanvasComponent",
            custom_properties=custom_props,
            properties=ComponentProperties(),
            children=[{"Button.Container": button_control}]
        )
        
        # Create PowerApp YAML
        power_app = PowerAppYAML(
            component_definitions={"SampleButtonComponent": component_def}
        )
        
        self.data = power_app
        print("✅ Đã tạo sample ButtonComponent với dataclasses")
        return self
        
    def validate_component_structure(self) -> Dict[str, Any]:
        """Validate cấu trúc component theo Power App rules"""
        if not self.data or not self.data.component_definitions:
            return {'valid': False, 'errors': ['Không có ComponentDefinitions']}
            
        errors = []
        warnings = []
        
        for comp_name, component in self.data.component_definitions.items():
            # Check DefinitionType
            if component.definition_type != "CanvasComponent":
                errors.append(f"{comp_name}: DefinitionType phải là 'CanvasComponent'")
            
            # Check CustomProperties
            for prop_name, prop in component.custom_properties.items():
                if prop.property_kind == PropertyKind.EVENT:
                    if prop.data_type:
                        warnings.append(f"{comp_name}.{prop_name}: Event không nên có DataType")
                    if not prop.return_type:
                        warnings.append(f"{comp_name}.{prop_name}: Event nên có ReturnType")
                else:
                    if not prop.data_type:
                        errors.append(f"{comp_name}.{prop_name}: Input/Output phải có DataType")
            
            # Check Children controls
            for child_dict in component.children:
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
    
    def create_from_template(self, template_name: str = "basic_button") -> 'FinalYAMLHandler':
        """Tạo component từ template có sẵn - Data lưu trong triple quotes"""
        
        # Templates được lưu trong triple quotes như yêu cầu
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
""",
            "card_layout": """
ComponentDefinitions:
  CardLayoutComponent:
    DefinitionType: CanvasComponent
    CustomProperties:
      Title:
        PropertyKind: Input
        DisplayName: Title
        Description: "Tiêu đề của card"
        DataType: Text
        Default: ="Card Title"
      Content:
        PropertyKind: Input
        DisplayName: Content
        Description: "Nội dung của card"
        DataType: Text
        Default: ="Card content goes here..."
      ShowBorder:
        PropertyKind: Input
        DisplayName: ShowBorder
        Description: "Hiển thị viền card"
        DataType: Boolean
        Default: =true
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
            BorderColor: =If(CardLayoutComponent.ShowBorder, RGBA(230, 230, 230, 1), RGBA(0, 0, 0, 0))
            BorderThickness: =If(CardLayoutComponent.ShowBorder, 1, 0)
            BorderRadius: =8
          Children:
            - 'Card.Title':
                Control: Label
                Properties:
                  X: =Parent.X + 16
                  Y: =Parent.Y + 16
                  Width: =Parent.Width - 32
                  Height: =32
                  Text: =CardLayoutComponent.Title
                  FontWeight: =FontWeight.Bold
                  Size: =18
                  Color: =RGBA(32, 54, 71, 1)
            - 'Card.Content':
                Control: Label
                Properties:
                  X: =Parent.X + 16
                  Y: ='Card.Title'.Y + 'Card.Title'.Height + 8
                  Width: =Parent.Width - 32
                  Height: =Parent.Height - 'Card.Title'.Height - 48
                  Text: =CardLayoutComponent.Content
                  Size: =14
                  Color: =RGBA(75, 85, 99, 1)
"""
        }
        
        if template_name not in templates:
            print(f"❌ Template '{template_name}' không tồn tại")
            available_templates = list(templates.keys())
            print(f"📋 Available templates: {available_templates}")
            return self
            
        return self.load_from_string(templates[template_name])
    
    def get_stats(self) -> Dict[str, Any]:
        """Lấy thống kê chi tiết về handler"""
        stats = {
            'created_at': self.created_at.isoformat(),
            'has_data': self.data is not None,
            'total_components': 0,
            'total_screens': 0
        }
        
        if self.data:
            if self.data.component_definitions:
                stats['total_components'] = len(self.data.component_definitions)
            if self.data.screens:
                stats['total_screens'] = len(self.data.screens)
                
        return stats
    
    def get_raw_data(self) -> Dict[str, Any]:
        """Lấy raw data để debug"""
        if self.data:
            return self.data.to_dict()
        return {}
        
    def __str__(self) -> str:
        """String representation"""
        if self.data and self.data.component_definitions:
            total = len(self.data.component_definitions)
            return f"FinalYAMLHandler - Components: {total} (Dataclass-based)"
        return "FinalYAMLHandler - Empty"
        
    def __repr__(self) -> str:
        return self.__str__()


# Test function
def test_final_yaml_handler():
    """Test Final YAML Handler"""
    print("🧪 Testing FinalYAMLHandler (Dataclass-based)...")
    
    # Test 1: Tạo sample component
    print("\n1. Tạo sample component với dataclasses:")
    handler = FinalYAMLHandler().create_sample_button_component()
    print(handler)
    
    # Test 2: Stats
    print("\n2. Handler stats:")
    stats = handler.get_stats()
    print(json.dumps(stats, indent=2, ensure_ascii=False))
    
    # Test 3: Validation
    print("\n3. Validate component structure:")
    validation = handler.validate_component_structure()
    print(json.dumps(validation, indent=2, ensure_ascii=False))
    
    # Test 4: Thông tin component
    print("\n4. Thông tin component:")
    info = handler.get_component_info()
    print(json.dumps(info, indent=2, ensure_ascii=False))
    
    # Test 5: Export YAML
    print("\n5. Export YAML:")
    yaml_output = handler.to_yaml_string()
    print(yaml_output[:450] + "..." if len(yaml_output) > 450 else yaml_output)
    
    # Test 6: Save to file
    print("\n6. Save to file:")
    handler.save_to_file("final_test_output.yaml")
    
    # Test 7: Template tests
    print("\n7. Test templates:")
    for template_name in ["basic_button", "input_field", "card_layout"]:
        print(f"   Testing template: {template_name}")
        template_handler = FinalYAMLHandler().create_from_template(template_name)
        print(f"   {template_handler}")
        template_handler.save_to_file(f"final_template_{template_name}.yaml")
    
    # Test 8: Load file gốc và so sánh
    print("\n8. Load và validate ButtonComponent.yaml:")
    try:
        original_handler = FinalYAMLHandler().load_from_file("src/Components/ButtonComponent.yaml")
        print(original_handler)
        validation = original_handler.validate_component_structure()
        print(f"   Validation: {validation['valid']} - Errors: {validation['total_errors']}, Warnings: {validation['total_warnings']}")
        
        # Export file gốc
        original_handler.save_to_file("final_original_export.yaml")
        print("   ✅ Đã export file gốc ra final_original_export.yaml")
        
    except Exception as e:
        print(f"   ❌ Lỗi validation: {e}")
    
    return handler


if __name__ == "__main__":
    test_final_yaml_handler() 