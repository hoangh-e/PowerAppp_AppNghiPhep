"""Abstract base class for YAML handlers."""

from abc import ABC, abstractmethod
from typing import Dict, Any, Optional


class BaseYAMLHandler(ABC):
    """Abstract base class for all YAML handlers."""
    
    def __init__(self, data: Optional[Any] = None):
        self.data = data
    
    @abstractmethod
    def load_from_file(self, file_path: str) -> 'BaseYAMLHandler':
        """Load YAML data from file."""
        pass
    
    @abstractmethod
    def load_from_string(self, yaml_string: str) -> 'BaseYAMLHandler':
        """Load YAML data from string."""
        pass
    
    @abstractmethod
    def save_to_file(self, file_path: str) -> bool:
        """Save YAML data to file."""
        pass
    
    @abstractmethod
    def to_yaml_string(self) -> str:
        """Convert data to YAML string."""
        pass
    
    @abstractmethod
    def get_component_info(self) -> Dict[str, Any]:
        """Get component information."""
        pass
