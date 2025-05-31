import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Union, Tuple

from dataclasses import dataclass, field

try:
    # ruamel.yaml preserves comments & ordering better than PyYAML
    from ruamel.yaml import YAML  # type: ignore
except ImportError:  # pragma: no cover
    raise ImportError("Please install ruamel.yaml: pip install ruamel.yaml")

# ------------------------------------------------------------
# Core data structures
# ------------------------------------------------------------

@dataclass
class Control:
    """Generic Power Apps control (Button, TextInput, etc.)."""

    name: str
    control_type: str
    properties: Dict[str, Any] = field(default_factory=dict)
    children: List["Control"] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        node: Dict[str, Any] = {self.name: {
            "Control": self.control_type,
        }}
        if self.properties:
            node[self.name]["Properties"] = self.properties
        if self.children:
            node[self.name]["Children"] = [child.to_dict() for child in self.children]
        return node


@dataclass
class Screen:
    """Represents a Power Apps screen (root YAML key: Screens)."""

    name: str
    properties: Dict[str, Any] = field(default_factory=dict)
    children: List[Control] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        d: Dict[str, Any] = {
            self.name: {
                "Properties": self.properties,
                "Children": [child.to_dict() for child in self.children] if self.children else []
            }
        }
        return {"Screens": d}


@dataclass
class ComponentDefinition:
    name: str
    properties: Dict[str, Any] = field(default_factory=dict)
    custom_properties: Dict[str, Any] = field(default_factory=dict)
    children: List[Control] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        d: Dict[str, Any] = {
            self.name: {
                "DefinitionType": "CanvasComponent",
                "CustomProperties": self.custom_properties,
                "Properties": self.properties,
                "Children": [child.to_dict() for child in self.children] if self.children else []
            }
        }
        return {"ComponentDefinitions": d}


# ------------------------------------------------------------
# Validation utilities
# ------------------------------------------------------------

class ValidationError(Exception):
    pass


class PowerAppValidator:
    """Validate YAML nodes against Power App rules (subset demo)."""

    # Demo subset of rules – extend as needed
    FORBIDDEN_PROPERTIES_BY_CONTROL: Dict[str, List[str]] = {
        "Rectangle": [
            "RadiusBottomLeft",
            "RadiusBottomRight",
            "RadiusTopLeft",
            "RadiusTopRight",
            "Variant",
            "DropShadow",
        ],
        "Classic/Button": [
            "BorderRadius",
            "Disabled",  # Should use DisplayMode
            "Align",
        ],
    }

    def validate_control(self, control: Control) -> List[str]:
        errors: List[str] = []
        forbidden = self.FORBIDDEN_PROPERTIES_BY_CONTROL.get(control.control_type, [])
        for prop in forbidden:
            if prop in control.properties:
                errors.append(
                    f"{control.name}: Property '{prop}' is forbidden for control type '{control.control_type}'"
                )
        # TODO: add more rule checks (absolute positioning, invalid icons, etc.)
        return errors

    def validate_screen(self, screen: Screen) -> List[str]:
        errs: List[str] = []
        for child in screen.children:
            errs.extend(self.validate_control_recursive(child))
        return errs

    def validate_control_recursive(self, control: Control) -> List[str]:
        errs = self.validate_control(control)
        for ch in control.children:
            errs.extend(self.validate_control_recursive(ch))
        return errs


# ------------------------------------------------------------
# YAML <-> Object helpers
# ------------------------------------------------------------

class PowerAppYAMLParser:
    def __init__(self):
        self.yaml = YAML()
        self.yaml.indent(mapping=2, sequence=4, offset=2)
        self.validator = PowerAppValidator()

    # --------------------------------------------------------
    # Loading & Validation
    # --------------------------------------------------------

    def load(self, path_or_str: Union[str, Path]) -> Dict[str, Any]:
        if isinstance(path_or_str, Path) or Path(path_or_str).exists():
            with open(path_or_str, "r", encoding="utf-8") as f:
                data = self.yaml.load(f)
        else:
            # treat as YAML snippet string
            data = self.yaml.load(path_or_str)
        return data

    def validate(self, data: Dict[str, Any]) -> List[str]:
        errors: List[str] = []
        if "Screens" in data:
            for screen_name, screen_payload in data["Screens"].items():
                scr = self._parse_screen(screen_name, screen_payload)
                errors.extend(self.validator.validate_screen(scr))
        # TODO: components validation
        return errors

    # --------------------------------------------------------
    # Parsing helpers
    # --------------------------------------------------------

    def _parse_control_node(self, node_name: str, node_data: Dict[str, Any]) -> Control:
        control_type = node_data.get("Control", "Unknown")
        props = node_data.get("Properties", {})
        children_raw = node_data.get("Children", [])
        children: List[Control] = []
        for ch in children_raw:
            # each child is a dict with single key
            ch_name, ch_data = next(iter(ch.items()))
            children.append(self._parse_control_node(ch_name, ch_data))
        return Control(name=node_name, control_type=control_type, properties=props, children=children)

    def _parse_screen(self, name: str, payload: Dict[str, Any]) -> Screen:
        props = payload.get("Properties", {})
        children_raw = payload.get("Children", [])
        children: List[Control] = []
        for ch in children_raw:
            ch_name, ch_data = next(iter(ch.items()))
            children.append(self._parse_control_node(ch_name, ch_data))
        return Screen(name=name, properties=props, children=children)

    # --------------------------------------------------------
    # CLI helpers
    # --------------------------------------------------------

    def cli_validate(self, input_path: Union[str, Path]):
        data = self.load(input_path)
        errors = self.validate(data)
        if errors:
            print("Validation errors detected:\n")
            for err in errors:
                print(" -", err)
            sys.exit(1)
        print("No validation errors found ✅")


# ------------------------------------------------------------
# Demo usage
# ------------------------------------------------------------

def _demo():
    sample_yaml = """
Screens:
  HomeScreen:
    Properties:
      Fill: =RGBA(248, 250, 252, 1)
    Children:
      - MyRect:
          Control: Rectangle
          Properties:
            Width: 300  # <- invalid absolute value, but not yet flagged (TODO rule)
            RadiusTopLeft: 8  # forbidden
    """

    parser = PowerAppYAMLParser()
    data = parser.load(sample_yaml)
    errors = parser.validate(data)
    for e in errors:
        print(e)


if __name__ == "__main__":  # pragma: no cover
    if len(sys.argv) > 1:
        PowerAppYAMLParser().cli_validate(sys.argv[1])
    else:
        _demo() 