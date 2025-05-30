#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import glob

def fix_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Pattern để tìm Rectangle control với DropShadow trong block Properties
        # Tìm Rectangle, sau đó tìm DropShadow trong block Properties của nó
        lines = content.split('\n')
        result_lines = []
        changed = False
        
        i = 0
        while i < len(lines):
            line = lines[i]
            
            # Nếu tìm thấy Control: Rectangle
            if 'Control: Rectangle' in line and not line.strip().startswith('#'):
                result_lines.append(line)
                control_indent = len(line) - len(line.lstrip())
                
                # Xử lý các dòng tiếp theo
                i += 1
                while i < len(lines):
                    next_line = lines[i]
                    
                    # Dòng trống hoặc comment
                    if not next_line.strip() or next_line.strip().startswith('#'):
                        result_lines.append(next_line)
                        i += 1
                        continue
                    
                    next_indent = len(next_line) - len(next_line.lstrip())
                    
                    # Nếu indent <= control indent và có content, nghĩa là ra khỏi block
                    if next_indent <= control_indent and next_line.strip():
                        break
                    
                    # Kiểm tra DropShadow property
                    if 'DropShadow:' in next_line and not next_line.strip().startswith('#'):
                        print(f'  🔧 Removing DropShadow at line {i+1}: {next_line.strip()}')
                        changed = True
                        # Bỏ qua dòng này
                        i += 1
                        continue
                    else:
                        result_lines.append(next_line)
                        i += 1
                
                continue
            else:
                result_lines.append(line)
                i += 1
        
        if changed:
            # Backup
            with open(filepath + '.dropshadow_backup', 'w', encoding='utf-8') as f:
                f.write(content)
            
            # Save fixed content
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write('\n'.join(result_lines))
            
            print(f'✅ Fixed: {filepath}')
            return True
        
        return False
    
    except Exception as e:
        print(f'❌ Error: {filepath} - {e}')
        return False

def main():
    yaml_files = glob.glob('**/*.yaml', recursive=True)
    print(f'🔍 Scanning {len(yaml_files)} YAML files...')
    
    fixed_count = 0
    for filepath in yaml_files:
        if fix_file(filepath):
            fixed_count += 1
    
    print(f'\n📊 Results: {fixed_count} files fixed')

if __name__ == '__main__':
    main() 