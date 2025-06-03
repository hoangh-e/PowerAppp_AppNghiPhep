#!/usr/bin/env python3
"""
Simple script to check basic violations in MyLeavesScreen.yaml
"""
import sys
import re

def check_sharepoint_violations(content):
    """Check SharePoint database schema violations"""
    violations = []
    
    # Check for MaNhanVien usage (should be MaNguoiDung)
    mahanvien_matches = re.findall(r'MaNhanVien[.\s]*[^a-zA-Z]', content)
    if mahanvien_matches:
        violations.append(f"❌ DATABASE SCHEMA: Found {len(mahanvien_matches)} instances of 'MaNhanVien' - should be 'MaNguoiDung'")
    
    return violations

def check_icon_violations(content):
    """Check invalid icon references"""
    violations = []
    
    # Check for invalid icons
    invalid_icons = ['Icon.Warning', 'Icon.CheckMark', 'Icon.HorizontalLine']
    for icon in invalid_icons:
        if icon in content:
            violations.append(f"❌ INVALID ICON: Found '{icon}' - not in approved icons list")
    
    return violations

def check_property_violations(content):
    """Check invalid property usage"""
    violations = []
    
    # Check for Rectangle with invalid properties
    lines = content.split('\n')
    control_type = None
    
    for i, line in enumerate(lines):
        if 'Control: Rectangle' in line:
            control_type = 'Rectangle'
        elif 'Control:' in line and 'Rectangle' not in line:
            control_type = None
        elif control_type == 'Rectangle':
            if any(prop in line for prop in ['DropShadow:', 'BorderRadius:', 'Variant:', 'RadiusTopLeft:', 'RadiusTopRight:']):
                violations.append(f"❌ RECTANGLE PROPERTY: Line {i+1} - Rectangle doesn't support this property")
    
    return violations

def check_text_formatting_violations(content):
    """Check text formatting violations"""
    violations = []
    
    # Check for inline text with spaces after colon
    matches = re.findall(r'"[^"]*:\s[^"]*"', content)
    for match in matches:
        if ': ' in match and not match.startswith('"Debug:'):  # Skip debug labels
            violations.append(f"❌ TEXT FORMAT: Found '{match}' - should separate colon and space")
    
    return violations

def check_yaml_syntax_violations(content):
    """Check YAML syntax issues"""
    violations = []
    
    # Check for potential YAML syntax issues with quotes
    lines = content.split('\n')
    for i, line in enumerate(lines):
        # Check for unescaped quotes in complex formulas
        if 'Text: =' in line and line.count('"') > 2:
            violations.append(f"⚠️ YAML SYNTAX: Line {i+1} - Complex text formula may need quote escaping")
    
    return violations

def main():
    if len(sys.argv) != 2:
        print("Usage: python check_violations.py <yaml_file>")
        return
    
    file_path = sys.argv[1]
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"❌ File not found: {file_path}")
        return
    except Exception as e:
        print(f"❌ Error reading file: {e}")
        return
    
    print(f"🔍 COMPREHENSIVE RULE VIOLATIONS CHECK")
    print(f"File: {file_path}")
    print("=" * 60)
    
    all_violations = []
    
    # Check different categories
    violations_checks = [
        ("SharePoint Database Schema", check_sharepoint_violations),
        ("Icon References", check_icon_violations), 
        ("Property Usage", check_property_violations),
        ("Text Formatting", check_text_formatting_violations),
        ("YAML Syntax", check_yaml_syntax_violations)
    ]
    
    for category, check_func in violations_checks:
        print(f"\n📋 {category}:")
        violations = check_func(content)
        if violations:
            for v in violations:
                print(f"  {v}")
            all_violations.extend(violations)
        else:
            print(f"  ✅ No violations found")
    
    print("\n" + "=" * 60)
    print(f"📊 SUMMARY: {len(all_violations)} total violations found")
    
    if all_violations:
        print("\n🚨 CRITICAL VIOLATIONS REQUIRING IMMEDIATE FIX:")
        for v in all_violations:
            print(f"  {v}")
    else:
        print("🎉 NO VIOLATIONS FOUND!")
    
    return len(all_violations)

if __name__ == "__main__":
    sys.exit(main()) 