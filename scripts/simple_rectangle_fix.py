#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import glob

def fix_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Pattern để tìm Rectangle control với Variant trên dòng tiếp theo
        pattern = r'(Control: Rectangle\s*\n\s*)Variant:\s*[^\n]*\n'
        
        if re.search(pattern, content):
            # Backup
            with open(filepath + '.variant_backup', 'w', encoding='utf-8') as f:
                f.write(content)
            
            # Fix
            fixed_content = re.sub(pattern, r'\1', content)
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(fixed_content)
            
            print(f'✅ Fixed: {filepath}')
            return True
        return False
    except Exception as e:
        print(f'❌ Error in {filepath}: {e}')
        return False

files = glob.glob('**/*.yaml', recursive=True)
fixed_count = 0

print("🔧 Fixing Rectangle + Variant properties...")

for file in files:
    if fix_file(file):
        fixed_count += 1

print(f'🎉 Fixed {fixed_count} files') 