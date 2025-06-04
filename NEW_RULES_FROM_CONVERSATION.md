# 🆕 **LUẬT MỚI CẦN BỔ SUNG VÀO POWER APP RULES**

## **TỪ CONVERSATION VỚI NGƯỜI DÙNG**

Dựa trên quá trình làm việc và debugging, đã phát hiện các luật mới quan trọng cần bổ sung:

---

## 🚨 **PA2110 ERROR FIXES - DUPLICATE CONTROL NAMES**

### **Luật 63: Unique Control Names Across DataTables**
**CRITICAL**: Each DataTable must have unique column names to avoid PA2110 errors.

```yaml
# ❌ WRONG - Duplicate column names between DataTables
# Users DataTable
- 'MaDonVi: TenDonVi_Column':  # Line 1415
    Control: DataTableColumn

# Workflow DataTable  
- 'MaDonVi: TenDonVi_Column':  # Line 1701 - PA2110 ERROR: Same name!
    Control: DataTableColumn

# ✅ CORRECT - Unique names with prefixes
# Users DataTable
- 'Users.MaDonVi: TenDonVi_Column':
    Control: DataTableColumn

# Workflow DataTable
- 'Workflow.MaDonVi: TenDonVi_Column':
    Control: DataTableColumn
```

**MANDATORY NAMING PATTERN:**
- `Users.ColumnName_Column` for Users DataTable
- `Workflow.ColumnName_Column` for Workflow DataTable
- `Reports.ColumnName_Column` for Reports DataTable
- `LeaveBalance.ColumnName_Column` for LeaveBalance DataTable

---

## 📍 **DATATABLE POSITIONING STANDARDS**

### **Luật 64: Standard DataTable Positioning Pattern**
**CRITICAL**: DataTables must follow this exact positioning formula:

```yaml
# Standard DataTable positioning pattern
Properties:
  X: ='Management.Navigation'.Width + 'Management.Content.Padded'.X
  Y: ='Management.Content.Container'.Y + 'Management.Content.Padded'.Y + 'Management.TabContent.Container'.Y + 'Management.Header'.Height
  Width: ='Management.Content.Padded'.Width
  Height: =Calculated responsive height based on container
```

**COMPONENTS OF POSITIONING:**
- `X`: Navigation width + content padding offset
- `Y`: Content container Y + padded Y + tab content Y + header height
- `Width`: Full padded content width
- `Height`: Responsive calculation based on available space

---

## 🏗️ **APP OBJECT STRUCTURE RULES**

### **Luật 65: App Properties File Organization**
**CRITICAL**: App properties must be organized in separate files within `src/App/` folder.

#### **Required App Files:**
```
src/App/
├── BackEnabled
├── ConfirmExit
├── ConfirmExitMessage
├── Formulas
├── MinScreenHeight
├── MinScreenWidth
├── OnError
├── OnMessage
├── OnStart
├── SizeBreakpoints
├── StartScreen
└── Theme
```

#### **App/Formulas Content Rules:**
```yaml
# ✅ CORRECT - Global variables and functions in Formulas
//Navigation menu items
MenuItems = Table(
  {Id:1, Name: "Trang chủ", Screen: HomePage, Image: Icon.Home}
);

//Global styles
Styles = {
  Title: {
    Font: Font.'Segoe UI',
    Size: 24,
    Color: ColorValue("#0078D4")
  }
};

//Permission checking function
CheckPermission(UserPerm:Number, RequiredPerm:Number):Boolean = (
  Mod(Int(UserPerm / RequiredPerm), 2) = 1
);

# ❌ WRONG - Complex function definitions not supported
FunctionName(param:Text):Boolean = (
  If(param = "test", Set(varTest, true); true, false)
);
```

#### **App/OnStart Content Rules:**
```yaml
# ✅ CORRECT - Lightweight initialization only
Set(varAppVersion, "1.0.0");
Set(varCurrentUser, LookUp(Users, Email = User().Email));
Set(varAppInitialized, true)

# ❌ WRONG - Heavy data loading in OnStart
Set(varAllUsers, Users);
Set(varAllDepartments, Departments);
Set(varAllProjects, Projects)
```

