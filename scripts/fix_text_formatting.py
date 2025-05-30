#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script để sửa lỗi format text trong file YAML Power App
Tìm và thay thế ": " thành ":" trong các chuỗi string được đóng bởi dấu ngoặc kép
"""

import os
import re
import glob
import argparse
from pathlib import Path

def process_string_content(text):
    """
    Xử lý nội dung bên trong chuỗi string để thay thế ": " thành ":"
    """
    # Thay thế ": " thành ":" nhưng chỉ trong text content
    # Không thay thế nếu ": " là phần của URL hoặc path
    processed = text.replace(': ', ':')
    return processed

def fix_yaml_text_formatting(content):
    """
    Sửa lỗi formatting trong file YAML
    Tìm các chuỗi string trong dấu ngoặc kép và sửa ": " thành ":"
    """
    result = ""
    i = 0
    
    while i < len(content):
        char = content[i]
        
        if char == '"':
            # Bắt đầu một chuỗi string
            result += char  # Thêm dấu " mở
            i += 1
            
            # Duyệt cho đến khi tìm thấy dấu " đóng
            string_content = ""
            while i < len(content):
                current_char = content[i]
                
                if current_char == '"':
                    # Tìm thấy dấu " đóng
                    # Xử lý nội dung string
                    processed_content = process_string_content(string_content)
                    result += processed_content
                    result += current_char  # Thêm dấu " đóng
                    i += 1
                    break
                elif current_char == '\\' and i + 1 < len(content):
                    # Xử lý escape characters
                    string_content += current_char
                    i += 1
                    if i < len(content):
                        string_content += content[i]
                        i += 1
                else:
                    string_content += current_char
                    i += 1
            else:
                # Nếu không tìm thấy dấu " đóng, thêm nội dung còn lại
                result += string_content
                break
        else:
            result += char
            i += 1
    
    return result

def process_yaml_file(file_path):
    """
    Xử lý một file YAML
    """
    print(f"Đang xử lý: {file_path}")
    
    try:
        # Đọc file với encoding UTF-8
        with open(file_path, 'r', encoding='utf-8') as f:
            original_content = f.read()
        
        # Xử lý nội dung
        fixed_content = fix_yaml_text_formatting(original_content)
        
        # Kiểm tra xem có thay đổi gì không
        if original_content != fixed_content:
            # Tạo backup
            backup_path = file_path + '.backup'
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(original_content)
            print(f"  → Đã tạo backup: {backup_path}")
            
            # Ghi file đã sửa
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(fixed_content)
            print(f"  → Đã sửa file: {file_path}")
            
            # Hiển thị thống kê thay đổi
            changes = original_content.count(': ') - fixed_content.count(': ')
            if changes > 0:
                print(f"  → Đã thay thế {changes} lỗi ': ' thành ':'")
        else:
            print(f"  → Không có thay đổi trong file")
            
    except Exception as e:
        print(f"  ❌ Lỗi khi xử lý file {file_path}: {e}")

def find_yaml_files(directory):
    """
    Tìm tất cả file YAML trong thư mục và thư mục con
    """
    yaml_patterns = ['*.yaml', '*.yml']
    yaml_files = []
    
    for pattern in yaml_patterns:
        # Tìm trong thư mục hiện tại
        yaml_files.extend(glob.glob(os.path.join(directory, pattern)))
        # Tìm trong thư mục con
        yaml_files.extend(glob.glob(os.path.join(directory, '**', pattern), recursive=True))
    
    return sorted(yaml_files)

def main():
    parser = argparse.ArgumentParser(
        description='Sửa lỗi format text trong file YAML Power App'
    )
    parser.add_argument(
        'directory',
        nargs='?',
        default='.',
        help='Thư mục chứa file YAML cần xử lý (mặc định: thư mục hiện tại)'
    )
    parser.add_argument(
        '--file',
        help='Xử lý một file cụ thể thay vì toàn bộ thư mục'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Chỉ hiển thị những gì sẽ được thay đổi mà không thực sự thay đổi file'
    )
    
    args = parser.parse_args()
    
    print("🔧 Script sửa lỗi format text trong YAML")
    print("="*50)
    
    if args.file:
        # Xử lý một file cụ thể
        if os.path.exists(args.file):
            if args.dry_run:
                print("📋 DRY RUN MODE - Không thay đổi file thực sự")
                print(f"Sẽ xử lý file: {args.file}")
            else:
                process_yaml_file(args.file)
        else:
            print(f"❌ File không tồn tại: {args.file}")
    else:
        # Xử lý tất cả file YAML trong thư mục
        yaml_files = find_yaml_files(args.directory)
        
        if not yaml_files:
            print(f"❌ Không tìm thấy file YAML nào trong thư mục: {args.directory}")
            return
        
        print(f"📁 Tìm thấy {len(yaml_files)} file YAML")
        
        if args.dry_run:
            print("\n📋 DRY RUN MODE - Danh sách file sẽ được xử lý:")
            for file_path in yaml_files:
                print(f"  • {file_path}")
        else:
            print("\n🚀 Bắt đầu xử lý...")
            for file_path in yaml_files:
                process_yaml_file(file_path)
    
    print("\n✅ Hoàn tất!")

if __name__ == "__main__":
    main() 