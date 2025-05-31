"""
Demo script so sánh các YAML Handler versions đã tạo:
1. YAMLHandler (basic version)
2. FinalYAMLHandler (dataclass-based - recommended)
"""

import time
import json
from yaml_handler import YAMLHandler, test_yaml_handler
from final_yaml_handler import FinalYAMLHandler, test_final_yaml_handler


def demo_basic_yaml_handler():
    """Demo Basic YAML Handler"""
    print("=" * 60)
    print("🚀 DEMO: Basic YAML Handler")
    print("=" * 60)
    
    start_time = time.time()
    
    # Test basic operations
    handler = YAMLHandler()
    
    # Create sample
    handler.create_sample_component()
    
    # Export YAML với data trong triple quotes
    sample_yaml = """
ComponentDefinitions:
  DemoComponent:
    DefinitionType: CanvasComponent
    CustomProperties:
      Title:
        PropertyKind: Input
        DisplayName: Title
        Description: "Demo title"
        DataType: Text
        Default: ="Demo Title"
      OnAction:
        PropertyKind: Event
        DisplayName: OnAction
        Description: "Demo event"
        ReturnType: None
        Default: =false
    Properties:
      Height: =App.Height
      Width: =App.Width
    Children:
      - 'Demo.Label':
          Control: Label
          Properties:
            X: =Parent.X
            Y: =Parent.Y
            Width: =Parent.Width
            Height: =50
            Text: =DemoComponent.Title
"""
    
    # Load từ string với triple quotes
    handler.load_from_string(sample_yaml)
    
    # Get info
    info = handler.get_component_info()
    print(f"✅ Components: {info.get('total_components', 0)}")
    
    # Save
    handler.save_to_file("demo_basic_output.yaml")
    
    end_time = time.time()
    print(f"⏱️  Thời gian: {end_time - start_time:.3f}s")
    
    return handler


def demo_final_yaml_handler():
    """Demo Final YAML Handler (Dataclass-based)"""
    print("\n" + "=" * 60)
    print("🚀 DEMO: Final YAML Handler (Dataclass-based)")
    print("=" * 60)
    
    start_time = time.time()
    
    # Test advanced operations
    handler = FinalYAMLHandler()
    
    # Create sample
    handler.create_sample_button_component()
    
    # Template với data trong triple quotes
    handler_template = FinalYAMLHandler().create_from_template("basic_button")
    
    # Validation
    validation = handler.validate_component_structure()
    print(f"✅ Validation: {validation['valid']} (Errors: {validation['total_errors']}, Warnings: {validation['total_warnings']})")
    
    # Advanced info
    info = handler.get_component_info()
    stats = handler.get_stats()
    print(f"✅ Components: {info.get('total_components', 0)}")
    print(f"✅ Created at: {stats.get('created_at', 'N/A')}")
    
    # Export multiple formats
    handler.save_to_file("demo_final_output.yaml")
    
    # JSON export
    json_output = handler.to_json_string()
    with open("demo_final_output.json", "w", encoding="utf-8") as f:
        f.write(json_output)
    
    end_time = time.time()
    print(f"⏱️  Thời gian: {end_time - start_time:.3f}s")
    
    return handler


def demo_template_showcase():
    """Demo Template showcase với data trong triple quotes"""
    print("\n" + "=" * 60)
    print("🚀 DEMO: Template Showcase (Data trong triple quotes)")
    print("=" * 60)
    
    templates_to_test = ["basic_button", "input_field", "card_layout"]
    
    for template_name in templates_to_test:
        print(f"\n📋 Testing template: {template_name}")
        
        handler = FinalYAMLHandler().create_from_template(template_name)
        info = handler.get_component_info()
        
        print(f"   ✅ Loaded: {handler}")
        print(f"   📊 Structure: {info['structure']}")
        
        # Save template
        handler.save_to_file(f"demo_template_{template_name}.yaml")


def demo_file_operations():
    """Demo File operations với real file"""
    print("\n" + "=" * 60)
    print("🚀 DEMO: File Operations với ButtonComponent.yaml")
    print("=" * 60)
    
    # Test với file thực
    try:
        # Basic handler
        basic_handler = YAMLHandler().load_from_file("src/Components/ButtonComponent.yaml")
        basic_info = basic_handler.get_component_info()
        
        # Final handler
        final_handler = FinalYAMLHandler().load_from_file("src/Components/ButtonComponent.yaml")
        final_info = final_handler.get_component_info()
        final_validation = final_handler.validate_component_structure()
        
        print("📊 Comparison Results:")
        print(f"   Basic Handler - Components: {basic_info.get('total_components', 0)}")
        print(f"   Final Handler - Components: {final_info.get('total_components', 0)}")
        print(f"   Final Handler - Validation: {final_validation['valid']}")
        
        # Export comparison
        basic_handler.save_to_file("demo_basic_from_file.yaml")
        final_handler.save_to_file("demo_final_from_file.yaml")
        
        print("✅ Cả hai handlers đều xử lý file thành công!")
        
    except Exception as e:
        print(f"❌ Lỗi khi test file operations: {e}")