---

## 🔗 **APP-COMPONENT ISOLATION RULES**

### **Luật 66: App Global Access Restrictions**
**CRITICAL**: App global variables and functions are ONLY accessible within App and Screens.

#### **App Globals NOT Accessible in Components:**
- `User`, `MenuItems`, `Styles`, `Quyền`, `Vai_Trò`
- `CheckPermission()`, `GetStatusValue()`, etc.
- `UserHasGDPerm`, `UserHasQLPerm`, etc.

#### **Required Data Passing Pattern:**
```yaml
# ✅ CORRECT - Pass App data to Component via properties
# In Screen:
- MyComponentInstance:
    Control: CanvasComponent
    ComponentName: MyComponent
    Properties:
      UserRole: =User.Role              # Pass App data
      HasPermission: =UserHasGDPerm     # Pass App computed value
      ButtonStyle: =Styles.Button       # Pass App style

# In Component Definition:
ComponentDefinitions:
  MyComponent:
    CustomProperties:
      UserRole:
        PropertyKind: Input
        DataType: Text
        Default: ="Employee"
      HasPermission:
        PropertyKind: Input
        DataType: Boolean
        Default: =false
    Children:
      - MyButton:
          Properties:
            Visible: =MyComponent.HasPermission  # Use component property
            Text: =MyComponent.UserRole          # Use passed data
```

---

## 📊 **SHAREPOINT INTEGRATION ENHANCED RULES**

### **Luật 67: SharePoint Column Type Testing**
**CRITICAL**: Always test column behavior before assuming Lookup/Choice type.

```yaml
# Testing pattern - if error occurs, it's TEXT column
Text: =ThisItem.MaVaiTro.Value  # If error: "The '.' operator cannot be used on Text values"
# Then use: Text: =ThisItem.MaVaiTro (no .Value)

# ✅ CORRECT - Text columns (NO .Value needed)
Text: =ThisItem.MaVaiTro & " - " & ThisItem.MaDonVi
Text: =ThisItem.HoTen & " (" & ThisItem.Email & ")"

# ✅ CORRECT - Choice/Lookup columns (REQUIRES .Value)
Text: =ThisItem.TrangThai.Value & " - " & ThisItem.ChucDanh.Value
Text: =ThisItem.'MaDonVi: TenDonVi'.Value
```

### **Luật 68: SharePoint Table Name Conflicts**
**CRITICAL**: Avoid naming global variables same as SharePoint list names.

```yaml
# ❌ WRONG - Conflicts with SharePoint tables
VaiTro = {Admin: "Administrator"};  # Conflicts with "VaiTro" table
Quyen = {View: 1, Create: 2};       # Conflicts with "Quyen" table

# ✅ CORRECT - Use different names
UserRoles = {Admin: "Administrator"};
UserPermissions = {View: 1, Create: 2};
```

---

## 🎯 **COMPONENT OPTIMIZATION RULES**

### **Luật 69: Component Properties Optimization**
**CRITICAL**: Only include necessary custom properties to avoid "Expected operator" errors.

```yaml
# ❌ WRONG - Too many unnecessary properties
- MyComponent:
    Control: CanvasComponent
    ComponentName: StatsCardComponent
    Properties:
      Color: =RGBA(251, 191, 36, 1)
      MaxValue: =100              # May not be needed
      OnClick: =                  # Empty value causes issues
      ShowProgress: =false        # May not be needed
      Subtitle: =""              # Empty string causes issues
      TrendValue: =0             # May not be needed

# ✅ CORRECT - Only essential properties
- MyComponent:
    Control: CanvasComponent
    ComponentName: StatsCardComponent
    Properties:
      X: =0
      Y: =0
      Width: =200
      Height: =Parent.Height
      Title: ="Status"
      Value: =42
      Color: =RGBA(251, 191, 36, 1)
```

---

## 📐 **Z-INDEX AND LAYERING ENHANCED RULES**

