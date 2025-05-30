# PA2108 Error Fixes for Power Apps YAML

## Overview

PA2108 errors occur when you try to use a property that doesn't exist or isn't supported for a specific control type and variant in Power Apps. This document explains common PA2108 errors and how to fix them.

## 🚨 Common PA2108 Errors

### 1. GroupContainer with Event Properties

**Error Message**: `Unknown property 'OnSelect' for control type 'GroupContainer'`

**Problem**: GroupContainer controls cannot handle event properties like OnSelect, OnClick, OnHover, etc.

**Solution**: Replace GroupContainer with Rectangle control.

```yaml
# ❌ WRONG
- 'MyContainer':
    Control: GroupContainer
    Variant: ManualLayout
    Properties:
      OnSelect: =Navigate(NextScreen)  # PA2108 Error

# ✅ CORRECT
- 'MyContainer':
    Control: Rectangle
    Properties:
      OnSelect: =Navigate(NextScreen)  # Rectangle supports OnSelect
```

### 2. Gallery VariableHeight with WrapCount

**Error Message**: `Unknown property 'WrapCount' for control type 'Gallery' and variant 'VariableHeight'`

**Problem**: VariableHeight variant doesn't support WrapCount property.

**Solution**: Remove WrapCount property or use Horizontal/Vertical variants.

```yaml
# ❌ WRONG
- 'MyGallery':
    Control: Gallery
    Variant: VariableHeight
    Properties:
      WrapCount: =7  # PA2108 Error

# ✅ CORRECT - Option 1: Remove WrapCount
- 'MyGallery':
    Control: Gallery
    Variant: VariableHeight
    Properties:
      Items: =MyCollection

# ✅ CORRECT - Option 2: Use different variant
- 'MyGallery':
    Control: Gallery
    Variant: Horizontal
    Properties:
      WrapCount: =7  # Supported for Horizontal/Vertical
```

### 3. Classic/Button Invalid Properties

**Error Messages**: 
- `Unknown property 'BorderRadius' for control type 'Classic/Button'`
- `Unknown property 'Disabled' for control type 'Classic/Button'`
- `Unknown property 'Align' for control type 'Classic/Button'`

**Problem**: Classic/Button doesn't support some modern styling properties.

**Solution**: Use supported properties or alternatives.

```yaml
# ❌ WRONG
- 'MyButton':
    Control: Classic/Button
    Properties:
      BorderRadius: =8     # PA2108 Error
      Disabled: =true      # PA2108 Error  
      Align: =Align.Center # PA2108 Error

# ✅ CORRECT
- 'MyButton':
    Control: Classic/Button
    Properties:
      DisplayMode: =If(varIsDisabled, DisplayMode.Disabled, DisplayMode.Edit)
      # BorderRadius not available for Classic/Button
      # Use Fill and other styling properties instead
```

### 4. Rectangle Individual Corner Radius

**Error Messages**: 
- `Unknown property 'RadiusTopLeft' for control type 'Rectangle'`
- `Unknown property 'RadiusTopRight' for control type 'Rectangle'`
- etc.

**Problem**: Rectangle only supports uniform border radius, not individual corners.

**Solution**: Use BorderRadius for uniform radius.

```yaml
# ❌ WRONG
- 'MyRectangle':
    Control: Rectangle
    Properties:
      RadiusTopLeft: =8      # PA2108 Error
      RadiusTopRight: =8     # PA2108 Error
      RadiusBottomLeft: =8   # PA2108 Error
      RadiusBottomRight: =8  # PA2108 Error

# ✅ CORRECT
- 'MyRectangle':
    Control: Rectangle
    Properties:
      BorderRadius: =8  # Uniform radius for all corners
```

### 5. Classic/TextInput Invalid Properties

**Error Messages**:
- `Unknown property 'OnFocus' for control type 'Classic/TextInput'`
- `Unknown property 'OnBlur' for control type 'Classic/TextInput'`
- `Unknown property 'TextMode' for control type 'Classic/TextInput'`

**Problem**: Classic/TextInput has limited event support and different property names.

**Solution**: Use supported properties and correct names.

```yaml
# ❌ WRONG
- 'MyTextInput':
    Control: Classic/TextInput
    Properties:
      OnFocus: =Set(varFocused, true)   # PA2108 Error
      OnBlur: =Set(varFocused, false)   # PA2108 Error
      TextMode: =TextMode.Password      # PA2108 Error

# ✅ CORRECT
- 'MyTextInput':
    Control: Classic/TextInput
    Properties:
      Mode: =TextMode.Password  # Use Mode instead of TextMode
      # OnFocus/OnBlur not available for Classic/TextInput
      # Use content-based logic instead
```

## 🛠️ Automation Tools

### Scripts Available

1. **`fix_pa2108_properties.py`** - Comprehensive PA2108 fixer
2. **`fix_pa2108.bat`** - Windows batch runner
3. **`fix_groupcontainer_onselect.py`** - Specific GroupContainer fixes

### Running the Fixer

```bash
# Python script
python scripts/fix_pa2108_properties.py

# Windows batch file
scripts/fix_pa2108.bat
```

### What the Scripts Fix

- ✅ GroupContainer + OnSelect → Rectangle
- ✅ Gallery VariableHeight + WrapCount → Remove WrapCount
- ✅ Classic/Button + Invalid properties → Remove/Replace
- ✅ Rectangle + Individual corner radius → BorderRadius  
- ✅ Classic/TextInput + Invalid properties → Remove/Replace
- ✅ Automatic backup creation
- ✅ Detailed change logging

## 📋 Quick Reference Table

| Control Type | Forbidden Properties | Replacement | Note |
|--------------|---------------------|-------------|------|
| **GroupContainer** | OnSelect, OnClick, OnHover, OnChange | Use Rectangle | Rectangle supports events |
| **Gallery VariableHeight** | WrapCount | Remove property | Only Horizontal/Vertical support |
| **Classic/Button** | BorderRadius, Disabled, Align | DisplayMode for Disabled | Use modern styling alternatives |
| **Rectangle** | RadiusTopLeft, RadiusTopRight, etc. | BorderRadius | Uniform radius only |
| **Classic/TextInput** | OnFocus, OnBlur, TextMode | Mode for TextMode | Limited event support |

## 🔍 Manual Detection

To find PA2108 errors manually:

```bash
# Search for GroupContainer with OnSelect
grep -r "Control: GroupContainer" --include="*.yaml" -A 10 | grep "OnSelect"

# Search for Gallery VariableHeight with WrapCount  
grep -r "Variant: VariableHeight" --include="*.yaml" -A 10 | grep "WrapCount"

# Search for Classic/Button with BorderRadius
grep -r "Control: Classic/Button" --include="*.yaml" -A 10 | grep "BorderRadius"
```

## 🚀 Prevention

To avoid PA2108 errors:

1. **Follow Power App Rules** - Use the `.cursorrules` file guidelines
2. **Use Automation** - Run PA2108 fixer regularly
3. **Test Frequently** - Validate YAML in Power Apps Studio
4. **Reference Documentation** - Check Microsoft docs for supported properties
5. **Use Templates** - Copy from working examples

## 📚 Related Documentation

- [Power Apps Control Properties](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/reference-properties)
- [Gallery Control Documentation](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/controls/control-gallery)
- [Button Control Documentation](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/controls/control-button)
- [Power App Development Rules](.cursorrules)

## 🤝 Contributing

If you find new PA2108 errors not covered here:

1. Document the error message
2. Identify the root cause  
3. Provide the fix
4. Update the automation scripts
5. Add to this documentation 