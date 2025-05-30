#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import glob

def fix_indentation(content):
    """
    Fix indentation after removing Variant properties
    """
    lines = content.split('\n')
    result_lines = []
    
    for i, line in enumerate(lines):
        # Tìm pattern: Control: Rectangle followed by excessive spaces before Properties:
        if 'Control: Rectangle' in line:
            result_lines.append(line)
            control_indent = len(line) - len(line.lstrip())
            
            # Kiểm tra dòng tiếp theo
            if i + 1 < len(lines):
                next_line = lines[i + 1]
                if 'Properties:' in next_line:
                    # Fix indentation của Properties: - should be control_indent + 2
                    proper_indent = ' ' * (control_indent + 2)
                    fixed_line = proper_indent + 'Properties:'
                    result_lines.append(fixed_line)
                    continue
        
        result_lines.append(line)
    
    return '\n'.join(result_lines)

def fix_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check if file has Rectangle controls
        if 'Control: Rectangle' not in content:
            return False
        
        # Check for indentation issues
        pattern = r'Control: Rectangle\s*\n\s{10,}Properties:'
        if re.search(pattern, content):
            # Backup
            with open(filepath + '.indent_backup', 'w', encoding='utf-8') as f:
                f.write(content)
            
            # Fix
            fixed_content = fix_indentation(content)
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(fixed_content)
            
            print(f'✅ Fixed indentation: {filepath}')
            return True
        return False
    except Exception as e:
        print(f'❌ Error in {filepath}: {e}')
        return False

files = glob.glob('**/*.yaml', recursive=True)
fixed_count = 0

print("🔧 Fixing indentation after Variant removal...")

for file in files:
    if fix_file(file):
        fixed_count += 1

print(f'🎉 Fixed indentation in {fixed_count} files') 