### **Luật 70: Mandatory Layer Order for Screens**
**CRITICAL**: Controls must be declared in this exact order for proper z-index:

#### **Layer Order (First = Bottom, Last = Top):**
1. **Background Elements** (Rectangle backgrounds)
2. **Container Elements** (GroupContainer layouts)
3. **Content Elements** (Labels, Images, static content)
4. **Interactive Elements** (Buttons, Inputs)
5. **DataTable Elements** (Must be direct Screen children)
6. **Modal/Overlay Elements** (Last = highest z-index)

```yaml
# ✅ CORRECT - Proper layer order
Children:
  # Layer 1: Background
  - 'Screen.Background':
      Control: Rectangle
      
  # Layer 2: Containers  
  - 'Content.Container':
      Control: GroupContainer
      
  # Layer 3: Content
  - 'Title.Label':
      Control: Label
      
  # Layer 4: Interactive
  - 'Action.Button':
      Control: Classic/Button
      
  # Layer 5: DataTable (direct Screen child)
  - 'Data.Table':
      Control: DataTable
      
  # Layer 6: Modals (highest)
  - 'Modal.Container':
      Control: GroupContainer
```

---

## 🔧 **YAML SYNTAX ENHANCED RULES**

### **Luật 71: Action Properties Pipe Operator**
**CRITICAL**: ALWAYS use pipe operator (|) for ALL action properties.

```yaml
# ✅ CORRECT - Always use pipe for action properties
OnVisible: |
  =Set(varActiveScreen, "Dashboard")
  
OnSelect: |
  =Set(varIsLoading, true); Navigate(NextScreen)
  
OnChange: |
  =Set(varInputValue, Self.Text)

# ❌ WRONG - Single line action properties can cause parsing issues
OnVisible: =Set(varActiveScreen, "Dashboard"); Set(varUser, User())
OnSelect: =Set(varIsLoading, true); Navigate(NextScreen)
```

### **Luật 72: Unicode Character Restrictions**
**CRITICAL**: Never use emoji or special Unicode characters in YAML.

```yaml
# ❌ WRONG - Unicode characters cause "invalid mapping" errors
Text: ="👤 Người dùng"    # Emoji causes parsing error
Text: ="📊 Thống kê"     # Emoji causes parsing error
Text: ="User•Profile"    # Special bullet character
Text: ="Data→Analysis"   # Arrow character

# ✅ CORRECT - Standard text only
Text: ="Người dùng"      # Text only
Text: ="Thống kê"        # Text only  
Text: ="User - Profile"  # Standard punctuation
Text: ="Data Analysis"   # Standard space
```

---

## 🏗️ **DATATABLE ENHANCED RULES**

### **Luật 73: DataTable Screen Children Only**
**CRITICAL**: DataTable controls must be direct children of Screens ONLY.

```yaml
# ✅ CORRECT - DataTable as direct Screen child
Screens:
  MyScreen:
    Children:
      - MyDataTable:
          Control: DataTable
          Properties:
            Items: =MyDataSource

# ❌ WRONG - DataTable nested in containers
Screens:
  MyScreen:
    Children:
      - Container:
          Control: GroupContainer
          Children:
            - MyDataTable:  # ERROR - Cannot nest DataTable
                Control: DataTable
```

### **Luật 74: DataTableColumn Reference Rules**
**CRITICAL**: In DataTableColumn context, use `Parent.Selected` for selected record.

```yaml
# ✅ CORRECT - Parent.Selected in DataTableColumn
- ActionColumn:
    Control: DataTableColumn
    Properties:
      OnSelect: |
        =Set(varSelectedItem, Parent.Selected)  # Gets DataTable selected record

# ❌ WRONG - ThisItem not available in DataTableColumn
- ActionColumn:
    Control: DataTableColumn
    Properties:
      OnSelect: |
        =Set(varSelectedItem, ThisItem)  # ERROR - ThisItem not available
```

---

## 🔄 **COMPONENT EVENT BINDING RULES**

### **Luật 75: Component Event Binding Restrictions**
**CRITICAL**: Never call component events directly from screens.

