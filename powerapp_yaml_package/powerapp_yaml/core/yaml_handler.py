import yaml
import json
from typing import Dict, Any, Optional
from pathlib import Path

class YAMLHandler:
    """Class để xử lý import/export YAML files cho Power App components"""
    
    def __init__(self, data: Optional[Dict[str, Any]] = None):
        self.data = data or {}
        
    def load_from_file(self, file_path: str) -> 'YAMLHandler':
        """Load YAML data từ file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                self.data = yaml.safe_load(file)
            print(f"✅ Đã load thành công từ: {file_path}")
            return self
        except Exception as e:
            print(f"❌ Lỗi khi load file: {e}")
            return self
            
    def load_from_string(self, yaml_string: str) -> 'YAMLHandler':
        """Load YAML data từ string"""
        try:
            self.data = yaml.safe_load(yaml_string)
            print("✅ Đã load thành công từ string")
            return self
        except Exception as e:
            print(f"❌ Lỗi khi parse YAML: {e}")
            return self
            
    def save_to_file(self, file_path: str) -> bool:
        """Save YAML data ra file"""
        try:
            with open(file_path, 'w', encoding='utf-8') as file:
                yaml.dump(self.data, file, default_flow_style=False, 
                         allow_unicode=True, sort_keys=False, indent=2)
            print(f"✅ Đã save thành công ra: {file_path}")
            return True
        except Exception as e:
            print(f"❌ Lỗi khi save file: {e}")
            return False
            
    def to_yaml_string(self) -> str:
        """Convert data thành YAML string"""
        try:
            return yaml.dump(self.data, default_flow_style=False, 
                           allow_unicode=True, sort_keys=False, indent=2)
        except Exception as e:
            print(f"❌ Lỗi khi convert sang YAML: {e}")
            return ""
            
    def to_json_string(self) -> str:
        """Convert data thành JSON string"""
        try:
            return json.dumps(self.data, indent=2, ensure_ascii=False)
        except Exception as e:
            print(f"❌ Lỗi khi convert sang JSON: {e}")
            return ""
            
    def get_component_info(self) -> Dict[str, Any]:
        """Lấy thông tin component từ YAML data"""
        if 'ComponentDefinitions' in self.data:
            components = self.data['ComponentDefinitions']
            return {
                'components': list(components.keys()),
                'total_components': len(components),
                'structure': {name: self._get_component_structure(comp) 
                           for name, comp in components.items()}
            }
        return {'error': 'Không tìm thấy ComponentDefinitions'}
        
    def _get_component_structure(self, component: Dict[str, Any]) -> Dict[str, Any]:
        """Phân tích cấu trúc của component"""
        structure = {
            'type': component.get('DefinitionType', 'Unknown'),
            'custom_properties': len(component.get('CustomProperties', {})),
            'children': len(component.get('Children', []))
        }
        
        if 'CustomProperties' in component:
            structure['property_types'] = {}
            for prop_name, prop_data in component['CustomProperties'].items():
                prop_type = prop_data.get('DataType', 'Unknown')
                if prop_type not in structure['property_types']:
                    structure['property_types'][prop_type] = 0
                structure['property_types'][prop_type] += 1
                
        return structure
        
    def create_sample_component(self) -> 'YAMLHandler':
        """Tạo sample component để test"""
        sample_data = """
ComponentDefinitions:
  SampleButtonComponent:
    DefinitionType: CanvasComponent
    CustomProperties:
      Text:
        PropertyKind: Input
        DisplayName: Text
        Description: "Text hiển thị trên button"
        DataType: Text
        Default: ="Button"
      Variant:
        PropertyKind: Input
        DisplayName: Variant
        Description: "Loại button: Primary, Secondary, Danger"
        DataType: Text
        Default: ="Primary"
      IsDisabled:
        PropertyKind: Input
        DisplayName: IsDisabled
        Description: "Button bị disable"
        DataType: Boolean
        Default: =false
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
      - 'Button.Container':
          Control: Classic/Button
          Properties:
            X: =Parent.X
            Y: =Parent.Y
            Width: =Parent.Width * 0.16
            Height: =Parent.Height * 0.055
            Text: =SampleButtonComponent.Text
            Fill: =RGBA(227, 242, 253, 1)
            Color: =RGBA(33, 150, 243, 1)
            OnSelect: =SampleButtonComponent.OnClick()
"""
        return self.load_from_string(sample_data)
        
    def __str__(self) -> str:
        """String representation"""
        if self.data:
            info = self.get_component_info()
            return f"YAMLHandler - Components: {info.get('total_components', 0)}"
        return "YAMLHandler - Empty"
        
    def __repr__(self) -> str:
        return self.__str__()


# Test function
def test_yaml_handler():
    """Test các chức năng của YAMLHandler"""
    print("🧪 Testing YAMLHandler...")
    
    # Test 1: Tạo sample component
    print("\n1. Tạo sample component:")
    handler = YAMLHandler().create_sample_component()
    print(handler)
    
    # Test 2: Lấy thông tin component
    print("\n2. Thông tin component:")
    info = handler.get_component_info()
    print(json.dumps(info, indent=2, ensure_ascii=False))
    
    # Test 3: Export YAML
    print("\n3. Export YAML string:")
    yaml_output = handler.to_yaml_string()
    print(yaml_output[:200] + "..." if len(yaml_output) > 200 else yaml_output)
    
    # Test 4: Save to file
    print("\n4. Save to file:")
    handler.save_to_file("test_output.yaml")
    
    # Test 5: Load từ file gốc
    print("\n5. Load từ file ButtonComponent.yaml:")
    original_handler = YAMLHandler().load_from_file("src/Components/ButtonComponent.yaml")
    print(original_handler)
    print("Info:", original_handler.get_component_info())
    
    return handler


if __name__ == "__main__":
    test_yaml_handler() 