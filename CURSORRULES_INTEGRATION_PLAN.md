# 📋 **KẾ HOẠCH TÍCH HỢP LUẬT MỚI VÀO CURSORRULES**

## **OVERVIEW**

Từ conversation với người dùng, đã phát hiện **15 luật mới (Luật 63-77)** cần bổ sung vào file .cursorrules để tránh các lỗi tương tự trong tương lai.

---

## 🎯 **LUẬT MỚI QUAN TRỌNG NHẤT**

### **Top 5 Luật Ưu Tiên Cao:**

1. **Luật 63: Unique DataTable Column Names** - Tránh PA2110 errors
2. **Luật 71: Action Properties Pipe Operator** - Luôn dùng | cho OnSelect/OnVisible
3. **Luật 73: DataTable Screen Children Only** - DataTable phải là direct children của Screen
4. **Luật 66: App-Component Isolation** - App globals không accessible trong Components
5. **Luật 76: SortOrder Enum Usage** - Dùng SortOrder.Descending thay vì "Descending"

---

## 📝 **VỊ TRÍ TÍCH HỢP TRONG .CURSORRULES**

### **Section 2: Control Rules**
- **Luật 73**: DataTable Screen Children Only

### **Section 3: Position & Size Rules**  
- **Luật 64**: Standard DataTable Positioning Pattern

### **Section 8: Common Mistakes**
- **Luật 63**: PA2110 Duplicate Control Names
- **Luật 67**: SharePoint Column Testing  
- **Luật 68**: SharePoint Table Name Conflicts
- **Luật 69**: Component Properties Optimization
- **Luật 71**: Action Properties Pipe Operator
- **Luật 72**: Unicode Character Restrictions
- **Luật 74**: DataTableColumn Reference Rules
- **Luật 75**: Component Event Binding Restrictions
- **Luật 76**: SortOrder Constants Usage

### **Section 9: Best Practices**
- **Luật 70**: Mandatory Layer Order for Screens

### **New Section: App Object Structure**
- **Luật 65**: App Properties File Organization
- **Luật 66**: App-Component Isolation Rules

### **New Section: URD Compliance**
- **Luật 77**: Chart Requirements Compliance

---

## 🔄 **CẬP NHẬT CRITICAL REMINDERS**

Cần cập nhật phần "CRITICAL REMINDERS" từ 62 items lên **77 items** với các luật mới:

```
63. **PA2110 DUPLICATE NAMES** - Use unique column names with prefixes for DataTables
64. **DATATABLE POSITIONING** - Follow standard positioning formula with Navigation + Content offsets
65. **APP PROPERTIES ORGANIZATION** - Separate App properties in src/App/ folder structure
66. **APP-COMPONENT ISOLATION** - App globals not accessible in Components, pass via properties
67. **SHAREPOINT COLUMN TESTING** - Test column behavior before assuming Choice/Lookup type
68. **SHAREPOINT TABLE CONFLICTS** - Use different global variable names to avoid ConnectedDataSource conflicts
69. **COMPONENT PROPERTIES OPTIMIZATION** - Only include necessary properties to avoid "Expected operator" errors
70. **MANDATORY LAYER ORDER** - Follow Background→Container→Content→Interactive→DataTable→Modal order
71. **ACTION PROPERTIES PIPE** - ALWAYS use pipe operator (|) for OnSelect, OnVisible, OnChange properties
72. **UNICODE RESTRICTIONS** - Never use emoji or special Unicode characters in YAML text values
73. **DATATABLE SCREEN CHILDREN** - DataTable must be direct children of Screens, never nested in containers
74. **DATATABLECOLUMN REFERENCES** - Use Parent.Selected in DataTableColumn context, not ThisItem
75. **COMPONENT EVENT BINDING** - Never call component events directly, use event binding pattern
76. **SORTORDER CONSTANTS** - Use SortOrder.Descending/Ascending, not plain text in SortByColumns
77. **URD CHART COMPLIANCE** - Include required ColumnChart and Export CSV functionality per URD requirements
```

---

## 📊 **IMPACT ASSESSMENT**

### **Lỗi Đã Được Giải Quyết:**
- ✅ PA2110: Duplicate control names (Luật 63)
- ✅ Expected operator errors (Luật 69)
- ✅ Component behavior invocation errors (Luật 75)
- ✅ SortOrder not recognized errors (Luật 76)
- ✅ Unicode character YAML parsing errors (Luật 72)

### **Cải Thiện Performance:**
- ✅ Chuẩn hóa DataTable positioning (Luật 64)
- ✅ Tối ưu Component properties (Luật 69)
- ✅ Proper z-index layering (Luật 70)

### **SharePoint Integration:**
- ✅ Column type testing methodology (Luật 67)
- ✅ Table name conflict avoidance (Luật 68)

### **App Architecture:**
- ✅ App object structure organization (Luật 65)
- ✅ Component isolation patterns (Luật 66)

---

## ⚡ **IMPLEMENTATION PRIORITY**

### **Immediate (High Priority):**
1. Luật 63: PA2110 fixes
2. Luật 71: Pipe operator for actions
3. Luật 73: DataTable positioning
4. Luật 76: SortOrder constants

### **Near-term (Medium Priority):**
5. Luật 66: App-Component isolation
6. Luật 69: Component optimization
7. Luật 72: Unicode restrictions
8. Luật 74: DataTableColumn references

### **Future (Lower Priority):**
9. Luật 65: App structure organization
10. Luật 70: Layer order standardization
11. Luật 77: URD compliance patterns

---

## 📋 **ACTION ITEMS**

1. **Update .cursorrules file** with 15 new rules
2. **Extend CRITICAL REMINDERS** from 62 to 77 items
3. **Add new sections** for App Object Structure and URD Compliance
4. **Document examples** for each new rule
5. **Test integration** with existing Power App development workflow

---

## 🏆 **EXPECTED OUTCOMES**

After integration:
- ✅ **Reduced PA2110 errors** by 100%
- ✅ **Improved SharePoint integration** reliability
- ✅ **Standardized DataTable patterns** across all screens
- ✅ **Enhanced Component architecture** with proper isolation
- ✅ **URD-compliant chart implementations**
- ✅ **Consistent YAML syntax** without Unicode issues

**Target: Zero Power App YAML errors in future development cycles.** 