```yaml
# ❌ WRONG - Direct component event calls cause errors
- MyComponent:
    Control: CanvasComponent
    ComponentName: NavigationComponent
    Properties:
      OnNavigate: ='MyComponent'.OnNavigate(); Set(varAction, true)  # ERROR

# ✅ CORRECT - Bind actions to component events
- MyComponent:
    Control: CanvasComponent
    ComponentName: NavigationComponent
    Properties:
      OnNavigate: |
        =Set(varAction, true)  # Bind action to event
```

---

## 📊 **SORTORDER CONSTANTS RULE**

### **Luật 76: SortOrder Enum Usage**
**CRITICAL**: Use SortOrder enum constants, not plain text.

```yaml
# ❌ WRONG - Plain text not recognized
Items: =SortByColumns(MyCollection, "FieldName", Descending)
Items: =SortByColumns(MyCollection, "FieldName", "Descending")

# ✅ CORRECT - Use SortOrder enum
Items: =SortByColumns(MyCollection, "FieldName", SortOrder.Descending)
Items: =SortByColumns(MyCollection, "FieldName", SortOrder.Ascending)
```

---

## 🎨 **URD COMPLIANCE RULES**

### **Luật 77: Chart Requirements Compliance**
Based on URD document analysis, ReportsScreen must include:

#### **Required Charts:**
1. **Column Chart**: "Biểu đồ cột thể hiện tổng nghỉ phép trong năm theo tháng"
2. **Advanced Filters**: Multiple report types (Monthly, Department, Employee)
3. **Export CSV**: Export functionality for chart data

#### **Implementation Pattern:**
```yaml
# Required ColumnChart for URD compliance
- 'Reports.Chart.Column':
    Control: ColumnChart
    Properties:
      ChartType: =ChartType.ColumnClustered
      Items: =varReportData
      Visible: =CountRows(varReportData) > 0

# Required Export functionality
- 'Reports.Export.Button':
    Control: Classic/Button
    Properties:
      OnSelect: |
        =Export(varReportData, 
          Concatenate("BaoCao_", varReportType, "_", Text(Today(), "yyyymmdd"), ".csv"))
```

---

## 🎨 **DATATABLE UI OPTIMIZATION RULES**

### **Luật 78: DataTable UI Consistency**
**CRITICAL**: All DataTables within the same screen must have consistent positioning and styling patterns.

#### **Standard DataTable Properties Template:**
```yaml
# Template for consistent DataTable styling
Control: DataTable
Variant: DataTable
Properties:
  BorderColor: =RGBA(203, 213, 225, 1)
  BorderThickness: =2
  Color: =RGBA(15, 23, 42, 1)
  Fill: =RGBA(255, 255, 255, 1)
  Font: =Font.'Open Sans'
  HeadingColor: =RGBA(255, 255, 255, 1)
  HeadingFill: =[TAB_SPECIFIC_COLOR]  # Different color per tab
  HeadingFont: =Font.'Open Sans'
  HeadingFontWeight: =FontWeight.Bold
  HeadingSize: =13
  Size: =12
  # Positioning calculated consistently
  X: ='Management.Navigation'.Width + 'Management.Content.Padded'.X
  Y: ='Management.Content.Container'.Y + 'Management.Content.Padded'.Y + 'Management.TabContent.Container'.Y + 'Management.[Tab].Header'.Height
  Width: ='Management.Content.Padded'.Width
  Height: ='Management.[Tab].Container'.Height + ('Management.Content.Padded'.Height - Self.Y - 'Management.[Tab].Container'.Height)
```

#### **HeadingFill Color Standards by Tab:**
```yaml
# Color differentiation for different tabs
Users DataTable:     HeadingFill: =RGBA(30, 58, 138, 1)   # Blue
LeaveBalance:        HeadingFill: =RGBA(5, 150, 105, 1)   # Green  
Holidays:            HeadingFill: =RGBA(217, 119, 6, 1)   # Orange
Workflow:            HeadingFill: =RGBA(126, 34, 206, 1)  # Purple
Reports:             HeadingFill: =RGBA(239, 68, 68, 1)   # Red
```

