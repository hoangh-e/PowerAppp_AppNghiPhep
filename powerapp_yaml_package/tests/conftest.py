"""Pytest configuration and fixtures."""

import pytest
from pathlib import Path


@pytest.fixture
def sample_yaml_data():
    """Sample YAML data for testing."""
    return """
ComponentDefinitions:
  TestComponent:
    DefinitionType: CanvasComponent
    CustomProperties:
      TestProperty:
        PropertyKind: Input
        DisplayName: TestProperty
        Description: "Test property"
        DataType: Text
        Default: ="Test"
    Properties:
      Height: =App.Height
      Width: =App.Width
    Children: []
"""


@pytest.fixture
def temp_yaml_file(tmp_path, sample_yaml_data):
    """Create temporary YAML file for testing."""
    file_path = tmp_path / "test.yaml"
    file_path.write_text(sample_yaml_data, encoding="utf-8")
    return file_path
