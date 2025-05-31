"""Enums for PowerApp YAML components."""

from enum import Enum


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


class ControlType(str, Enum):
    """Enum cho Control Types"""
    LABEL = "Label"
    BUTTON = "Classic/Button"
    TEXT_INPUT = "Classic/TextInput"
    RECTANGLE = "Rectangle"
    GROUP_CONTAINER = "GroupContainer"
    GALLERY = "Gallery"
    ICON = "Classic/Icon"
    IMAGE = "Image"