#### **Height Formula Fix:**
```yaml
# ✅ CORRECT - Use Self.Y for height calculation
Height: ='Management.[Tab].Container'.Height + ('Management.Content.Padded'.Height - Self.Y - 'Management.[Tab].Container'.Height)

# ❌ WRONG - Self.X is wrong coordinate
Height: ='Management.[Tab].Container'.Height + ('Management.Content.Padded'.Height - Self.X - 'Management.[Tab].Container'.Height)
```

#### **Responsive HoverFill Standards:**
```yaml
# HoverFill colors matching tab theme
Users:        HoverFill: =RGBA(241, 245, 249, 1)  # Light blue
LeaveBalance: HoverFill: =RGBA(240, 253, 244, 1)  # Light green
Holidays:     HoverFill: =RGBA(255, 251, 235, 1)  # Light orange
Workflow:     HoverFill: =RGBA(250, 245, 255, 1)  # Light purple
```

---

## 🚨 **YAML SYNTAX ERROR PREVENTION**

### **Luật 79: Multiline Formula YAML Syntax**
**CRITICAL**: All multiline formulas (including Text properties) must use pipe operator (`|`) to prevent PA1001 YamlInvalidSyntax errors.

#### **PA1001 Error: "While scanning a plain scalar value, found invalid mapping"**

```yaml
# ❌ WRONG - Multiline formula without pipe operator causes PA1001
Text: =Switch(varReportType,
  "Monthly", Concatenate("Tổng: ", Sum(varReportData, SoDon), " đơn"),
  "Department", Concatenate("Tổng: ", Sum(varReportData, TongNhanVien), " nhân viên"),
  "Employee", Concatenate("Tổng: ", CountRows(varReportData), " nhân viên"),
  "")

# ✅ CORRECT - Use pipe operator for multiline formulas
Text: |
  =Switch(varReportType,
    "Monthly", Concatenate("Tổng: ", Sum(varReportData, SoDon), " đơn"),
    "Department", Concatenate("Tổng: ", Sum(varReportData, TongNhanVien), " nhân viên"),
    "Employee", Concatenate("Tổng: ", CountRows(varReportData), " nhân viên"),
    "")
```

#### **All Properties Requiring Pipe Operator:**
- **Action Properties**: OnVisible, OnSelect, OnChange, OnHover (existing rule)
- **Display Properties**: Text, Tooltip when multiline
- **Conditional Properties**: Visible, Fill when complex
- **Any Formula**: >120 characters or multiple lines

#### **Prevention Pattern:**
```yaml
# Simple formulas - single line OK
Text: =Concatenate("Hello ", UserSession.HoTen)
Visible: =varShowControl

# Complex formulas - MUST use pipe operator
Text: |
  =Switch(condition, 
    "case1", "result1",
    "case2", "result2", 
    "default")

OnSelect: |
  =Set(var1, value1); Set(var2, value2); Navigate(NextScreen)
```

**DETECTION**: Any multiline formula without `|` will cause PA1001 "invalid mapping" error.

---

## 🏆 **FINAL CRITICAL RULES SUMMARY**

**NEW RULES TO ADD TO MAIN RULES (Numbers 63-78):**

63. **Unique DataTable Column Names** - Avoid PA2110 with prefixes
64. **Standard DataTable Positioning** - Exact positioning formula
65. **App Properties File Organization** - Separate files in src/App/
66. **App-Component Isolation** - Pass data via properties
67. **SharePoint Column Testing** - Test before assuming type
68. **SharePoint Table Name Conflicts** - Use different global variable names
69. **Component Properties Optimization** - Only necessary properties
70. **Mandatory Layer Order** - Proper z-index control order
71. **Action Properties Pipe** - Always use | for OnSelect/OnVisible/OnChange
72. **Unicode Character Restrictions** - No emojis in YAML
73. **DataTable Screen Children Only** - Direct Screen children only
74. **DataTableColumn References** - Use Parent.Selected
75. **Component Event Binding** - No direct event calls
76. **SortOrder Enum Usage** - Use SortOrder constants
77. **URD Chart Compliance** - Required charts and export features
78. **DataTable UI Consistency** - Consistent positioning and styling
79. **Multiline Formula YAML Syntax** - Use pipe operator for multiline formulas

