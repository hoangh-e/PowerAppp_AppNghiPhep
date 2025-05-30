#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script nâng cao để sửa lỗi text formatting trong file YAML Power App
Tùy chọn xử lý các trường hợp khác nhau
"""

import os
import glob
import re
import argparse

def fix_text_patterns(content, fix_colon_space=True, fix_notification_text=False):
    """
    Tìm và sửa lỗi trong các chuỗi được bao bởi dấu ngoặc kép
    
    Args:
        content (str): Nội dung file
        fix_colon_space (bool): Sửa ": " thành ":"
        fix_notification_text (bool): Sửa text trong notification (ít an toàn hơn)
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
            fixed_content = quote_content
            
            # Sửa ": " thành ":" (trừ một số trường hợp ngoại lệ)
            if fix_colon_space:
                # Không sửa nếu đây là notification hoặc một số trường hợp đặc biệt
                is_notification = any(keyword in quote_content.lower() for keyword in [
                    'notify', 'thông báo', 'đã xóa', 'tải xuống', 'mở file'
                ])
                
                if not is_notification or fix_notification_text:
                    # Sửa ": " thành ":" cho labels và text thông thường
                    if any(label in quote_content for label in [
                        'Email:', 'Tên:', 'Họ tên:', 'Vai trò:', 'Phòng ban:', 
                        'Trạng thái:', 'Ngày tạo:', 'Đơn:', 'File:', 'Kích thước:',
                        'Đã chọn file:', 'Loại:', 'Thời gian:', 'Người tạo:'
                    ]):
                        fixed_content = fixed_content.replace(': ', ':')
            
            result += fixed_content
            
            # Thêm dấu " đóng nếu tìm thấy
            if i < len(content):
                result += content[i]  # Thêm dấu " đóng
                i += 1
        else:
            result += content[i]
            i += 1
    
    return result

def process_file(file_path, fix_colon_space=True, fix_notification_text=False, dry_run=False):
    """
    Xử lý một file YAML
    """
    print(f"Xử lý: {file_path}")
    
    try:
        # Đọc file
        with open(file_path, 'r', encoding='utf-8') as f:
            original = f.read()
        
        # Sửa lỗi
        fixed = fix_text_patterns(original, fix_colon_space, fix_notification_text)
        
        # Kiểm tra có thay đổi không
        if original != fixed:
            if dry_run:
                # Hiển thị diff
                print(f"  📝 [DRY RUN] Sẽ có thay đổi:")
                lines_orig = original.split('\n')
                lines_fixed = fixed.split('\n')
                for i, (orig_line, fixed_line) in enumerate(zip(lines_orig, lines_fixed)):
                    if orig_line != fixed_line:
                        print(f"    Dòng {i+1}:")
                        print(f"      Cũ:  {orig_line.strip()}")
                        print(f"      Mới: {fixed_line.strip()}")
                        if i > 5:  # Giới hạn hiển thị
                            remaining = sum(1 for o, f in zip(lines_orig[i:], lines_fixed[i:]) if o != f)
                            if remaining > 0:
                                print(f"    ... và {remaining} thay đổi khác")
                            break
            else:
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
    parser = argparse.ArgumentParser(
        description='Sửa lỗi text formatting trong file YAML Power App'
    )
    parser.add_argument(
        '--file',
        help='Xử lý một file cụ thể'
    )
    parser.add_argument(
        '--directory',
        default='.',
        help='Thư mục chứa file YAML (mặc định: thư mục hiện tại)'
    )
    parser.add_argument(
        '--no-colon-fix',
        action='store_true',
        help='Không sửa ": " thành ":"'
    )
    parser.add_argument(
        '--fix-notifications',
        action='store_true',
        help='Cũng sửa text trong notifications (không an toàn)'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Chỉ hiển thị những gì sẽ thay đổi'
    )
    
    args = parser.parse_args()
    
    print("🔧 Script sửa lỗi text formatting nâng cao")
    print("="*45)
    
    if args.file:
        # Xử lý một file cụ thể
        if os.path.exists(args.file):
            process_file(
                args.file, 
                fix_colon_space=not args.no_colon_fix,
                fix_notification_text=args.fix_notifications,
                dry_run=args.dry_run
            )
        else:
            print(f"❌ File không tồn tại: {args.file}")
    else:
        # Tìm tất cả file YAML
        os.chdir(args.directory)
        yaml_files = []
        for pattern in ['*.yaml', '*.yml']:
            yaml_files.extend(glob.glob(pattern, recursive=False))
            yaml_files.extend(glob.glob(f'**/{pattern}', recursive=True))
        
        yaml_files = sorted(set(yaml_files))
        
        print(f"📁 Tìm thấy {len(yaml_files)} file YAML")
        if args.dry_run:
            print("📋 DRY RUN MODE - Không thay đổi file thực sự")
        
        for file_path in yaml_files:
            process_file(
                file_path,
                fix_colon_space=not args.no_colon_fix,
                fix_notification_text=args.fix_notifications,
                dry_run=args.dry_run
            )
    
    print("\n✅ Hoàn tất!")

if __name__ == "__main__":
    main() 