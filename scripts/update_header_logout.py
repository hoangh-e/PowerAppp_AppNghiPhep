#!/usr/bin/env python3
"""
Script to add OnLogout event binding to HeaderComponent in all SharePoint screens
"""

import os
import re
import glob

def update_header_component_logout(file_path):
    """Add OnLogout event binding to HeaderComponent in a YAML file"""
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if file already has OnLogout binding
    if 'OnLogout:' in content:
        print(f"✅ {file_path} already has OnLogout binding")
        return False
    
    # Pattern to find HeaderComponent properties section
    pattern = r'(ComponentName: HeaderComponent\s+Properties:.*?)(NotificationCount: [^\n]+)'
    
    def replacement(match):
        properties_section = match.group(1)
        notification_count = match.group(2)
        
        logout_binding = """            OnLogout: |
              =//LOGOUT: Clear all session data and return to login
              Set(varLoginSuccess, false); Set(varSessionValid, false);
              Set(varLoggedInUserEmail, ""); Clear(UserSession);
              UpdateContext({localLogout: true});
              Navigate(LoginScreen)"""
        
        return f"{properties_section}{notification_count}\n{logout_binding}"
    
    # Apply the replacement
    updated_content = re.sub(pattern, replacement, content, flags=re.DOTALL)
    
    if updated_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(updated_content)
        print(f"✅ Updated {file_path}")
        return True
    else:
        print(f"⚠️  Could not find HeaderComponent pattern in {file_path}")
        return False

def main():
    """Main function to update all SharePoint screen files"""
    
    # Get all SharePoint screen files
    pattern = "src/Screens/*_SharePoint.yaml"
    files = glob.glob(pattern)
    
    if not files:
        print("❌ No SharePoint screen files found")
        return
    
    print(f"🔍 Found {len(files)} SharePoint screen files")
    
    updated_count = 0
    for file_path in files:
        if update_header_component_logout(file_path):
            updated_count += 1
    
    print(f"\n🎉 Updated {updated_count} files successfully!")

if __name__ == "__main__":
    main() 