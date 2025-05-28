# POWER APP DEVELOPMENT RULES FOR AI AGENT

> **CRITICAL**: Agent MUST follow these rules ABSOLUTELY when creating or modifying Power App YAML files.

---

## 📋 TABLE OF CONTENTS
1. [File Structure](mdc:#1-file-structure)
2. [Control Rules](mdc:#2-control-rules)
3. [Position & Size Rules](mdc:#3-position--size-rules)
4. [Allowed Controls](mdc:#4-allowed-controls)
5. [Properties Guidelines](mdc:#5-properties-guidelines)
6. [Naming Conventions](mdc:#6-naming-conventions)
7. [Common Mistakes](mdc:#7-common-mistakes)
8. [Best Practices](mdc:#8-best-practices)

---

## 1. FILE STRUCTURE

### 1.1 Screens (Màn hình)
**REQUIRED**: All screen files MUST start with `Screens:`

```yaml
Screens:
  ScreenName:
    Properties:
      Fill: =RGBA(248, 250, 252, 1)
      OnVisible: =Set(varExample, "value")
    Children:
      - ControlName:
          Control: ControlType
          Properties:
            # Control properties here
```

### 1.2 Components (Thành phần)
**REQUIRED**: All component files MUST use the CORRECT structure:

```yaml
# ✅ CORRECT - Component Definition Structure
ComponentDefinitions:
  ComponentName:
    DefinitionType: CanvasComponent
    CustomProperties:
      PropertyName:
        PropertyKind: Input
        DisplayName: PropertyName
        Description: "Property description"
        DataType: Text
        Default: ="Default value"
    Properties:
      Height: =App.Height
      Width: =App.Width
    Children:
      - ControlName:
          Control: ControlType
          Properties:
            # Control properties here

# ❌ WRONG - Old/Invalid Structure
ComponentDefinition:
  DefinitionType: CanvasComponent
  CustomProperties:
    - PropertyName:
        PropertyType: Data
        PropertyDataType: Text
        DefaultValue: ="Default"
```

### 1.3 Custom Properties Data Types
**ONLY** these data types are allowed for `DataType`:
- `Text` - String values
- `Number` - Numeric values  
- `Boolean` - True/false values
- `Date and time` - Date/time values
- `Screen` - Screen references
- `Record` - Single record
- `Table` - Data tables
- `Image` - Image data
- `Video or audio` - Media files
- `Color` - Color values
- `Currency` - Currency values

### 1.4 Custom Property Kinds
**ONLY** these property kinds are allowed for `PropertyKind`:
- `Input` - Input properties (most common)
- `Output` - Output properties
- `Event` - Event properties

### 1.4.1 Output Properties Restrictions
**CRITICAL**: Output properties have special restrictions:

```yaml
# ✅ CORRECT - Output Property (NO Default value)
PropertyName:
  PropertyKind: Output
  DisplayName: PropertyName
  Description: "Property description"
  DataType: Text
  # NO Default property allowed for Output

# ❌ WRONG - Output Property with Default (causes PA1003 error)
PropertyName:
  PropertyKind: Output
  DisplayName: PropertyName
  Description: "Property description"
  DataType: Text
  Default: ="Some value"  # ❌ FORBIDDEN for Output properties
```

**RULES for Output Properties**:
- ❌ **NEVER** use `Default` property with Output properties
- ❌ **NEVER** set default values for Output properties
- ✅ **ONLY** use `PropertyKind`, `DisplayName`, `Description`, `DataType`
- ✅ Output values must be calculated in component logic or child controls

### 1.4.2 Input Properties Requirements
**REQUIRED**: Input properties SHOULD have Default values:

```yaml
# ✅ CORRECT - Input Property with Default
PropertyName:
  PropertyKind: Input
  DisplayName: PropertyName
  Description: "Property description"
  DataType: Text
  Default: ="Default value"  # ✅ REQUIRED for Input properties

# ⚠️ ACCEPTABLE but not recommended - Input without Default
PropertyName:
  PropertyKind: Input
  DisplayName: PropertyName
  Description: "Property description"
  DataType: Text
  # Missing Default - will use system default
```

### 1.5 Event Properties Structure
**REQUIRED**: Event properties MUST follow this structure:

```yaml
# ✅ CORRECT - Event Property Structure
OnNavigate:
  PropertyKind: Event
  DisplayName: OnNavigate
  Description: "Event description"
  ReturnType: None
  Default: =
  Parameters:
    - ParameterName:
        Description: "Parameter description"
        DataType: Text
        IsOptional: true
        Default: ="Default value"

# ❌ WRONG - Invalid Event Structure
- OnNavigate:
    PropertyType: Event
    PropertyDataType: Text
    DefaultValue: =""
```

---

## 2. CONTROL RULES

### 2.1 Version Restriction
**FORBIDDEN**: Never include version numbers in Control declarations

```yaml
# ✅ CORRECT
Control: GroupContainer

# ❌ WRONG
Control: GroupContainer@1.3.0
```

### 2.2 Forbidden Properties
**NEVER USE** these properties:
- `ZIndex` - Not supported
- `DropShadow` - Use only when certain the control supports it

### 2.3 Forbidden Properties by Control Type
**Rectangle Control** - NEVER use these properties:
- `RadiusBottomLeft` - Not supported
- `RadiusBottomRight` - Not supported  
- `RadiusTopLeft` - Not supported
- `RadiusTopRight` - Not supported
- `BorderRadius` - **NOT SUPPORTED for Rectangle control**

**Classic/Button Control** - NEVER use these properties:
- `BorderRadius` - Not supported for Classic/Button
- `Disabled` - Use `DisplayMode` instead
- `Align` - Not supported for buttons
- `DropShadow` - **NOT SUPPORTED for Classic/Button control**

**GroupContainer Control** - NEVER use these properties:
- `BorderRadius` - **NOT SUPPORTED for GroupContainer with ManualLayout variant**
- `OnSelect` - **NOT SUPPORTED for GroupContainer with ManualLayout variant (PA2108 error)**

**Classic/TextInput Control** - NEVER use these properties:
- `Self.Focused` - Not recognized, use `Self.Focus` instead
- `Self.IsHovered` - Not recognized, use hover events instead

### 2.3.1 PA2108 Error - Invalid Properties for Control Types
**CRITICAL ERROR**: Using unsupported properties causes PA2108 error:

```yaml
# ❌ WRONG - Causes PA2108 Error
- 'Container.Name':
    Control: GroupContainer
    Variant: ManualLayout
    Properties:
      OnSelect: =SomeAction()  # ❌ FORBIDDEN - causes PA2108

# ✅ CORRECT - Use Button or other interactive control instead
- 'Container.Name':
    Control: GroupContainer
    Variant: ManualLayout
    Properties:
      # No OnSelect property for GroupContainer
    Children:
      - 'Interactive.Button':
          Control: Classic/Button
          Properties:
            OnSelect: =SomeAction()  # ✅ OK for Button controls
```

**ERROR MESSAGE**: `error PA2108 : Unknown property 'OnSelect' for control type 'GroupContainer' and variant 'ManualLayout'.`

**SOLUTION**: 
- Remove `OnSelect` from GroupContainer, OR
- Use interactive controls (Button, Icon) inside GroupContainer for click events

### 2.3.2 TextMode Property Restrictions
**CRITICAL**: TextMode property only accepts these values:

```yaml
# ✅ CORRECT - Valid TextMode values
- 'Input.Field':
    Control: Classic/TextInput
    Properties:
      TextMode: =TextMode.SingleLine  # Default single line input
      
- 'Input.Password':
    Control: Classic/TextInput
    Properties:
      TextMode: =TextMode.Password    # Password input (masked)
      
- 'Input.MultiLine':
    Control: Classic/TextInput
    Properties:
      TextMode: =TextMode.MultiLine   # Multi-line text area

# ❌ WRONG - Invalid TextMode values
- 'Input.Field':
    Control: Classic/TextInput
    Properties:
      TextMode: =TextMode.Email       # ❌ NOT SUPPORTED
      TextMode: =TextMode.Number      # ❌ NOT SUPPORTED
      TextMode: ="SingleLine"        # ❌ Use enumeration, not string
```

**VALID TextMode VALUES**:
- `TextMode.SingleLine` - Single line text input (default)
- `TextMode.MultiLine` - Multi-line text area
- `TextMode.Password` - Password input with masked characters

### 2.3.3 Invalid Self Property References
**CRITICAL ERROR**: Using invalid Self properties causes name recognition errors:

```yaml
# ❌ WRONG - Invalid Self property references
- 'Input.Field':
    Control: Classic/TextInput
    Properties:
      BorderColor: =If('Input.Field'.Focused, RGBA(0, 120, 212, 1), RGBA(200, 200, 200, 1))  # ❌ 'Focused' isn't recognized

# ✅ CORRECT - Use valid Self properties
- 'Input.Field':
    Control: Classic/TextInput
    Properties:
      BorderColor: =If(Self.Focus, RGBA(0, 120, 212, 1), RGBA(200, 200, 200, 1))  # ✅ Use Self.Focus instead

# ✅ ALTERNATIVE - Use control reference with valid properties
- 'Input.Field':
    Control: Classic/TextInput
    Properties:
      BorderColor: =If('Input.Field'.DisplayMode = DisplayMode.Edit, RGBA(0, 120, 212, 1), RGBA(200, 200, 200, 1))
```

**INVALID Self PROPERTIES**:
- `'ControlName'.Focused` - Use `Self.Focus` or focus events instead
- `'ControlName'.IsHovered` - Use hover events instead
- `'ControlName'.IsPressed` - Use press events instead

**VALID Self PROPERTIES**:
- `Self.Focus` - Focus state
- `Self.DisplayMode` - Display mode state
- `Self.Visible` - Visibility state
- `Self.Width` - Control width
- `Self.Height` - Control height

### 2.4 Required Properties for All Controls
Every control MUST have these properties when applicable:
- `X` - Horizontal position (relative to parent)
- `Y` - Vertical position (relative to parent)  
- `Width` - Control width (relative to parent)
- `Height` - Control height (relative to parent)

---

## 3. POSITION & SIZE RULES

### 3.1 Width and Height - MANDATORY RELATIVE POSITIONING
**NEVER** use absolute values. Always reference parent or other controls.

```yaml
# ✅ CORRECT Examples
Width: =Parent.Width * (3/2)
Height: =Parent.Height / 3
Width: =(Parent.Width - Control.Width) / 2
Height: =Self.Width

# ❌ WRONG Examples  
Width: 400
Height: 200
Width: =400
```

### 3.2 X and Y Positioning - MANDATORY RELATIVE POSITIONING
**ALWAYS** position relative to parent or other controls.

```yaml
# ✅ CORRECT Examples
X: =Parent.X /2
Y: =HeaderControl.Y + HeaderControl.Height
X: =(Parent.Width - Self.Width) / 2
Y: =Parent.Height - Self.Height 

# ❌ WRONG Examples
X: 100
Y: 50
```

### 3.3 Screen-Level Properties
For screens, use these specific properties:

```yaml
Properties:
  Fill: =RGBA(248, 250, 252, 1)
  # Width and Height are automatically handled by Power Apps
```

---

## 4. ALLOWED CONTROLS

### 4.1 Input Controls
```yaml
# Text Input
Control: Classic/TextInput

# Buttons  
Control: Classic/Button

# Date Selection
Control: Classic/DatePicker

# Dropdowns
Control: Classic/DropDown
Control: Classic/ComboBox

# Selection Controls
Control: Classic/CheckBox
Control: Classic/Radio
Control: Classic/Toggle
Control: Classic/Slider
Control: Rating
Control: PenInput
```

### 4.2 Display Controls
```yaml
# Text Display
Control: Label

# Media Display
Control: Image
Control: HtmlViewer
Control: RichTextEditor
Control: PDFViewer

# Icons
Control: Classic/Icon
```

### 4.2.1 Icon Control Rules
**CRITICAL**: Icon controls have specific restrictions:

#### Valid Icon Properties
```yaml
# ✅ CORRECT - Icon Control Structure
- 'Icon.Name':
    Control: Classic/Icon
    Properties:
      X: =Parent.X + 10
      Y: =Parent.Y + 10
      Width: =Parent.Height * 0.5
      Height: =Parent.Height * 0.5
      Icon: =Icon.ValidIconName  # Must use Icon enumeration
      Color: =RGBA(32, 54, 71, 1)
      Rotation: =0  # Optional rotation in degrees
```

#### Icon Enumeration - ONLY THESE ICONS ARE VALID
**CRITICAL**: Only use icons from the official Power Apps Icon enumeration:

**Navigation & Actions**:
- `Icon.Add` - Plus/Add icon
- `Icon.Cancel` - X/Cancel icon  
- `Icon.Check` - Checkmark icon
- `Icon.ChevronDown` - Down arrow
- `Icon.ChevronLeft` - Left arrow
- `Icon.ChevronRight` - Right arrow
- `Icon.ChevronUp` - Up arrow
- `Icon.Edit` - Edit/Pencil icon
- `Icon.Save` - Save/Disk icon
- `Icon.Delete` - Delete/Trash icon
- `Icon.Reload` - Refresh/Reload icon
- `Icon.Search` - Search/Magnifying glass
- `Icon.Filter` - Filter icon
- `Icon.Settings` - Settings/Gear icon
- `Icon.Home` - Home icon
- `Icon.Back` - Back arrow
- `Icon.Forward` - Forward arrow

**Communication & Media**:
- `Icon.Mail` - Email icon
- `Icon.Phone` - Phone icon
- `Icon.Bell` - Notification bell
- `Icon.Camera` - Camera icon
- `Icon.Microphone` - Microphone icon
- `Icon.Video` - Video icon

**Files & Documents**:
- `Icon.Document` - Document icon
- `Icon.Download` - Download arrow
- `Icon.Folder` - Folder icon
- `Icon.Print` - Print icon

**Calendar & Time**:
- `Icon.CalendarBlank` - Calendar icon
- `Icon.Clock` - Clock icon
- `Icon.Timer` - Timer icon

**People & Social**:
- `Icon.Person` - Person/User icon
- `Icon.People` - Multiple people icon
- `Icon.Contact` - Contact icon

**Status & Indicators**:
- `Icon.CheckBadge` - Check badge
- `Icon.Warning` - Warning triangle
- `Icon.Error` - Error icon
- `Icon.Information` - Info icon
- `Icon.Lock` - Lock icon
- `Icon.Unlock` - Unlock icon

**UI Elements**:
- `Icon.Menu` - Menu/Hamburger icon
- `Icon.HamburgerMenu` - Hamburger menu
- `Icon.MoreVertical` - Three dots vertical
- `Icon.DetailList` - List icon
- `Icon.Sync` - Sync icon

#### Icon Property Restrictions
**NEVER USE** these properties with Classic/Icon:
- `BorderRadius` - Not supported for icons
- `DropShadow` - Not supported for icons  
- `Fill` - Use `Color` instead
- `BorderColor` - Not supported for icons
- `BorderThickness` - Not supported for icons

#### Required Icon Properties
```yaml
# ✅ REQUIRED Properties for Classic/Icon
Properties:
  X: =Parent.X + 10          # Position relative to parent
  Y: =Parent.Y + 10          # Position relative to parent  
  Width: =Parent.Height * 0.5 # Size relative to parent
  Height: =Parent.Height * 0.5 # Size relative to parent
  Icon: =Icon.ValidName       # MUST use Icon enumeration
  Color: =RGBA(32, 54, 71, 1) # Icon color
```

#### Optional Icon Properties
```yaml
# ✅ OPTIONAL Properties for Classic/Icon
Properties:
  Rotation: =0               # Rotation in degrees (0-360)
  Visible: =true             # Visibility
  OnSelect: =Navigate(Screen) # Click action
```

### 4.3 Layout Controls
```yaml
# Containers
Control: GroupContainer
Control: Rectangle

# Data Display
Control: Gallery
Control: Form
Control: FormViewer
Control: DataTable
```

### 4.4 Shape Controls
```yaml
Control: Circle
Control: Triangle
Control: Pentagon
Control: Octagon
Control: Star
Control: Arrow
Control: PartialCircle
```

### 4.5 Chart Controls
```yaml
Control: BarChart
Control: LineChart
Control: PieChart
Control: Legend
```

### 4.6 Media & Data Controls
```yaml
# Media
Control: AddMedia
Control: Timer

# Data
Control: Import
Control: Export
Control: ListBox
Control: PowerBI
```

---

## 5. PROPERTIES GUIDELINES

### 5.1 Color Properties
**ALWAYS** use RGBA format:

```yaml
Fill: =RGBA(255, 255, 255, 1)
Color: =RGBA(32, 54, 71, 1)
BorderColor: =RGBA(230, 230, 230, 1)
```

### 5.2 DropShadow Properties
**ONLY** use these values and ONLY for supported controls:
```yaml
DropShadow: =DropShadow.Light
DropShadow: =DropShadow.Regular
DropShadow: =DropShadow.Bold
DropShadow: =DropShadow.ExtraBold
DropShadow: =DropShadow.Semilight
DropShadow: =DropShadow.None
```

**NEVER USE DropShadow for**:
- Classic/Button controls
- Any control that doesn't explicitly support it

### 5.3 Font Properties
```yaml
FontWeight: =FontWeight.Bold
FontWeight: =FontWeight.Semibold
FontWeight: =FontWeight.Normal
Font: =Font.'Open Sans'
```

### 5.4 Formula Properties
**ALL** dynamic properties MUST start with `=`:

```yaml
# ✅ CORRECT
Visible: =varShowControl
Text: =Concatenate("Hello ", varUserName)
Fill: =If(Self.IsHovered, RGBA(0, 120, 212, 1), RGBA(255, 255, 255, 1))

# ❌ WRONG
Visible: varShowControl
Text: "Static text" # Use this only for truly static text
```

### 5.5 Variants for Controls
```yaml
# GroupContainer
Variant: ManualLayout
Variant: AutoLayout

# Gallery
Variant: Vertical
Variant: Horizontal
Variant: VariableHeight

# Form
Variant: Classic

# Arrow
Variant: BackArrow

# Star
Variant: 5Points
Variant: 6Points
Variant: 8Points
Variant: 12Points
```

---

## 6. NAMING CONVENTIONS

### 6.1 Special Character Handling
**REQUIRED**: Wrap names with special characters in single quotes:

```yaml
# ✅ CORRECT - Names with special characters
- 'Header.Logo':
- 'Login Container':
- 'User-Info':
- 'Data View 1':
- 'My.Control.Name':

# ✅ CORRECT - Simple names (no quotes needed)
- HeaderLogo:
- LoginContainer:
- UserInfo:
```

### 6.2 Naming Best Practices
```yaml
# Use descriptive, hierarchical names
- 'Header.UserInfo.Avatar':
- 'LoginForm.UsernameInput':
- 'Dashboard.StatsCard.Title':
- 'Navigation.MenuButton':
```

---

## 7. COMMON MISTAKES TO AVOID

### 7.1 Component Definition Structure Errors
**CRITICAL**: Use the correct component structure:

```yaml
# ❌ WRONG - Old/Invalid Structure
ComponentDefinition:
  DefinitionType: CanvasComponent
  CustomProperties:
    - UserRole:
        PropertyType: Data
        PropertyDataType: Text
        DefaultValue: ="Employee"

# ✅ CORRECT - New/Valid Structure
ComponentDefinitions:
  NavigationComponent:
    DefinitionType: CanvasComponent
    CustomProperties:
      UserRole:
        PropertyKind: Input
        DisplayName: UserRole
        Description: "Vai trò của người dùng"
        DataType: Text
        Default: ="Employee"
    Properties:
      Height: =App.Height
      Width: =App.Width
```

### 7.2 Custom Properties Errors
**NEVER USE** these old property names:
- `PropertyType` → Use `PropertyKind`
- `PropertyDataType` → Use `DataType`
- `DefaultValue` → Use `Default`

**ALWAYS INCLUDE** these required fields:
- `DisplayName` - Human readable name
- `Description` - Property description
- `DataType` - Data type
- `Default` - Default value (for Input properties only)

### 7.2.1 PA1003 Error - Output Properties with Default Values
**CRITICAL ERROR**: Using `Default` with Output properties causes PA1003 error:

```yaml
# ❌ WRONG - Causes PA1003 Error
PrimaryColor:
  PropertyKind: Output
  DisplayName: PrimaryColor
  Description: "Màu chính"
  DataType: Color
  Default: =RGBA(59, 130, 246, 1)  # ❌ FORBIDDEN - causes PA1003

# ✅ CORRECT - Output Property without Default
PrimaryColor:
  PropertyKind: Output
  DisplayName: PrimaryColor
  Description: "Màu chính"
  DataType: Color
  # No Default property for Output

# ✅ ALTERNATIVE - Convert to Input Property
PrimaryColor:
  PropertyKind: Input  # Changed to Input
  DisplayName: PrimaryColor
  Description: "Màu chính"
  DataType: Color
  Default: =RGBA(59, 130, 246, 1)  # ✅ OK for Input properties
```

**ERROR MESSAGE**: `(line,column) : error PA1003 : The schema keyword 'Default' is not known or allowed in this context.`

**SOLUTION**: 
- Remove `Default` property from Output properties, OR
- Convert Output properties to Input properties if defaults are needed

### 7.3 Event Property Errors
**WRONG** event structure:
```yaml
# ❌ WRONG
- OnNavigate:
    PropertyType: Event
    PropertyDataType: Text
    DefaultValue: =""
```

**CORRECT** event structure:
```yaml
# ✅ CORRECT
OnNavigate:
  PropertyKind: Event
  DisplayName: OnNavigate
  Description: "Sự kiện khi chuyển màn hình"
  ReturnType: None
  Default: =
  Parameters:
    - ScreenName:
        Description: "Tên màn hình"
        DataType: Text
        IsOptional: true
        Default: ="Dashboard"
```

### 7.4 Event Call Syntax Errors
**WRONG** event call syntax:
```yaml
# ❌ WRONG
OnSelect: =NavigationComponent.OnNavigate; Set(varActiveScreen, "Dashboard")
```

**CORRECT** event call syntax:
```yaml
# ✅ CORRECT
OnSelect: =NavigationComponent.OnNavigate(); Set(varActiveScreen, "Dashboard")
```

### 7.5 Text Property Formatting
**CRITICAL**: Avoid spaces after colons in text content, especially in key-value pairs:

#### 7.5.1 Key-Value Pair Formatting
**NEVER** use spaces after colons in key-value text content:

```yaml
# ✅ CORRECT - No spaces after colons in key-value pairs
Text: =Concatenate("ShadowSM:DropShadow.Light;", "ShadowMD:DropShadow.Regular;", "ShadowLG:DropShadow.Bold;", "ShadowXL:DropShadow.ExtraBold")

# ❌ WRONG - Spaces after colons in key-value pairs
Text: =Concatenate("ShadowSM: DropShadow.Light;", "ShadowMD: DropShadow.Regular;", "ShadowLG: DropShadow.Bold;", "ShadowXL: DropShadow.ExtraBold")
```

#### 7.5.2 Design System Constants Formatting
**ALWAYS** format design system constants without spaces after colons:

```yaml
# ✅ CORRECT - Design system color constants
Text: |
  =Concatenate(
    "Primary:RGBA(59, 130, 246, 1);",
    "Secondary:RGBA(99, 102, 241, 1);",
    "Success:RGBA(34, 197, 94, 1);",
    "Warning:RGBA(251, 191, 36, 1);",
    "Danger:RGBA(239, 68, 68, 1)"
  )

# ❌ WRONG - Spaces after colons
Text: |
  =Concatenate(
    "Primary: RGBA(59, 130, 246, 1);",
    "Secondary: RGBA(99, 102, 241, 1);",
    "Success: RGBA(34, 197, 94, 1);",
    "Warning: RGBA(251, 191, 36, 1);",
    "Danger: RGBA(239, 68, 68, 1)"
  )
```

#### 7.5.3 Typography and Spacing Constants
**CONSISTENT** formatting for all design system constants:

```yaml
# ✅ CORRECT - Typography constants
Text: =Concatenate("TextXS:", Text(Parent.Height * 0.012), ";", "TextSM:", Text(Parent.Height * 0.014), ";", "TextBase:", Text(Parent.Height * 0.016))

# ✅ CORRECT - Spacing constants  
Text: =Concatenate("Space1:", Text(Parent.Width * 0.004), ";", "Space2:", Text(Parent.Width * 0.008), ";", "Space3:", Text(Parent.Width * 0.012))

# ✅ CORRECT - Border radius constants
Text: =Concatenate("RadiusNone:0;", "RadiusSM:", Text(Parent.Height * 0.002), ";", "RadiusMD:", Text(Parent.Height * 0.004))

# ❌ WRONG - Inconsistent spacing
Text: =Concatenate("TextXS: ", Text(Parent.Height * 0.012), ";", "TextSM: ", Text(Parent.Height * 0.014))
```

#### 7.5.4 General Text Content Rules
**STANDARD** text content can have spaces after colons:

```yaml
# ✅ CORRECT - Standard descriptive text (spaces allowed)
Text: ="Demo: Phần lớn của ứng dụng"
Text: ="Status: Đang chờ phê duyệt"
Text: ="Role: Quản lý nhân sự"

# ✅ CORRECT - Key-value data format (no spaces)
Text: ="UserID:EMP001;Name:Nguyễn Văn An;Role:Manager"

# ❌ WRONG - Mixed formatting in data strings
Text: ="UserID: EMP001;Name: Nguyễn Văn An;Role: Manager"
```

#### 7.5.5 Detection Rules for Text Formatting
**AUTOMATED DETECTION** patterns for text formatting violations:

```bash
# Detect spaces after colons in Concatenate key-value pairs
grep -n "Concatenate.*\".*: [^\"]*\"" src/**/*.yaml

# Detect inconsistent formatting in design system constants
grep -n "Text.*=.*Concatenate.*: [A-Z]" src/**/*.yaml
```

**VIOLATION PATTERNS**:
```yaml
# ❌ PATTERN 1: Space after colon in design constants
"Primary: RGBA(59, 130, 246, 1)"
"ShadowSM: DropShadow.Light"
"TextXS: "

# ❌ PATTERN 2: Mixed spacing in data strings
"Key1: Value1;Key2:Value2"

# ✅ CORRECT PATTERNS: Consistent formatting
"Primary:RGBA(59, 130, 246, 1)"
"ShadowSM:DropShadow.Light"
"TextXS:"
"Key1:Value1;Key2:Value2"
```

### 7.6 Absolute Positioning
**NEVER** use absolute values for positioning:

```yaml
# ❌ WRONG
X: 100
Y: 200
Width: 300
Height: 150

# ✅ CORRECT
X: =Parent.X + 20
Y: =PreviousControl.Y + PreviousControl.Height + 10
Width: =Parent.Width - 40
Height: =Parent.Height / 4
```

### 7.7 Missing Required Properties
**ALWAYS** include these for positioned controls:

```yaml
Properties:
  X: =Parent.X + 20
  Y: =Parent.Y + 10
  Width: =Parent.Width - 40
  Height: =40
  # Other properties...
```

### 7.8 Missing Component-Level Properties
**ALWAYS** include these for components:

```yaml
ComponentDefinitions:
  ComponentName:
    DefinitionType: CanvasComponent
    CustomProperties:
      # Custom properties here
    Properties:
      Height: =App.Height
      Width: =App.Width
    Children:
      # Child controls here
```

### 7.9 YAML Syntax for Multi-line Formulas
**CRITICAL**: Use correct YAML syntax for formulas:

#### For Short Formulas (Single Line):
```yaml
# ✅ CORRECT - Single line formula under 120 characters
OnSelect: =Set(varExample, true); Navigate(NextScreen)
```

#### For Long Formulas (Multi-line with Pipe Operator):
```yaml
# ✅ CORRECT - Multi-line formula with pipe operator
OnSelect: |
                    =Set(varIsLoading, true); Set(varLoginError, ""); If(And(Not(IsBlank('Login.Email.Input'.Text)), Not(IsBlank('Login.Password.Input'.Text))), Set(varCurrentUser, {ID: "EMP001", FullName: "Nguyễn Văn An", Email: 'Login.Email.Input'.Text, Role: "Employee", Department: "Phòng Công nghệ thông tin"}); Set(varIsLoading, false); Navigate(DashboardScreen), Set(varLoginError, "Email hoặc mật khẩu không đúng"); Set(varIsLoading, false))

# ❌ WRONG - Multi-line without pipe operator causes YAML parsing error
OnSelect: =Set(varIsLoading, true); Set(varLoginError, ""); 
          If(And(Not(IsBlank('Login.Email.Input'.Text)), Not(IsBlank('Login.Password.Input'.Text))), 
          Set(varCurrentUser, {ID: "EMP001", FullName: "Nguyễn Văn An", Email: 'Login.Email.Input'.Text, Role: "Employee", Department: "Phòng Công nghệ thông tin"}); 
          Set(varIsLoading, false); Navigate(DashboardScreen), 
          Set(varLoginError, "Email hoặc mật khẩu không đúng"); Set(varIsLoading, false))
```

#### For Concatenate Functions (Common Violation):
```yaml
# ✅ CORRECT - Concatenate with pipe operator
Text: |
  =Concatenate(
    "Primary: RGBA(59, 130, 246, 1);",
    "Secondary: RGBA(99, 102, 241, 1);",
    "Success: RGBA(34, 197, 94, 1)"
  )

# ❌ WRONG - Concatenate without pipe operator
Text: =Concatenate(
    "Primary: RGBA(59, 130, 246, 1);",
    "Secondary: RGBA(99, 102, 241, 1);",
    "Success: RGBA(34, 197, 94, 1)"
  )
```

**RULES for Multi-line Formulas:**
- **ALWAYS** use pipe operator (`|`) for formulas longer than 120 characters
- **ALWAYS** use pipe operator (`|`) for ANY multi-line formula regardless of length
- **ALWAYS** place the pipe operator (`|`) immediately after the property name and colon
- **ALWAYS** indent the formula content with proper spacing (typically 20 spaces)
- **NEVER** split formula without using pipe operator
- **ESPECIALLY** use for `OnSelect`, `OnChange`, `OnVisible`, `Text` with complex logic

### 7.9.1 Formula Length Detection
**CRITICAL**: Automated detection of formula length violations:

#### Detection Rules:
- **Single line > 120 characters**: MUST use pipe operator
- **Multi-line formula**: MUST use pipe operator regardless of length
- **Concatenate functions**: MUST use pipe operator if multi-line

#### Detection Scripts:
```bash
# Bash - Find formulas longer than 120 characters
grep -n "Text: =.*" src/**/*.yaml | awk 'length($0) > 130'

# Bash - Find multi-line formulas without pipe operator
grep -A 10 "Text: =.*(" src/**/*.yaml | grep -v "Text: |"

# PowerShell - Find long formulas
Get-Content "src/**/*.yaml" | Select-String "Text: =.*" | Where-Object {$_.Line.Length -gt 120}
```

#### Common Violation Patterns:
```yaml
# ❌ PATTERN 1: Long single-line Concatenate
Text: =Concatenate("A: ", value1, ";", "B: ", value2, ";", "C: ", value3, ";", "D: ", value4)

# ❌ PATTERN 2: Multi-line Concatenate without pipe
Text: =Concatenate(
  "Line 1",
  "Line 2",
  "Line 3"
)

# ❌ PATTERN 3: Long single-line formula
OnSelect: =Set(var1, value1); Set(var2, value2); Set(var3, value3); Navigate(Screen); UpdateContext({key: value})

# ✅ CORRECT: All above with pipe operator
Text: |
  =Concatenate("A: ", value1, ";", "B: ", value2, ";", "C: ", value3, ";", "D: ", value4)

Text: |
  =Concatenate(
    "Line 1",
    "Line 2", 
    "Line 3"
  )

OnSelect: |
  =Set(var1, value1); Set(var2, value2); Set(var3, value3); Navigate(Screen); UpdateContext({key: value})
```

### 7.10 Control Reference Errors
**CRITICAL**: Use single quotes for control names with dots:

```yaml
# ❌ WRONG - Dot operator error
Text: =LoginCard.FormSection.UsernameInput.Text

# ✅ CORRECT - Wrap in single quotes
Text: ='LoginCard.FormSection.UsernameInput'.Text
```

### 7.11 Invalid Self Properties
**NEVER USE** these invalid Self properties:

```yaml
# ❌ WRONG - Invalid Self properties
BorderColor: =If(Self.Focused, RGBA(0, 120, 212, 1), RGBA(200, 200, 200, 1))
Fill: =If(Self.IsHovered, RGBA(240, 240, 240, 1), RGBA(255, 255, 255, 1))

# ✅ CORRECT - Use valid properties or events
BorderColor: =If(Self.Focus, RGBA(0, 120, 212, 1), RGBA(200, 200, 200, 1))
# Use OnHover events instead of Self.IsHovered
```

### 7.12 Button Property Errors
**NEVER USE** these properties for Classic/Button:

```yaml
# ❌ WRONG - Invalid button properties
Properties:
  BorderRadius: =8        # Not supported for Classic/Button
  Disabled: =true         # Use DisplayMode instead
  Align: =Align.Center    # Not supported for buttons
  DropShadow: =DropShadow.Light  # Not supported for Classic/Button

# ✅ CORRECT - Valid button properties
Properties:
  DisplayMode: =If(varIsDisabled, DisplayMode.Disabled, DisplayMode.Edit)
  # BorderRadius not available for Classic/Button
  # DropShadow not available for Classic/Button
  # Use Fill and other styling properties instead
```

### 7.13 Rectangle Radius Errors
**NEVER USE** BorderRadius or individual corner radius properties for Rectangle:

```yaml
# ❌ WRONG - BorderRadius and individual corner radius not supported for Rectangle
Properties:
  BorderRadius: =8        # NOT SUPPORTED for Rectangle
  RadiusBottomLeft: =8    # NOT SUPPORTED for Rectangle
  RadiusBottomRight: =8   # NOT SUPPORTED for Rectangle
  RadiusTopLeft: =8       # NOT SUPPORTED for Rectangle
  RadiusTopRight: =8      # NOT SUPPORTED for Rectangle

# ✅ CORRECT - Use other styling properties for Rectangle
Properties:
  Fill: =RGBA(255, 255, 255, 1)
  BorderColor: =RGBA(229, 231, 235, 1)
  BorderThickness: =Parent.Height * 0.001
  # No radius properties available for Rectangle
```

### 7.14 GroupContainer BorderRadius Errors
**NEVER USE** BorderRadius for GroupContainer with ManualLayout:

```yaml
# ❌ WRONG - BorderRadius not supported for GroupContainer ManualLayout
- 'Container.Name':
    Control: GroupContainer
    Variant: ManualLayout
    Properties:
      BorderRadius: =8    # NOT SUPPORTED for GroupContainer ManualLayout

# ✅ CORRECT - Use other styling properties
- 'Container.Name':
    Control: GroupContainer
    Variant: ManualLayout
    Properties:
      Fill: =RGBA(255, 255, 255, 1)
      BorderColor: =RGBA(229, 231, 235, 1)
      BorderThickness: =Parent.Height * 0.001
      # No BorderRadius available for GroupContainer ManualLayout
```

---

## 8. BEST PRACTICES

### 8.1 Component Structure Best Practices
- Always use `ComponentDefinitions` (plural) as root
- Include component name as child of `ComponentDefinitions`
- Always include `Properties` section with `Height` and `Width`
- Use descriptive `DisplayName` and `Description` for all custom properties
- Group related custom properties logically

### 8.2 Custom Properties Best Practices
- Use `Input` for most custom properties
- Use `Event` for callback functions
- Use `Output` for computed values
- Always provide meaningful default values
- Include parameter definitions for event properties

### 8.3 Event Handling Best Practices
- Always call event properties with parentheses: `ComponentName.EventName()`
- Define parameters for events when needed
- Use `ReturnType: None` for most events
- Mark optional parameters with `IsOptional: true`

### 8.4 Multi-line Formula Best Practices
- Use pipe operator (`|`) for formulas longer than 120 characters
- Maintain consistent indentation (20 spaces recommended)
- Keep the entire formula logic on the indented line after the pipe
- Use for complex `OnSelect`, `OnChange`, `OnVisible` properties

### 8.5 Consistency
- Use consistent naming patterns across similar controls
- Apply consistent spacing and sizing formulas
- Use consistent color schemes (RGBA values)

### 8.6 Relative References
**ALWAYS** use relative references:
```yaml
# Parent references
Width: =Parent.Width - 80
X: =Parent.X + 20

# Self references  
Height: =Self.Size * 1.2

# Other control references
Y: =HeaderControl.Y + HeaderControl.Height + 10
```

### 8.7 Hierarchy Maintenance
- Maintain clear parent-child relationships
- Use logical grouping with GroupContainer
- Keep related controls together in the YAML structure

### 8.8 Property Organization
Organize properties in this order:
1. Position (X, Y)
2. Size (Width, Height)  
3. Visual (Fill, Color, BorderColor)
4. Behavior (OnSelect, OnChange)
5. Content (Text, Items)
6. Other properties

```yaml
Properties:
  X: =Parent.X + 20
  Y: =Parent.Y + 10
  Width: =Parent.Width - 40
  Height: =40
  Fill: =RGBA(255, 255, 255, 1)
  Color: =RGBA(32, 54, 71, 1)
  BorderColor: =RGBA(230, 230, 230, 1)
  OnSelect: =Navigate(NextScreen)
  Text: ="Click me"
  FontWeight: =FontWeight.Semibold
```

---

## 🚨 CRITICAL REMINDERS

1. **CORRECT COMPONENT STRUCTURE** - Use `ComponentDefinitions` with proper custom property syntax
2. **NO ABSOLUTE VALUES** - Everything must be relative
3. **WRAP SPECIAL NAMES** - Use single quotes for names with special characters
4. **FORMULA PREFIX** - All dynamic properties start with `=`
5. **RGBA COLORS** - Always use RGBA format for colors
6. **RELATIVE POSITIONING** - Position everything relative to parent or other controls
7. **EVENT SYNTAX** - Call events with parentheses: `ComponentName.EventName()`
8. **CUSTOM PROPERTIES** - Use `PropertyKind`, `DataType`, `Default` (not old syntax)
9. **MULTI-LINE FORMULAS** - Use pipe operator (`|`) for long formulas (>120 chars)
10. **CONTROL REFERENCES** - Wrap control names with dots in single quotes
11. **VALID SELF PROPERTIES** - Never use `Self.Focused` or `Self.IsHovered`
12. **BUTTON PROPERTIES** - Never use `BorderRadius`, `Disabled`, `Align`, or `DropShadow` for Classic/Button
13. **RECTANGLE PROPERTIES** - Never use `BorderRadius` or individual corner radius properties for Rectangle
14. **GROUPCONTAINER PROPERTIES** - Never use `BorderRadius` for GroupContainer with ManualLayout variant
15. **DROPSHADOW RESTRICTIONS** - Only use DropShadow for controls that explicitly support it (NOT Classic/Button)
16. **PA1003 ERROR PREVENTION** - NEVER use `Default` property with Output properties (causes PA1003 error)
17. **ICON ENUMERATION** - ONLY use valid icons from Icon enumeration (Icon.Add, Icon.Search, etc.)
18. **ICON PROPERTIES** - Never use BorderRadius, DropShadow, Fill, BorderColor with Classic/Icon controls
19. **FORMULA LENGTH DETECTION** - Use automated scripts to detect formulas >120 chars without pipe operator
20. **CONCATENATE FUNCTIONS** - ALWAYS use pipe operator for multi-line Concatenate functions
21. **YAML SYNTAX VALIDATION** - Validate YAML syntax before deployment to prevent parsing errors
22. **TEXT FORMATTING CONSISTENCY** - NEVER use spaces after colons in key-value pairs (e.g., "Key:Value" not "Key: Value")
23. **PA2108 ERROR PREVENTION** - NEVER use `OnSelect` with GroupContainer ManualLayout (causes PA2108 error)
24. **TEXTMODE RESTRICTIONS** - ONLY use TextMode.SingleLine, TextMode.MultiLine, TextMode.Password
25. **INVALID SELF PROPERTIES** - NEVER use `'ControlName'.Focused` - use `Self.Focus` or focus events instead

**Agent must follow these rules ABSOLUTELY when generating Power App YAML code.** 