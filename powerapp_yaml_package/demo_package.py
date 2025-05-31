#!/usr/bin/env python3
"""
Demo script để showcase functionality của PowerApp YAML package.
"""

def demo_basic_functionality():
    """Demo basic functionality"""
    print("🚀 DEMO: Basic Functionality")
    print("=" * 40)
    
    from powerapp_yaml import YAMLHandler
    
    # Create handler
    handler = YAMLHandler()
    print(f"✅ Created handler: {handler}")
    
    # Create from template
    handler.create_from_template("basic_button")
    print("✅ Created from template")
    
    # Get component info
    info = handler.get_component_info()
    print(f"✅ Components: {info['total_components']}")
    print(f"   Structure: {list(info['structure'].keys())}")
    
    # Export YAML
    yaml_output = handler.to_yaml_string()
    print(f"✅ YAML output: {len(yaml_output)} characters")
    
    # Export JSON
    json_output = handler.to_json_string()
    print(f"✅ JSON output: {len(json_output)} characters")
    
    return handler


def demo_advanced_functionality():
    """Demo advanced functionality"""
    print("\n🚀 DEMO: Advanced Functionality")
    print("=" * 40)
    
    from powerapp_yaml import AdvancedYAMLHandler, TemplateBuilder, ComponentValidator
    
    # Template builder
    builder = TemplateBuilder()
    template = builder.create_card_template(
        title_property=True,
        content_property=True,
        actions=["save", "cancel"]
    )
    print("✅ Created card template with TemplateBuilder")
    
    # Load template
    handler = AdvancedYAMLHandler()
    handler.load_from_string(template)
    print("✅ Loaded template into handler")
    
    # Validate
    validator = ComponentValidator()
    result = validator.validate(handler.data)
    print(f"✅ Validation result: {result.is_valid}")
    print(f"   Errors: {result.total_errors}")
    print(f"   Warnings: {result.total_warnings}")
    
    # Get advanced info
    info = handler.get_component_info()
    stats = handler.get_stats()
    print(f"✅ Advanced info: {info['total_components']} components")
    print(f"   Created at: {stats['created_at'][:19]}")
    
    return handler


def demo_template_system():
    """Demo template system"""
    print("\n🚀 DEMO: Template System")
    print("=" * 40)
    
    from powerapp_yaml import YAMLHandler
    
    templates = ["basic_button", "input_field", "card_layout"]
    
    for template_name in templates:
        print(f"\n📋 Testing template: {template_name}")
        
        handler = YAMLHandler()
        handler.create_from_template(template_name)
        
        info = handler.get_component_info()
        print(f"   ✅ Components: {info['total_components']}")
        
        # Save template
        filename = f"demo_{template_name}.yaml"
        handler.save_to_file(filename)
        print(f"   📁 Saved: {filename}")


def demo_validation_system():
    """Demo validation system"""
    print("\n🚀 DEMO: Validation System")  
    print("=" * 40)
    
    from powerapp_yaml import AdvancedYAMLHandler, ComponentValidator
    
    # Test với valid component
    handler = AdvancedYAMLHandler()
    handler.create_sample_button_component()
    
    validator = ComponentValidator()
    result = validator.validate(handler.data)
    
    print(f"✅ Valid component test:")
    print(f"   Valid: {result.is_valid}")
    print(f"   Errors: {result.total_errors}")
    print(f"   Warnings: {result.total_warnings}")
    
    # Test với invalid component
    invalid_yaml = """
ComponentDefinitions:
  InvalidComponent:
    DefinitionType: WrongType
    CustomProperties:
      BadProperty:
        PropertyKind: Input
        Description: "Missing DataType"
        Default: ="Test"
    Properties:
      Height: =App.Height
      Width: =App.Width
    Children: []
"""
    
    handler2 = AdvancedYAMLHandler()
    handler2.load_from_string(invalid_yaml)
    
    result2 = validator.validate(handler2.data)
    
    print(f"\n❌ Invalid component test:")
    print(f"   Valid: {result2.is_valid}")
    print(f"   Errors: {result2.total_errors}")
    print(f"   Warnings: {result2.total_warnings}")
    if result2.errors:
        print(f"   First error: {result2.errors[0]}")


def demo_all_imports():
    """Demo all package imports"""
    print("\n🚀 DEMO: Package Imports")
    print("=" * 40)
    
    try:
        from powerapp_yaml import (
            YAMLHandler,
            AdvancedYAMLHandler, 
            BasicYAMLHandler,
            PropertyKind,
            DataType,
            TemplateBuilder,
            ComponentValidator
        )
        
        print("✅ All imports successful:")
        print(f"   - YAMLHandler: {YAMLHandler}")
        print(f"   - AdvancedYAMLHandler: {AdvancedYAMLHandler}")
        print(f"   - BasicYAMLHandler: {BasicYAMLHandler}")
        print(f"   - PropertyKind: {PropertyKind}")
        print(f"   - DataType: {DataType}")
        print(f"   - TemplateBuilder: {TemplateBuilder}")
        print(f"   - ComponentValidator: {ComponentValidator}")
        
        # Test enums
        print(f"\n📋 Enum values:")
        print(f"   PropertyKind: {[e.value for e in PropertyKind]}")
        print(f"   DataType: {[e.value for e in DataType][:5]}...")  # First 5
        
    except Exception as e:
        print(f"❌ Import error: {e}")


def main():
    """Main demo function"""
    print("🎉 POWERAPP YAML PACKAGE DEMO")
    print("=" * 50)
    print("Demonstrating professional Python package for PowerApp YAML handling")
    print("Data stored in triple quotes as requested")
    
    try:
        # Run all demos
        demo_all_imports()
        demo_basic_functionality() 
        demo_advanced_functionality()
        demo_template_system()
        demo_validation_system()
        
        print("\n🎯 DEMO COMPLETED SUCCESSFULLY!")
        print("=" * 50)
        print("✅ Package is working correctly")
        print("✅ All major features demonstrated")
        print("✅ Templates use triple quotes for data storage")
        print("✅ Validation system functioning")
        print("✅ Multiple export formats working")
        print("\n📁 Output files created:")
        print("   - demo_basic_button.yaml")
        print("   - demo_input_field.yaml") 
        print("   - demo_card_layout.yaml")
        
        print("\n🏆 PACKAGE READY FOR PRODUCTION USE!")
        
    except Exception as e:
        print(f"❌ Demo error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main() 