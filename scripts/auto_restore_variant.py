#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script tự động restore tất cả file từ variant_backup (không confirm)
"""

import os
import glob
import shutil

def auto_restore():
    """
    Tự động restore tất cả file từ variant_backup
    """
    print("🔄 Auto Restore từ variant_backup files...")
    
    # Tìm tất cả file variant_backup
    backup_files = glob.glob('**/*.variant_backup', recursive=True)
    
    print(f"📁 Tìm thấy {len(backup_files)} file variant_backup")
    
    if not backup_files:
        print("⚪ Không có file variant_backup nào để restore.")
        return
    
    restored_count = 0
    
    for backup_file in backup_files:
        try:
            # Tìm file gốc
            original_file = backup_file.replace('.variant_backup', '')
            
            if os.path.exists(original_file):
                # Restore
                shutil.copy2(backup_file, original_file)
                print(f"  ✅ {original_file}")
                restored_count += 1
                
                # Xóa backup file
                os.remove(backup_file)
                
        except Exception as e:
            print(f"  ❌ Error: {backup_file} - {e}")
    
    print(f"\n🎉 Hoàn tất! Restored {restored_count} files")

if __name__ == "__main__":
    auto_restore() 