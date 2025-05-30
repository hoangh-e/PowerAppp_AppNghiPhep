#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script để xóa Variant property khỏi Rectangle controls
"""

import os
import glob
import re

def fix_rectangle_variants(content):
    """
    Xóa Variant property khỏi Rectangle controls
    """
    lines = content.split('\n')
    result_lines = []
    changes_made = []
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Tìm Rectangle control
        if 'Control: Rectangle' in line and not line.strip().startswith('#'):
            result_lines.append(line)
            current_indent = len(line) - len(line.lstrip())
            
            # Kiểm tra các dòng tiếp theo trong block này
            j = i + 1
            while j < len(lines):
                next_line = lines[j]
                
                # Nếu gặp dòng trống, thêm vào
                if next_line.strip() == '':
                    result_lines.append(next_line)
                    j += 1
                    continue
                
                next_indent = len(next_line) - len(next_line.lstrip())
                
                # Nếu indent <= current_indent và có content, nghĩa là hết block
                if next_indent <= current_indent and next_line.strip():
                    break
                
                # Nếu là Variant property, bỏ qua (không thêm vào result)
                if 'Variant:' in next_line:
                    changes_made.append(f"Xóa Variant property ở dòng {j+1}")
                    j += 1
                    continue
                
                # Thêm các dòng khác
                result_lines.append(next_line)
                j += 1
            
            i = j
        else:
            result_lines.append(line)
            i += 1
    
    return '\n'.join(result_lines), changes_made

def process_file(file_path):
    """
    Xử lý một file YAML
    """
    print(f"Kiểm tra: {file_path}")
    
    try:
        # Đọc file
        with open(file_path, 'r', encoding='utf-8') as f:
            original = f.read()
        
        # Kiểm tra có Rectangle + Variant không
        if 'Control: Rectangle' not in original:
            print(f"  ⚪ Không có Rectangle control")
            return
        
        # Sửa lỗi
        fixed, changes = fix_rectangle_variants(original)
        
        # Kiểm tra có thay đổi không
        if original != fixed and changes:
            # Tạo backup
            backup_path = file_path + '.rectangle_backup'
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(original)
            
            # Ghi file mới
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(fixed)
            
            print(f"  ✅ Đã sửa file:")
            for change in changes:
                print(f"     → {change}")
            print(f"  📁 Backup: {backup_path}")
        else:
            print(f"  ⚪ Không có Rectangle + Variant nào cần sửa")
    
    except Exception as e:
        print(f"  ❌ Lỗi: {e}")

def main():
    print("🔧 Xóa Variant property khỏi Rectangle controls")
    print("="*50)
    
    # Tìm tất cả file YAML
    yaml_files = []
    for pattern in ['*.yaml', '*.yml']:
        yaml_files.extend(glob.glob(pattern, recursive=False))
        yaml_files.extend(glob.glob(f'**/{pattern}', recursive=True))
    
    yaml_files = sorted(set(yaml_files))
    
    print(f"📁 Tìm thấy {len(yaml_files)} file YAML")
    print("\n🚀 Bắt đầu xử lý...")
    
    total_fixed = 0
    for file_path in yaml_files:
        if process_file(file_path):
            total_fixed += 1
    
    print(f"\n✅ Hoàn tất! Đã sửa {total_fixed} files")
    print("\n📋 Lỗi đã fix:")
    print("- Rectangle + Variant → Xóa Variant property")
    print("- Backup files được tạo tự động")

if __name__ == "__main__":
    main() 