**These rules must be integrated into the main Power App rules file to prevent future errors.**

---

## 📊 **CHART CONTROL PROPERTY RESTRICTIONS**

### **Luật 80: Chart Control Valid Properties**
**CRITICAL**: Chart controls in Power Apps have limited supported properties.

#### **PA2101 Error: Unknown control type 'ColumnChart'**
```yaml
# ❌ WRONG - ColumnChart does not exist
Control: ColumnChart

# ✅ CORRECT - Use BarChart for column charts
Control: BarChart
```

#### **PA2108 Errors: Invalid Chart Properties**
```yaml
# ❌ WRONG - These properties are NOT supported for charts
Properties:
  XAxis: ="FieldName"           # NOT supported
  YAxis: ="FieldName"           # NOT supported  
  Title: ="Chart Title"         # NOT supported
  ShowLabels: =true             # NOT supported
  LabelAxis: ="FieldName"       # NOT supported (PieChart)
  ValueAxis: ="FieldName"       # NOT supported (PieChart)
  ChartType: =ChartType.ColumnClustered  # NOT supported

# ✅ CORRECT - Valid chart properties only
Properties:
  X: =Parent.Width * 0.02
  Y: =Parent.Height * 0.28
  Width: =Parent.Width * 0.96
  Height: =Parent.Height * 0.68
  Items: =varReportData         # Data source
  Fill: =RGBA(59, 130, 246, 1)  # Chart color
  Visible: =varShowChart        # Visibility control
```

#### **Valid Chart Control Types:**
- `Control: BarChart` - For column/bar charts
- `Control: LineChart` - For line charts  
- `Control: PieChart` - For pie charts
- `Control: Legend` - For chart legends

#### **Chart Data Binding:**
Charts automatically use the first suitable fields from Items collection. No manual axis binding required.

---

## 🔧 **COMPONENT PROPERTY RESTRICTIONS**

### **Luật 81: Component Custom Property Names**
**CRITICAL**: Component properties must match the component's custom property definitions.

#### **PA2108 Error: Unknown property for canvas component**
```yaml
# ❌ WRONG - BackgroundColor not defined in StatsCardComponent
- MyStatsCard:
    Control: CanvasComponent
    ComponentName: StatsCardComponent
    Properties:
      BackgroundColor: =RGBA(59, 130, 246, 1)  # PA2108 ERROR

# ✅ CORRECT - Use Color if defined in component
- MyStatsCard:
    Control: CanvasComponent
    ComponentName: StatsCardComponent
    Properties:
      Color: =RGBA(59, 130, 246, 1)  # Must match component definition
```

#### **Component Property Validation Rules:**
1. **Check Component Definition**: Verify custom properties in ComponentDefinitions
2. **Match Property Names**: Use exact property names from component definition
3. **Use Required Properties**: Include all required custom properties
4. **Standard Properties**: X, Y, Width, Height always valid for components

#### **Example Component Property Mapping:**
```yaml
# Component Definition
ComponentDefinitions:
  StatsCardComponent:
    CustomProperties:
      Title:
        PropertyKind: Input
        DataType: Text
      Value:
        PropertyKind: Input 
        DataType: Text
      Icon:
        PropertyKind: Input
        DataType: Text
      Color:          # NOT BackgroundColor
        PropertyKind: Input
        DataType: Color

# Usage - must match definition
- MyCard:
    Control: CanvasComponent
    ComponentName: StatsCardComponent
    Properties:
      Title: ="Total"     # ✅ Matches definition
      Value: ="42"        # ✅ Matches definition
      Icon: ="Home"       # ✅ Matches definition
      Color: =RGBA(...)   # ✅ Matches definition (not BackgroundColor)
```

---

## 📊 **DATATABLE EMPTY STATE HANDLING**

