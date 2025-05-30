#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script đơn giản để sửa lỗi ": " thành ":" trong file YAML
"""

import os
import glob

def fix_text_in_quotes(content):
    """
    Tìm và sửa ": " thành ":" trong các chuỗi được bao bởi dấu ngoặc kép
    """
    result = ""
    i = 0
    
    while i < len(content):
        if content[i] == '"':
            # Tìm thấy dấu " mở
            result += content[i]  # Thêm dấu "
            i += 1
            
            # Tìm dấu " đóng
            quote_content = ""
            while i < len(content) and content[i] != '"':
                quote_content += content[i]
                i += 1
            
            # Xử lý nội dung trong dấu ngoặc kép
            fixed_content = quote_content.replace(': ', ':')
            result += fixed_content
            
            # Thêm dấu " đóng nếu tìm thấy
            if i < len(content):
                result += content[i]  # Thêm dấu " đóng
                i += 1
        else:
            result += content[i]
            i += 1
    
    return result

def process_file(file_path):
    """
    Xử lý một file YAML
    """
    print(f"Xử lý: {file_path}")
    
    try:
        # Đọc file
        with open(file_path, 'r', encoding='utf-8') as f:
            original = f.read()
        
        # Sửa lỗi
        fixed = fix_text_in_quotes(original)
        
        # Kiểm tra có thay đổi không
        if original != fixed:
            # Tạo backup
            backup_path = file_path + '.backup'
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(original)
            
            # Ghi file mới
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(fixed)
            
            changes = original.count(': ') - fixed.count(': ')
            print(f"  ✅ Đã sửa {changes} lỗi, backup: {backup_path}")
        else:
            print(f"  ⚪ Không có thay đổi")
    
    except Exception as e:
        print(f"  ❌ Lỗi: {e}")

def main():
    # Tìm tất cả file YAML
    yaml_files = []
    for pattern in ['*.yaml', '*.yml']:
        yaml_files.extend(glob.glob(pattern, recursive=False))
        yaml_files.extend(glob.glob(f'**/{pattern}', recursive=True))
    
    yaml_files = sorted(set(yaml_files))
    
    print("🔧 Sửa lỗi ': ' thành ':' trong file YAML")
    print("="*40)
    print(f"Tìm thấy {len(yaml_files)} file YAML")
    
    for file_path in yaml_files:
        process_file(file_path)
    
    print("\n✅ Hoàn tất!")

if __name__ == "__main__":
    main() 