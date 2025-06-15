#!/usr/bin/env python3
"""
Script để sửa tất cả "ADMIN" thành "Admin" trong NavigationComponent
"""

import re

def fix_navigation_admin():
    file_path = "Components/NavigationComponent.yaml"
    
    try:
        # Đọc file
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Thay thế tất cả "ADMIN" thành "Admin" trong NavigationComponent.UserRole
        content = content.replace('NavigationComponent.UserRole = "ADMIN"', 'NavigationComponent.UserRole = "Admin"')
        
        # Ghi lại file
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print("✅ Đã sửa thành công NavigationComponent.yaml")
        print("Thay đổi: 'ADMIN' → 'Admin' trong tất cả UserRole checks")
        
    except Exception as e:
        print(f"❌ Lỗi: {e}")

if __name__ == "__main__":
    fix_navigation_admin() 