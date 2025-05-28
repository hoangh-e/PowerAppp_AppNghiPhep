#!/bin/bash

echo "🔍 POWER APP FORMULA COMPLIANCE CHECKER"
echo "======================================="
echo ""

violations=0
total_files=0

# Find all YAML files
for file in $(find src -name "*.yaml" -type f); do
    total_files=$((total_files + 1))
    file_violations=0
    
    echo "Checking: $file"
    
    # Check for long Text formulas without pipe operator
    while IFS= read -r line; do
        line_length=${#line}
        if [[ $line =~ Text:.*= ]] && [[ $line_length -gt 120 ]] && [[ ! $line =~ Text:.*\| ]]; then
            echo "❌ Long Text formula without pipe operator ($line_length chars)"
            violations=$((violations + 1))
            file_violations=$((file_violations + 1))
        fi
        
        # Check for Concatenate without pipe
        if [[ $line =~ Text:.*=.*Concatenate\( ]] && [[ ! $line =~ Text:.*\| ]]; then
            echo "❌ Concatenate without pipe operator"
            violations=$((violations + 1))
            file_violations=$((file_violations + 1))
        fi
        
        # Check for long OnSelect formulas
        if [[ $line =~ OnSelect:.*= ]] && [[ $line_length -gt 120 ]] && [[ ! $line =~ OnSelect:.*\| ]]; then
            echo "❌ Long OnSelect formula without pipe operator ($line_length chars)"
            violations=$((violations + 1))
            file_violations=$((file_violations + 1))
        fi
        
        # Check for spaces after colons in key-value pairs (design system constants)
        if [[ $line =~ Concatenate.*\"[A-Za-z]+:\ [A-Z] ]]; then
            echo "❌ Space after colon in key-value pair (design system constants)"
            violations=$((violations + 1))
            file_violations=$((file_violations + 1))
        fi
        
        # Check for spaces after colons in Shadow/Color constants
        if [[ $line =~ \"(Shadow|Color|Text|Space|Radius)[A-Z]*:\ [A-Z] ]]; then
            echo "❌ Space after colon in design system constant"
            violations=$((violations + 1))
            file_violations=$((file_violations + 1))
        fi
        
        # NEW: Check for OnSelect in GroupContainer (PA2108 error)
        if [[ $line =~ OnSelect: ]] && grep -B 10 "$line" "$file" | grep -q "Control: GroupContainer"; then
            echo "❌ PA2108 Error: OnSelect not supported for GroupContainer"
            violations=$((violations + 1))
            file_violations=$((file_violations + 1))
        fi
        
        # NEW: Check for invalid TextMode values
        if [[ $line =~ TextMode:.*= ]] && [[ ! $line =~ TextMode\.SingleLine|TextMode\.MultiLine|TextMode\.Password ]]; then
            echo "❌ Invalid TextMode value - only SingleLine, MultiLine, Password allowed"
            violations=$((violations + 1))
            file_violations=$((file_violations + 1))
        fi
        
        # NEW: Check for invalid Self properties (.Focused)
        if [[ $line =~ \'[^\']*\'\.Focused ]]; then
            echo "❌ Invalid Self property: 'ControlName'.Focused - use Self.Focus instead"
            violations=$((violations + 1))
            file_violations=$((file_violations + 1))
        fi
        
        # NEW: Check for other invalid Self properties
        if [[ $line =~ \'[^\']*\'\.IsHovered ]] || [[ $line =~ \'[^\']*\'\.IsPressed ]]; then
            echo "❌ Invalid Self property: Use hover/press events instead"
            violations=$((violations + 1))
            file_violations=$((file_violations + 1))
        fi
    done < "$file"
    
    if [[ $file_violations -eq 0 ]]; then
        echo "✅ No violations"
    fi
    echo ""
done

echo "📊 SUMMARY"
echo "=========="
echo "Total files checked: $total_files"
echo "Total violations: $violations"

if [[ $violations -eq 0 ]]; then
    echo "🎉 ALL FILES ARE COMPLIANT! 🎉"
    exit 0
else
    echo "🚨 VIOLATIONS FOUND - Fix required!"
    exit 1
fi 