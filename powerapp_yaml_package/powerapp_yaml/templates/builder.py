"""Template builder for PowerApp components."""

from typing import Dict, Any, List, Optional
from ..models.enums import PropertyKind, DataType


class TemplateBuilder:
    """Builder class for creating PowerApp component templates."""
    
    def __init__(self) -> None:
        self.templates: Dict[str, Any] = {}
    
    def create_button_template(
        self,
        text_property: bool = True,
        variant_property: bool = True,
        on_click_event: bool = True
    ) -> str:
        """Create a button component template."""
        
        template = """
ComponentDefinitions:
  ButtonComponent:
    DefinitionType: CanvasComponent
    CustomProperties:"""
        
        if text_property:
            template += """
      Text:
        PropertyKind: Input
        DisplayName: Text
        Description: "Button text"
        DataType: Text
        Default: ="Click me" """
        
        if variant_property:
            template += """
      Variant:
        PropertyKind: Input
        DisplayName: Variant
        Description: "Button variant: Primary, Secondary, Danger"
        DataType: Text
        Default: ="Primary" """
        
        if on_click_event:
            template += """
      OnClick:
        PropertyKind: Event
        DisplayName: OnClick
        Description: "Button click event"
        ReturnType: None
        Default: =false """
        
        template += """
    Properties:
      Height: =App.Height
      Width: =App.Width
    Children:
      - 'Button.Main':
          Control: Classic/Button
          Properties:
            X: =Parent.X
            Y: =Parent.Y
            Width: =Parent.Width * 0.2
            Height: =Parent.Height * 0.06
            Text: =ButtonComponent.Text
            Fill: =RGBA(33, 150, 243, 1)
            Color: =RGBA(255, 255, 255, 1)
            OnSelect: =ButtonComponent.OnClick()
"""
        
        return template
    
    def create_card_template(
        self,
        title_property: bool = True,
        content_property: bool = True,
        actions: Optional[List[str]] = None
    ) -> str:
        """Create a card layout template."""
        
        actions = actions or []
        
        template = """
ComponentDefinitions:
  CardComponent:
    DefinitionType: CanvasComponent
    CustomProperties:"""
        
        if title_property:
            template += """
      Title:
        PropertyKind: Input
        DisplayName: Title
        Description: "Card title"
        DataType: Text
        Default: ="Card Title" """
        
        if content_property:
            template += """
      Content:
        PropertyKind: Input
        DisplayName: Content
        Description: "Card content"
        DataType: Text
        Default: ="Card content goes here..." """
        
        for action in actions:
            template += f"""
      On{action.capitalize()}:
        PropertyKind: Event
        DisplayName: On{action.capitalize()}
        Description: "{action.capitalize()} action event"
        ReturnType: None
        Default: =false """
        
        template += """
    Properties:
      Height: =App.Height
      Width: =App.Width
    Children:
      - 'Card.Container':
          Control: Rectangle
          Properties:
            X: =Parent.X
            Y: =Parent.Y
            Width: =Parent.Width * 0.4
            Height: =Parent.Height * 0.3
            Fill: =RGBA(255, 255, 255, 1)
            BorderColor: =RGBA(230, 230, 230, 1)
            BorderThickness: =1
            BorderRadius: =8
"""
        
        return template