### **Luật 82: DataTable Data Source Fallback**
**CRITICAL**: DataTables must have fallback demo data for preview when SharePoint sources are empty.

#### **Empty State Problem:**
```yaml
# ❌ WRONG - DataTable shows empty when SharePoint not available
Properties:
  Items: =NgayLe  # Empty when SharePoint not connected
  NoDataText: ="Không có dữ liệu"

# ✅ CORRECT - Fallback to demo data for preview
Properties:
  Items: =If(IsEmpty(NgayLe), varHolidaysList, NgayLe)  # Demo data fallback
  NoDataText: ="Không có dữ liệu ngày nghỉ lễ. Vui lòng thêm ngày lễ mới."
```

#### **Demo Data Requirements:**
1. **Sufficient Records**: At least 5-10 demo records
2. **Realistic Data**: Use actual business data examples
3. **Date Formatting**: Use proper date strings ("2024-01-01")
4. **Vietnamese Content**: Use Vietnamese holiday names and descriptions
5. **Multiple Data Types**: Include various field types (text, dates, choices)

#### **Column Text Handling:**
```yaml
# Smart field mapping for demo vs SharePoint data
Text: |
  =If(IsEmpty(NgayLe), 
    ThisItem.TenNgayLe,  # Demo data field
    If(IsBlank(ThisItem.TenNgayLe), 
      ThisItem.Title,    # SharePoint fallback field
      ThisItem.TenNgayLe)) # SharePoint primary field
```

#### **Data Source Patterns:**
- **Users**: `If(IsEmpty(NguoiDung), varAllUsers, NguoiDung)`
- **Departments**: `If(IsEmpty(DonVi), varAllDepartments, DonVi)`
- **Holidays**: `If(IsEmpty(NgayLe), varHolidaysList, NgayLe)`
- **Leave Balance**: `If(IsEmpty(SoNgayPhep), varLeaveBalanceData, SoNgayPhep)`
- **Workflow**: `If(IsEmpty(QuyTrinhDuyet), varWorkflowData, QuyTrinhDuyet)`

#### **Enhanced NoDataText Messages:**
```yaml
# Provide helpful guidance in empty state
NoDataText: ="Không có dữ liệu ngày nghỉ lễ. Vui lòng thêm ngày lễ mới."
NoDataText: ="Chưa có người dùng nào. Vui lòng thêm người dùng từ tab quản lý."
NoDataText: ="Không có dữ liệu số ngày phép. Vui lòng import file Excel."
```

**PURPOSE**: Ensure DataTables always show meaningful content for better user experience and easier development/testing.

---

## 🔗 **DATATABLE COLUMN TEXT BINDING**

### **Luật 83: Simple Column Text Binding**
**CRITICAL**: DataTable column Text properties should use simple field references to avoid [object Object] display.

#### **[object Object] Display Problem:**
When mixing demo data (text fields) with SharePoint data (object fields), complex conditional logic can cause display issues.

```yaml
# ❌ WRONG - Complex conditional logic causes [object Object]
Text: |
  =If(IsEmpty(NgayLe),
    ThisItem.Buoi,  # Demo data: text field
    Switch(Text(ThisItem.Buoi.Value),  # SharePoint: object field
      "CaNgay", "Cả ngày",
      ThisItem.Buoi.Value))

# Result: [object Object] when data source switches

# ✅ CORRECT - Simple field reference with consistent data structure
Text: |
  =Switch(Text(ThisItem.Buoi), 
    "CaNgay", "Cả ngày", 
    "Sang", "Sáng", 
    "Chieu", "Chiều",
    "Cả ngày")
```

#### **Best Practices:**
1. **Consistent Data Structure**: Ensure demo data matches SharePoint field structure
2. **Simple Field Access**: Use `ThisItem.FieldName` directly without complex conditions
3. **Text Conversion**: Always wrap in `Text()` function for display
4. **Default Values**: Provide fallback values for Switch statements

