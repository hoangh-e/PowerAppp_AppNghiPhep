#!/usr/bin/env python3
"""Advanced usage example for PowerApp YAML."""

from powerapp_yaml import AdvancedYAMLHandler, TemplateBuilder, ComponentValidator

def main():
    """Advanced usage demonstration."""
    
    # Template builder
    builder = TemplateBuilder()
    template = builder.create_card_template(
        title_property=True,
        content_property=True,
        actions=["save", "cancel"]
    )
    
    # Load template
    handler = AdvancedYAMLHandler()
    handler.load_from_string(template)
    print("Loaded custom template")
    
    # Validate
    validator = ComponentValidator()
    result = validator.validate(handler.data)
    print(f"Validation: {result.is_valid}")
    print(f"Errors: {result.total_errors}")
    print(f"Warnings: {result.total_warnings}")
    
    # Export multiple formats
    handler.save_to_file("advanced_card.yaml")
    
    json_output = handler.to_json_string()
    with open("advanced_card.json", "w", encoding="utf-8") as f:
        f.write(json_output)
    
    print("Exported to YAML and JSON")

if __name__ == "__main__":
    main()
