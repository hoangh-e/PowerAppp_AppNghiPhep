# POWER APP RULES - SCRIPTS VALIDATION MATRIX

## 📋 MA TRẬN RULES VÀ SCRIPTS VALIDATION

### ✅ **SCRIPTS ĐÃ CÓ (7 scripts)**

| # | Rule Category | Script Name | Status | Mô tả |
|---|--------------|-------------|---------|-------|
| 1 | Icon Validation | `check_valid_icons.ps1` | ✅ Có | Kiểm tra icons hợp lệ từ approved list |
| 2 | TextMode Properties | `check_textmode_violations.ps1` | ✅ Có | Kiểm tra `TextMode:` → `Mode:` cho Classic/TextInput |
| 3 | Fixed Numbers | `check_fixed_numbers.ps1` | ✅ Có | Kiểm tra việc sử dụng fixed numbers |
| 4 | Comprehensive Rules | `validate_power_app_rules.ps1` | ✅ Có | Kiểm tra tổng hợp nhiều rules |
| 5 | Multi-line Formulas | `fix_multiline_formulas.ps1` | ✅ Có | Fix multi-line formulas → single line |
| 6 | Self Properties | `fix_self_properties.ps1` | ✅ Có | Fix invalid Self properties |
| 7 | Invalid Properties | `remove_invalid_properties.ps1` | ✅ Có | Remove invalid properties |

### ❌ **SCRIPTS THIẾU CẦN BỔ SUNG (15 scripts)**

| # | Rule Category | Script Needed | Priority | Mô tả chi tiết |
|---|--------------|---------------|----------|----------------|
| 1 | Component Structure | `check_component_definitions.ps1` | 🔴 CRITICAL | `ComponentDefinition:` → `ComponentDefinitions:` |
| 2 | Control Declarations | `check_component_controls.ps1` | 🔴 CRITICAL | `Control: ComponentName` → `Control: CanvasComponent` |
| 3 | Custom Properties | `check_custom_properties.ps1` | 🔴 CRITICAL | `PropertyType` → `PropertyKind`, `DefaultValue` → `Default` |
| 4 | Event Properties | `check_event_properties.ps1` | 🔴 CRITICAL | Event structure validation |
| 5 | Text Formatting | `check_text_formatting.ps1` | 🟡 MEDIUM | "Label: " → "Label:" & " " |
| 6 | Absolute Positioning | `check_absolute_positioning.ps1` | 🟠 HIGH | X: 100 → X: =Parent.X + 100 |
| 7 | Missing Properties | `check_required_properties.ps1` | 🟠 HIGH | X, Y, Width, Height for controls |
| 8 | YAML Syntax | `check_yaml_syntax.ps1` | 🔴 CRITICAL | Validate YAML parsing |
| 9 | Control References | `check_control_references.ps1` | 🟡 MEDIUM | 'Control.Name'.Property validation |
| 10 | Button Properties | `check_button_properties.ps1` | 🟠 HIGH | BorderRadius, Disabled for Classic/Button |
| 11 | Rectangle Properties | `check_rectangle_properties.ps1` | 🟠 HIGH | BorderRadius for Rectangle |
| 12 | Formula Length | `check_formula_length.ps1` | 🟡 MEDIUM | >120 chars without pipe operator |
| 13 | RGBA Text Functions | `check_rgba_text_functions.ps1` | 🟡 MEDIUM | Text(RGBA()) violations |
| 14 | PA2108 Errors | `check_pa2108_errors.ps1` | 🔴 CRITICAL | OnSelect for GroupContainer |
| 15 | Special Characters | `check_naming_conventions.ps1` | 🟡 MEDIUM | Single quotes for special names |

### 🔧 **RULES DẠI DIỆN KHÔNG SCRIPT ĐƯỢC (5 rules)**

| # | Rule Category | Validation Type | Mô tả |
|---|--------------|----------------|-------|
| 1 | Business Logic | Manual Review | OnSelect logic correctness |
| 2 | Visual Design | Visual Testing | Color scheme consistency |
| 3 | UX Patterns | Manual Testing | User experience flows |
| 4 | Performance | Runtime Testing | App performance metrics |
| 5 | Accessibility | Manual Review | Screen reader compatibility |

## 📊 THỐNG KÊ RULES COVERAGE

- **Total Rules trong .cursorrules**: ~50+ rules
- **Rules có thể script**: ~35 rules (70%)
- **Scripts đã có**: 7 scripts (20%)
- **Scripts cần bổ sung**: 15 scripts (50%)
- **Rules không script được**: 5 rules (10%)

## 🎯 ĐỀ XUẤT PRIORITY IMPLEMENTATION

### Phase 1: CRITICAL (4 scripts)
1. **`check_component_definitions.ps1`** - ComponentDefinition structure
2. **`check_component_controls.ps1`** - Control declarations
3. **`check_custom_properties.ps1`** - Custom properties structure
4. **`check_yaml_syntax.ps1`** - YAML parsing validation

### Phase 2: HIGH (3 scripts)
5. **`check_absolute_positioning.ps1`** - Absolute vs relative positioning
6. **`check_required_properties.ps1`** - Missing required properties
7. **`check_button_properties.ps1`** - Classic/Button property restrictions

### Phase 3: MEDIUM (8 scripts)
8. **`check_text_formatting.ps1`** - Text concatenation formatting
9. **`check_formula_length.ps1`** - Formula length validation
10. **`check_control_references.ps1`** - Control name references
11. **`check_rectangle_properties.ps1`** - Rectangle property restrictions
12. **`check_rgba_text_functions.ps1`** - RGBA in Text() functions
13. **`check_pa2108_errors.ps1`** - PA2108 error prevention
14. **`check_event_properties.ps1`** - Event property structure
15. **`check_naming_conventions.ps1`** - Naming convention validation

## 🚀 **AUTOMATION STRATEGY**

### Master Validation Script
Tạo **`validate_all_rules.ps1`** gọi tất cả scripts con:
```powershell
# Phase 1: CRITICAL
.\check_component_definitions.ps1
.\check_component_controls.ps1  
.\check_custom_properties.ps1
.\check_yaml_syntax.ps1

# Phase 2: HIGH
.\check_absolute_positioning.ps1
.\check_required_properties.ps1
.\check_button_properties.ps1

# Phase 3: MEDIUM + Existing
.\check_text_formatting.ps1
.\check_formula_length.ps1
.\check_valid_icons.ps1
.\check_textmode_violations.ps1
.\check_fixed_numbers.ps1
# ... etc
```

### CI/CD Integration
- Pre-commit hooks chạy validation
- GitHub Actions cho automated checking
- Report generation tự động

## 📈 **EXPECTED BENEFITS**

1. **Coverage**: 90% rules được automated
2. **Quality**: Consistent code quality 
3. **Speed**: Faster development cycles
4. **Reliability**: Fewer runtime errors
5. **Maintenance**: Easier codebase maintenance

---

**🎯 CONCLUSION: Cần implement 15 scripts mới để có coverage đầy đủ cho Power App rules validation! 🎯** 