"""Tests for AdvancedYAMLHandler."""

import pytest
from powerapp_yaml.core.advanced_handler import AdvancedYAMLHandler


class TestAdvancedYAMLHandler:
    """Test cases for AdvancedYAMLHandler."""
    
    def test_creation(self):
        """Test handler creation."""
        handler = AdvancedYAMLHandler()
        assert handler is not None
        assert handler.data is None
    
    def test_sample_component(self):
        """Test sample component creation."""
        handler = AdvancedYAMLHandler()
        handler.create_sample_button_component()
        
        assert handler.data is not None
        info = handler.get_component_info()
        assert info['total_components'] == 1
        assert 'SampleButtonComponent' in info['components']
    
    def test_yaml_export(self):
        """Test YAML export."""
        handler = AdvancedYAMLHandler()
        handler.create_sample_button_component()
        
        yaml_output = handler.to_yaml_string()
        assert len(yaml_output) > 0
        assert 'ComponentDefinitions' in yaml_output
    
    def test_validation(self):
        """Test component validation."""
        handler = AdvancedYAMLHandler()
        handler.create_sample_button_component()
        
        validation = handler.validate_component_structure()
        assert validation['valid'] is True
        assert validation['total_errors'] == 0
