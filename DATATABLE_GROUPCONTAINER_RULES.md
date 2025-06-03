# 🚨 DATATABLE & GROUPCONTAINER CRITICAL RULES

## Rule 57: DataTable Screen Children Only
**CRITICAL**: DataTable controls MUST be direct Children of Screens ONLY. Never nest DataTable inside GroupContainer or other containers.

### ✅ CORRECT - DataTable as direct Screen child
```yaml
Screens:
  MyScreen:
    Children:
      - MyDataTable:
          Control: DataTable@1.0.3
          Variant: DataTable
          Properties:
            X: =Parent.Width * 0.03
            Y: =Parent.Height * 0.3  
            Items: =MyDataSource
          Children:
            - ColumnName:
                Control: DataTableColumn@1.0.1
                Variant: Textual
                Properties:
                  FieldDisplayName: ="Display Name"
                  FieldName: ="FieldName"
                  Order: =1
                  Text: =ThisItem.FieldName
```

### ❌ WRONG - DataTable nested in containers
```yaml
Screens:
  MyScreen:
    Children:
      - Container:
          Control: GroupContainer
          Children:
            - MyDataTable:  # ERROR - Cannot nest DataTable
                Control: DataTable@1.0.3
```

## Rule 58: GroupContainer BorderRadius Restriction  
**CRITICAL**: GroupContainer controls do NOT support BorderRadius property. PA2108 error will occur.

### ❌ WRONG - GroupContainer with BorderRadius
```yaml
- Container:
    Control: GroupContainer
    Properties:
      BorderRadius: =8        # PA2108 ERROR
```

### ✅ CORRECT - GroupContainer without BorderRadius
```yaml
- Container:
    Control: GroupContainer
    Properties:
      BorderThickness: =1
      BorderColor: =RGBA(226, 232, 240, 1)
      # NO BorderRadius property
```

## Summary of Changes Made
1. **MyLeavesScreen.yaml**: Moved DataTable out of GroupContainer to direct Screen Children
2. **MyLeavesScreen.yaml**: Removed all BorderRadius properties from GroupContainer controls
3. **Structure Fixed**: DataTable now positioned relative to Screen (Y: =Parent.Height * 0.3)
4. **Compliance**: All PA2108 errors resolved

**Agent must follow these NEW rules ABSOLUTELY when generating Power App YAML code.** 