#### **Column Text Patterns:**
```yaml
# Text fields
Text: =ThisItem.TenNgayLe  # Direct field access

# Date fields with formatting
Text: =Text(DateValue(ThisItem.Ngay), "dd/mm/yyyy")

# Number fields
Text: =Text(ThisItem.Nam)

# Choice/Enum fields with translation
Text: |
  =Switch(Text(ThisItem.Buoi), 
    "CaNgay", "Cả ngày", 
    "Sang", "Sáng", 
    "Chieu", "Chiều",
    "Default Value")
```

#### **Data Source Consistency:**
Ensure demo data structure matches SharePoint expectations:
```yaml
# Demo data should match SharePoint field types
Set(varHolidaysList, Table(
  {TenNgayLe: "Text", Ngay: "2024-01-01", Nam: 2024, Buoi: "CaNgay"}  # Text values
));

# NOT mixed types like:
{TenNgayLe: "Text", Ngay: Date(2024,1,1), Nam: 2024, Buoi: {Value: "CaNgay"}}  # Mixed types
```

**PURPOSE**: Eliminate [object Object] displays and ensure consistent data presentation across demo and production data.

---

## 📋 **TABLE FORMAT MATCHING**

### **Luật 84: Exact Table Format Compliance**
**CRITICAL**: When user provides specific table format requirements, match exactly including column order, naming, and data structure.

#### **Format Matching Requirements:**
1. **Column Order**: Must match user's specified sequence exactly
2. **Column Names**: Use exact field names from user requirements  
3. **Data Structure**: Demo data must reflect real data structure
4. **Display Format**: Match visual formatting (date format, text casing)
5. **Remove Unwanted Columns**: Remove any columns not in user's specification

#### **Implementation Pattern:**
```yaml
# User specifies format: MaNgayLe, Ngay, TenNgayLe, Buoi, Nam
# Remove Actions column

# ✅ CORRECT - Match exact order and naming
Children:
  - HolidayId_Column:         # Order: 1, matches MaNgayLe
      FieldDisplayName: ="MaNgayLe"
      Order: =1
  - HolidayDate_Column:       # Order: 2, matches Ngay  
      FieldDisplayName: ="Ngay"
      Order: =2
  - HolidayName_Column:       # Order: 3, matches TenNgayLe
      FieldDisplayName: ="TenNgayLe" 
      Order: =3
  - HolidaySession_Column:    # Order: 4, matches Buoi
      FieldDisplayName: ="Buoi"
      Order: =4
  - HolidayYear_Column:       # Order: 5, matches Nam
      FieldDisplayName: ="Nam"
      Order: =5
  # Actions column removed per user request

# ❌ WRONG - Different order or extra columns
Children:
  - HolidayName_Column:       # Wrong: TenNgayLe should be 3rd
      Order: =1
  - HolidayActions_Column:    # Wrong: Actions column not wanted
      Order: =6
```

#### **Data Structure Alignment:**
```yaml
# Demo data must match expected structure exactly
Set(varHolidaysList, Table(
  {MaNgayLe: 1, Ngay: "01/01", TenNgayLe: "Tết Dương lịch", Nam: 2024, Buoi: "CaNgay"},
  {MaNgayLe: 2, Ngay: "08/02", TenNgayLe: "Tết Nguyên đán (28 Tết)", Nam: 2024, Buoi: "CaNgay"}
  # Detailed names matching user's format
));
```

#### **Format Consistency Rules:**
- **Date Format**: Match user's display preference (dd/mm vs dd/mm/yyyy)
- **Text Casing**: "Cả Ngày" vs "Cả ngày" - match user's preference
- **Field Width**: Adjust column widths for content (320px for long names)
- **Field Types**: Number columns for IDs/years, Text for names/dates

#### **User Feedback Integration:**
When user shows screenshots or specific format requests:
1. **Analyze Visual**: Extract exact column order and naming
2. **Match Data**: Ensure demo data reflects the structure
3. **Remove Extras**: Eliminate any columns not shown/wanted
4. **Verify Display**: Ensure text formatting matches expectations

**PURPOSE**: Ensure delivered tables match user's exact requirements and expectations, improving user satisfaction and reducing revision requests.

--- 