def demo_performance_comparison():
    """Demo Performance comparison"""
    print("\n" + "=" * 60)
    print("🚀 DEMO: Performance Comparison")
    print("=" * 60)
    
    # Data mẫu lớn với triple quotes
    large_yaml_data = """
ComponentDefinitions:
  LargeTestComponent:
    DefinitionType: CanvasComponent
    CustomProperties:
      Property1:
        PropertyKind: Input
        DisplayName: Property1
        Description: "Test property 1"
        DataType: Text
        Default: ="Value1"
      Property2:
        PropertyKind: Input
        DisplayName: Property2
        Description: "Test property 2"
        DataType: Number
        Default: =100
      Property3:
        PropertyKind: Input
        DisplayName: Property3
        Description: "Test property 3"
        DataType: Boolean
        Default: =true
      OnEvent1:
        PropertyKind: Event
        DisplayName: OnEvent1
        Description: "Test event 1"
        ReturnType: None
        Default: =false
      OnEvent2:
        PropertyKind: Event
        DisplayName: OnEvent2
        Description: "Test event 2"
        ReturnType: None
        Default: =false
    Properties:
      Height: =App.Height
      Width: =App.Width
    Children:
      - 'Control1':
          Control: Label
          Properties:
            X: =Parent.X
            Y: =Parent.Y
            Width: =Parent.Width
            Height: =50
            Text: ="Control 1"
      - 'Control2':
          Control: Classic/Button
          Properties:
            X: =Parent.X
            Y: =Parent.Y + 60
            Width: =Parent.Width
            Height: =40
            Text: ="Button 1"
      - 'Control3':
          Control: Classic/TextInput
          Properties:
            X: =Parent.X
            Y: =Parent.Y + 110
            Width: =Parent.Width
            Height: =35
            HintText: ="Enter text..."
"""
    
    iterations = 5
    
    # Test Basic Handler
    print(f"🔄 Testing Basic Handler ({iterations} iterations)...")
    basic_times = []
    for i in range(iterations):
        start = time.time()
        handler = YAMLHandler().load_from_string(large_yaml_data)
        info = handler.get_component_info()
        yaml_output = handler.to_yaml_string()
        end = time.time()
        basic_times.append(end - start)
    
    basic_avg = sum(basic_times) / len(basic_times)
    print(f"   Average time: {basic_avg:.4f}s")
    
    # Test Final Handler
    print(f"🔄 Testing Final Handler ({iterations} iterations)...")
    final_times = []
    for i in range(iterations):
        start = time.time()
        handler = FinalYAMLHandler().load_from_string(large_yaml_data)
        info = handler.get_component_info()
        validation = handler.validate_component_structure()
        yaml_output = handler.to_yaml_string()
        end = time.time()
        final_times.append(end - start)
    
    final_avg = sum(final_times) / len(final_times)
    print(f"   Average time: {final_avg:.4f}s")
    
    # Comparison
    if final_avg < basic_avg:
        improvement = (basic_avg - final_avg) / basic_avg * 100
        print(f"🚀 Final Handler nhanh hơn {improvement:.1f}%")
    else:
        slower = (final_avg - basic_avg) / basic_avg * 100
        print(f"⚠️  Final Handler chậm hơn {slower:.1f}% (nhưng có thêm features)")


def main():
    """Main demo function"""
    print("🎉 YAML HANDLER DEMO COMPARISON")
    print("Comparison của các YAML Handler versions đã implement")
    print("Data được lưu trong triple quotes (\"\"\"data\"\"\") như yêu cầu")
    
    try:
        # Run all demos
        demo_basic_yaml_handler()
        demo_final_yaml_handler()
        demo_template_showcase()
        demo_file_operations()
        demo_performance_comparison()
        
        print("\n" + "=" * 60)
        print("🎯 SUMMARY & RECOMMENDATIONS")
        print("=" * 60)
        print("✅ Basic YAML Handler:")
        print("   - Đơn giản, dễ sử dụng")
        print("   - Phù hợp cho use cases cơ bản")
        print("   - Sử dụng PyYAML thuần")
        
        print("\n✅ Final YAML Handler (RECOMMENDED):")
        print("   - Sử dụng dataclasses (no Pydantic conflicts)")
        print("   - Validation built-in")
        print("   - Template system với triple quotes")
        print("   - Type safety và error handling tốt")
        print("   - Export multiple formats (YAML, JSON)")
        print("   - Performance tracking")
        
        print("\n📁 Files created:")
        print("   - demo_basic_output.yaml")
        print("   - demo_final_output.yaml + .json")
        print("   - demo_template_*.yaml")
        print("   - demo_*_from_file.yaml")
        
        print("\n🏆 WINNER: FinalYAMLHandler (dataclass-based)")
        print("   Reason: Robust, feature-rich, no dependency conflicts")
        
    except Exception as e:
        print(f"❌ Demo error: {e}")


if __name__ == "__main__":
    main() 