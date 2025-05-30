#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script để xóa DropShadow property khỏi Rectangle controls
PA2108: Unknown property 'DropShadow' for control type 'Rectangle'
"""

import os
import glob
import re

def fix_rectangle_dropshadow(content):
    """
    Xóa DropShadow property khỏi Rectangle controls
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
            control_name = "Unknown"
            
            # Tìm tên control từ các dòng trước
            for prev_idx in range(max(0, i-5), i):
                prev_line = lines[prev_idx].strip()
                if prev_line.endswith(':') and not prev_line.startswith('Control:') and not prev_line.startswith('Properties:'):
                    control_name = prev_line.replace(':', '').strip()
                    break
            
            current_indent = len(line) - len(line.lstrip())
            
            # Kiểm tra các dòng tiếp theo trong block này
            j = i + 1
            while j < len(lines):
                next_line = lines[j]
                
                # Nếu gặp dòng trống hoặc comment, giữ nguyên
                if not next_line.strip() or next_line.strip().startswith('#'):
                    result_lines.append(next_line)
                    j += 1
                    continue
                
                next_indent = len(next_line) - len(next_line.lstrip())
                
                # Nếu indent nhỏ hơn hoặc bằng current control, dừng block
                if next_indent <= current_indent and next_line.strip():
                    break
                
                # Kiểm tra DropShadow property
                if 'DropShadow:' in next_line and not next_line.strip().startswith('#'):
                    # Bỏ qua dòng này (xóa DropShadow)
                    changes_made.append(f"Removed DropShadow from Rectangle '{control_name}' at line {j+1}")
                    j += 1
                    continue
                else:
                    # Giữ nguyên dòng khác
                    result_lines.append(next_line)
                
                j += 1
            
            i = j
        else:
            result_lines.append(line)
            i += 1
    
    return '\n'.join(result_lines), changes_made

def process_file(filepath):
    """
    Xử lý một file YAML
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Kiểm tra xem có Rectangle + DropShadow không
        if 'Control: Rectangle' in content and 'DropShadow:' in content:
            # Backup file
            backup_path = filepath + '.dropshadow_backup'
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            # Fix content
            fixed_content, changes = fix_rectangle_dropshadow(content)
            
            if changes:
                # Ghi file đã fix
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(fixed_content)
                
                print(f"\n✅ Fixed: {filepath}")
                for change in changes:
                    print(f"   • {change}")
                return True
            else:
                # Xóa backup nếu không có thay đổi
                os.remove(backup_path)
        
        return False
    
    except Exception as e:
        print(f"❌ Error processing {filepath}: {e}")
        return False

def main():
    """
    Main function
    """
    print("🔧 Fix Rectangle + DropShadow PA2108 Errors")
    print("="*50)
    
    # Tìm tất cả file YAML
    yaml_files = glob.glob('**/*.yaml', recursive=True)
    
    print(f"📁 Tìm thấy {len(yaml_files)} file YAML")
    
    fixed_count = 0
    total_changes = 0
    
    for yaml_file in yaml_files:
        if process_file(yaml_file):
            fixed_count += 1
    
    print(f"\n📊 Kết quả:")
    print(f"  ✅ Fixed files: {fixed_count}")
    print(f"  📁 Total files scanned: {len(yaml_files)}")
    print(f"  💾 Backup files created automatically")
    
    if fixed_count > 0:
        print(f"\n🎉 Hoàn tất! Đã fix {fixed_count} file(s)")
        print("📋 Backup files tạo với extension .dropshadow_backup")
    else:
        print("\n⚪ Không tìm thấy lỗi Rectangle + DropShadow nào cần fix")

if __name__ == "__main__":
    main() 