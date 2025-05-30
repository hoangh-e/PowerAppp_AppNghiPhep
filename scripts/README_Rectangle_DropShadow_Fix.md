# Rectangle DropShadow Property Fix

## 🚨 **PA2108 Error Discovered**

User reported PA2108 errors:
```
(66,21) : error PA2108 : Unknown property 'DropShadow' for control type 'Rectangle'.
(133,21) : error PA2108 : Unknown property 'DropShadow' for control type 'Rectangle'.
```

## 📋 **Problem Analysis**

**Rectangle controls in Power Apps do NOT support DropShadow property**

### ❌ **Invalid Code:**
```yaml
- 'MyContainer':
    Control: Rectangle
    Properties:
      DropShadow: =DropShadow.Light  # PA2108 Error!
      Fill: =RGBA(255, 255, 255, 1)
```

### ✅ **Correct Code:**
```yaml
- 'MyContainer':
    Control: Rectangle
    Properties:
      Fill: =RGBA(255, 255, 255, 1)
      BorderColor: =RGBA(230, 230, 230, 1)
      BorderThickness: =1
      # Use BorderColor/BorderThickness for visual effects
```

## 🔧 **Solution Implemented**

### 1. **Manual Fix**
- ✅ Fixed `src/Screens/AttachmentScreen.yaml`
- ✅ Removed DropShadow from 2 Rectangle controls:
  - `'Attachment.Upload.Container'` at line 66
  - `'Attachment.List.Container'` at line 133

### 2. **Automated Scripts Created**
- `scripts/fix_rectangle_dropshadow.py` - Advanced script with control name detection
- `scripts/simple_dropshadow_fix.py` - Simple regex-based approach
- `scripts/fix_all_rectangle_dropshadow.py` - Comprehensive project-wide fix

### 3. **Rules Updated**
- ✅ Updated `.cursorrules` file
- ✅ Added `DropShadow` to Rectangle forbidden properties
- ✅ Added PA2108 error example and fix
- ✅ Added to Critical Reminders (#20)

## 📊 **Impact Assessment**

### **Files Affected:**
Based on grep search, potentially dozens of files contain Rectangle + DropShadow combinations:
- Components: NavigationComponent, LoadingComponent, HeaderComponent, etc.
- Screens: ReportsScreen, ProfileScreen, ManagementScreen, etc.

### **Search Results Summary:**
```
- 64+ YAML files scanned
- Multiple Rectangle controls with DropShadow properties found
- Manual fix completed for AttachmentScreen.yaml
- Automated scripts ready for project-wide fixes
```

## 🛠️ **Alternative Solutions**

If visual shadow effects are needed, consider:

### **1. GroupContainer with DropShadow**
```yaml
- 'ShadowContainer':
    Control: GroupContainer
    Variant: ManualLayout
    Properties:
      DropShadow: =DropShadow.Light  # ✅ Supported!
    Children:
      - 'InnerRectangle':
          Control: Rectangle
          Properties:
            Fill: =RGBA(255, 255, 255, 1)
```

### **2. Border Effects**
```yaml
- 'VisualContainer':
    Control: Rectangle
    Properties:
      BorderColor: =RGBA(200, 200, 200, 1)
      BorderThickness: =2
      Fill: =RGBA(255, 255, 255, 1)
```

### **3. Multiple Rectangles for Shadow Effect**
```yaml
- 'ShadowLayer':
    Control: Rectangle
    Properties:
      Fill: =RGBA(0, 0, 0, 0.1)
      X: =Parent.X + 2
      Y: =Parent.Y + 2
      
- 'ContentLayer':
    Control: Rectangle
    Properties:
      Fill: =RGBA(255, 255, 255, 1)
      X: =Parent.X
      Y: =Parent.Y
```

## 🚀 **Next Steps**

1. **Run project-wide fix:**
   ```bash
   python scripts/fix_all_rectangle_dropshadow.py
   ```

2. **Review and test** all fixed files

3. **Consider design alternatives** for shadow effects

4. **Update design system** to avoid Rectangle + DropShadow combinations

## ✅ **Rules Established**

**Rectangle Control** - FORBIDDEN properties:
- ❌ `DropShadow` - Not supported
- ❌ `Variant` - Not supported  
- ❌ `RadiusTopLeft/Right/BottomLeft/Right` - Not supported

**Use instead:**
- ✅ `BorderRadius` for uniform corners
- ✅ `BorderColor` + `BorderThickness` for visual effects
- ✅ `GroupContainer` with DropShadow for shadow effects

---

*Fix completed manually for: AttachmentScreen.yaml*
*Automated scripts ready for project-wide implementation* 