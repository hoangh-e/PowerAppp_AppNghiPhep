#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script để fix tất cả Rectangle + DropShadow PA2108 errors trong project
"""

import os
import glob
import re

def fix_rectangle_dropshadow_in_file(filepath):
    """
    Fix Rectangle + DropShadow trong một file
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Kiểm tra có Rectangle và DropShadow không
        if 'Control: Rectangle' not in content or 'DropShadow:' not in content:
            return False
        
        # Backup
        backup_path = filepath + '.dropshadow_backup'
        with open(backup_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        lines = content.split('\\n')
        result_lines = []
        changes = []
        
        i = 0
        while i < len(lines):
            line = lines[i]
            
            # Tìm Rectangle control
            if 'Control: Rectangle' in line and not line.strip().startswith('#'):
                result_lines.append(line)
                
                # Tìm tên control
                control_name = "Unknown"
                for j in range(max(0, i-5), i):
                    prev_line = lines[j].strip()
                    if prev_line.endswith(':') and not any(x in prev_line for x in ['Control:', 'Properties:', 'Children:']):
                        control_name = prev_line[:-1].strip("'\"")
                        break
                
                control_indent = len(line) - len(line.lstrip())
                
                # Xử lý block Properties
                i += 1
                while i < len(lines):
                    current_line = lines[i]
                    
                    # Dòng trống hoặc comment
                    if not current_line.strip() or current_line.strip().startswith('#'):
                        result_lines.append(current_line)
                        i += 1
                        continue
                    
                    current_indent = len(current_line) - len(current_line.lstrip())
                    
                    # Ra khỏi block Rectangle
                    if current_indent <= control_indent and current_line.strip():
                        break
                    
                    # Xóa DropShadow
                    if 'DropShadow:' in current_line and not current_line.strip().startswith('#'):
                        changes.append(f"Removed DropShadow from Rectangle '{control_name}' at line {i+1}")
                        i += 1  # Skip dòng này
                        continue
                    else:
                        result_lines.append(current_line)
                        i += 1
                
                continue
            else:
                result_lines.append(line)
                i += 1
        
        if changes:
            # Save fixed content
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write('\\n'.join(result_lines))
            
            print(f"\\n✅ Fixed: {filepath}")
            for change in changes:
                print(f"   • {change}")
            return True
        else:
            # Remove backup if no changes
            if os.path.exists(backup_path):
                os.remove(backup_path)
            return False
    
    except Exception as e:
        print(f"❌ Error processing {filepath}: {e}")
        return False

def main():
    print("🔧 Fix ALL Rectangle + DropShadow PA2108 Errors")
    print("="*50)
    
    # Tìm tất cả file YAML
    yaml_files = glob.glob('**/*.yaml', recursive=True)
    
    print(f"📁 Scanning {len(yaml_files)} YAML files...")
    
    fixed_count = 0
    
    for yaml_file in yaml_files:
        if fix_rectangle_dropshadow_in_file(yaml_file):
            fixed_count += 1
    
    print(f"\\n📊 Results:")
    print(f"  ✅ Fixed files: {fixed_count}")
    print(f"  📁 Total files: {len(yaml_files)}")
    
    if fixed_count > 0:
        print(f"\\n🎉 Success! Fixed {fixed_count} files")
        print("💾 Backup files created with .dropshadow_backup extension")
    else:
        print("\\n⚪ No Rectangle + DropShadow errors found")

if __name__ == "__main__":
    main() 