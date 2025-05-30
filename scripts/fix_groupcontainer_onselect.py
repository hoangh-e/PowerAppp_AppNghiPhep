#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script để tìm và sửa lỗi GroupContainer có OnSelect property
PA2108: Unknown property 'OnSelect' for control type 'GroupContainer'
"""

import os
import glob
import re

def fix_groupcontainer_onselect(content):
    """
    Tìm GroupContainer có OnSelect và chuyển thành Rectangle
    """
    lines = content.split('\n')
    result_lines = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Tìm GroupContainer
        if 'Control: GroupContainer' in line:
            # Tìm OnSelect trong block này
            current_indent = len(line) - len(line.lstrip())
            has_onselect = False
            block_lines = [line]
            j = i + 1
            
            # Đọc toàn bộ block GroupContainer
            while j < len(lines):
                next_line = lines[j]
                if next_line.strip() == '':
                    block_lines.append(next_line)
                    j += 1
                    continue
                    
                next_indent = len(next_line) - len(next_line.lstrip())
                
                # Nếu indent nhỏ hơn hoặc bằng, block kết thúc
                if next_indent <= current_indent and next_line.strip():
                    break
                
                block_lines.append(next_line)
                
                # Kiểm tra có OnSelect không
                if 'OnSelect:' in next_line:
                    has_onselect = True
                
                j += 1
            
            # Nếu có OnSelect, chuyển GroupContainer thành Rectangle
            if has_onselect:
                print(f"  🔧 Tìm thấy GroupContainer với OnSelect tại dòng {i+1}")
                for k, block_line in enumerate(block_lines):
                    if 'Control: GroupContainer' in block_line:
                        # Thay thế GroupContainer bằng Rectangle
                        block_lines[k] = block_line.replace('Control: GroupContainer', 'Control: Rectangle')
                        print(f"     → Đã thay đổi thành Rectangle")
                    elif 'Variant: ManualLayout' in block_line:
                        # Xóa Variant vì Rectangle không cần
                        block_lines[k] = ''
                        print(f"     → Đã xóa Variant: ManualLayout")
            
            result_lines.extend(block_lines)
            i = j
        else:
            result_lines.append(line)
            i += 1
    
    return '\n'.join(result_lines)

def process_file(file_path):
    """
    Xử lý một file YAML
    """
    print(f"Kiểm tra: {file_path}")
    
    try:
        # Đọc file
        with open(file_path, 'r', encoding='utf-8') as f:
            original = f.read()
        
        # Sửa lỗi
        fixed = fix_groupcontainer_onselect(original)
        
        # Kiểm tra có thay đổi không
        if original != fixed:
            # Tạo backup
            backup_path = file_path + '.backup'
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(original)
            
            # Ghi file mới
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(fixed)
            
            print(f"  ✅ Đã sửa file, backup: {backup_path}")
        else:
            print(f"  ⚪ Không có GroupContainer với OnSelect")
    
    except Exception as e:
        print(f"  ❌ Lỗi: {e}")

def main():
    print("🔧 Sửa lỗi GroupContainer có OnSelect property")
    print("="*50)
    
    # Tìm tất cả file YAML
    yaml_files = []
    for pattern in ['*.yaml', '*.yml']:
        yaml_files.extend(glob.glob(pattern, recursive=False))
        yaml_files.extend(glob.glob(f'**/{pattern}', recursive=True))
    
    yaml_files = sorted(set(yaml_files))
    
    print(f"📁 Tìm thấy {len(yaml_files)} file YAML")
    print("\n🚀 Bắt đầu xử lý...")
    
    for file_path in yaml_files:
        process_file(file_path)
    
    print("\n✅ Hoàn tất!")
    print("\n📋 Lưu ý:")
    print("- GroupContainer + OnSelect → Rectangle")
    print("- Variant: ManualLayout đã được xóa")
    print("- Backup files được tạo tự động")

if __name__ == "__main__":
    main() 