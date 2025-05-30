#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script để restore tất cả file từ variant_backup
"""

import os
import glob
import shutil

def restore_from_backup():
    """
    Restore tất cả file từ variant_backup
    """
    # Tìm tất cả file variant_backup
    backup_files = glob.glob('**/*.variant_backup', recursive=True)
    
    print(f"🔄 Tìm thấy {len(backup_files)} file variant_backup")
    
    restored_count = 0
    failed_count = 0
    
    for backup_file in backup_files:
        try:
            # Tìm file gốc bằng cách bỏ .variant_backup
            original_file = backup_file.replace('.variant_backup', '')
            
            # Kiểm tra file gốc có tồn tại không
            if os.path.exists(original_file):
                # Backup current file trước khi restore
                current_backup = original_file + '.current_backup'
                shutil.copy2(original_file, current_backup)
                print(f"  📁 Backup current: {current_backup}")
                
                # Restore từ variant_backup
                shutil.copy2(backup_file, original_file)
                print(f"  ✅ Restored: {original_file}")
                
                restored_count += 1
            else:
                print(f"  ⚠️  Original file not found: {original_file}")
                failed_count += 1
                
        except Exception as e:
            print(f"  ❌ Error restoring {backup_file}: {e}")
            failed_count += 1
    
    print(f"\n📊 Kết quả:")
    print(f"  ✅ Restored: {restored_count} files")
    print(f"  ❌ Failed: {failed_count} files")
    print(f"  📁 Current backups created automatically")
    
    return restored_count, failed_count

def cleanup_backups():
    """
    Xóa các file backup sau khi restore thành công
    """
    print("\n🧹 Cleanup backup files...")
    
    # Tìm và xóa variant_backup files
    backup_files = glob.glob('**/*.variant_backup', recursive=True)
    
    for backup_file in backup_files:
        try:
            os.remove(backup_file)
            print(f"  🗑️  Deleted: {backup_file}")
        except Exception as e:
            print(f"  ❌ Error deleting {backup_file}: {e}")
    
    print(f"  ✅ Cleanup completed!")

def main():
    print("🔄 Rectangle Variant Backup Restore Tool")
    print("="*50)
    
    # Confirm action
    print("⚠️  Cảnh báo: Script này sẽ:")
    print("  1. Restore tất cả file từ .variant_backup")
    print("  2. Backup current files thành .current_backup")
    print("  3. Xóa các .variant_backup files")
    print()
    
    response = input("Bạn có muốn tiếp tục? (y/N): ")
    
    if response.lower() not in ['y', 'yes', 'đ']:
        print("❌ Đã hủy restore.")
        return
    
    # Restore files
    restored, failed = restore_from_backup()
    
    if restored > 0:
        print(f"\n✅ Đã restore {restored} files thành công!")
        
        # Ask about cleanup
        cleanup_response = input("\nXóa các .variant_backup files? (y/N): ")
        if cleanup_response.lower() in ['y', 'yes', 'đ']:
            cleanup_backups()
    else:
        print("\n⚪ Không có file nào được restore.")
    
    print("\n🎉 Hoàn tất!")

if __name__ == "__main__":
    main() 