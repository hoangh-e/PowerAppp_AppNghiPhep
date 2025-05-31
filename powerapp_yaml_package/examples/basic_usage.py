#!/usr/bin/env python3
"""Basic usage example for PowerApp YAML."""

from powerapp_yaml import YAMLHandler

def main():
    """Basic usage demonstration."""
    
    # Create handler
    handler = YAMLHandler()
    print("Created handler:", handler)
    
    # Create from template
    handler.create_from_template("basic_button")
    print("Created from template")
    
    # Get component info
    info = handler.get_component_info()
    print(f"Components: {info['total_components']}")
    
    # Save to file
    handler.save_to_file("example_button.yaml")
    print("Saved to file")
    
    # Convert to JSON
    json_output = handler.to_json_string()
    print(f"JSON length: {len(json_output)} characters")

if __name__ == "__main__":
    main()
