#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script để tìm và sửa các lỗi PA2108: Unknown property cho các control types
"""

import os
import glob
import re

# Dictionary mapping các lỗi PA2108 phổ biến
PA2108_FIXES = {
    # GroupContainer không hỗ trợ event properties
    'GroupContainer': {
        'forbidden_properties': ['OnSelect', 'OnClick', 'OnHover', 'OnChange'],
        'replacement_control': 'Rectangle',
        'remove_variant': True  # Xóa Variant: ManualLayout khi chuyển sang Rectangle
    },
    
    # Rectangle không hỗ trợ Variant property
    'Rectangle': {
        'forbidden_properties': ['RadiusBottomLeft', 'RadiusBottomRight', 'RadiusTopLeft', 'RadiusTopRight'],
        'forbidden_variants': ['ManualLayout', 'AutoLayout'],  # Rectangle không có Variant
        'replacement_control': None,
        'remove_variant': True,  # Luôn xóa Variant cho Rectangle
        'property_replacements': {
            # Các individual radius properties sẽ được thay bằng BorderRadius
            'RadiusBottomLeft': 'BorderRadius',
            'RadiusBottomRight': 'BorderRadius', 
            'RadiusTopLeft': 'BorderRadius',
            'RadiusTopRight': 'BorderRadius'
        }
    },
    
    # Gallery VariableHeight không hỗ trợ WrapCount
    'Gallery_VariableHeight': {
        'forbidden_properties': ['WrapCount'],
        'replacement_control': None,
        'remove_variant': False
    },
    
    # Classic/Button không hỗ trợ một số properties
    'Classic/Button': {
        'forbidden_properties': ['BorderRadius', 'Disabled', 'Align'],
        'replacement_control': None,
        'remove_variant': False,
        'property_replacements': {
            'Disabled': 'DisplayMode'  # Thay Disabled bằng DisplayMode
        }
    },
    
    # Classic/TextInput không hỗ trợ một số properties
    'Classic/TextInput': {
        'forbidden_properties': ['OnFocus', 'OnBlur', 'TextMode'],
        'replacement_control': None,
        'remove_variant': False,
        'property_replacements': {
            'TextMode': 'Mode'  # Thay TextMode bằng Mode
        }
    }
}

def fix_pa2108_errors(content):
    """
    Sửa các lỗi PA2108 trong content YAML
    """
    lines = content.split('\n')
    result_lines = []
    i = 0
    changes_made = []
    
    while i < len(lines):
        line = lines[i]
        
        # Tìm Control declarations
        if 'Control:' in line and not line.strip().startswith('#'):
            control_type = line.split('Control:')[1].strip()
            current_indent = len(line) - len(line.lstrip())
            
            # Xử lý đặc biệt cho Gallery VariableHeight
            if control_type == 'Gallery':
                # Kiểm tra variant trong block này
                block_lines = [line]
                j = i + 1
                is_variable_height = False
                
                while j < len(lines):
                    next_line = lines[j]
                    if next_line.strip() == '':
                        block_lines.append(next_line)
                        j += 1
                        continue
                        
                    next_indent = len(next_line) - len(next_line.lstrip())
                    if next_indent <= current_indent and next_line.strip():
                        break
                    
                    block_lines.append(next_line)
                    
                    if 'Variant: VariableHeight' in next_line:
                        is_variable_height = True
                    
                    j += 1
                
                if is_variable_height:
                    control_type = 'Gallery_VariableHeight'
            
            # Kiểm tra có cần fix không
            if control_type in PA2108_FIXES:
                fix_config = PA2108_FIXES[control_type]
                
                # Đọc toàn bộ block của control này
                if control_type != 'Gallery_VariableHeight':
                    block_lines = [line]
                    j = i + 1
                    
                    while j < len(lines):
                        next_line = lines[j]
                        if next_line.strip() == '':
                            block_lines.append(next_line)
                            j += 1
                            continue
                            
                        next_indent = len(next_line) - len(next_line.lstrip())
                        if next_indent <= current_indent and next_line.strip():
                            break
                        
                        block_lines.append(next_line)
                        j += 1
                
                # Fix các properties trong block
                for k, block_line in enumerate(block_lines):
                    modified = False
                    
                    # Fix control type nếu cần
                    if 'Control:' in block_line and fix_config.get('replacement_control'):
                        old_control = control_type
                        new_control = fix_config['replacement_control']
                        block_lines[k] = block_line.replace(f'Control: {old_control}', f'Control: {new_control}')
                        changes_made.append(f"Thay đổi {old_control} → {new_control}")
                        modified = True
                    
                    # Xóa Variant nếu cần
                    if fix_config.get('remove_variant') and 'Variant:' in block_line:
                        # Kiểm tra forbidden variants nếu có
                        forbidden_variants = fix_config.get('forbidden_variants', [])
                        if forbidden_variants:
                            for variant in forbidden_variants:
                                if f'Variant: {variant}' in block_line:
                                    block_lines[k] = ''
                                    changes_made.append(f"Xóa Variant: {variant} cho {control_type}")
                                    modified = True
                                    break
                        else:
                            block_lines[k] = ''
                            changes_made.append("Xóa Variant property")
                            modified = True
                    
                    # Xóa forbidden properties
                    for forbidden_prop in fix_config['forbidden_properties']:
                        if f'{forbidden_prop}:' in block_line and not block_line.strip().startswith('#'):
                            # Kiểm tra có replacement không
                            replacements = fix_config.get('property_replacements', {})
                            if forbidden_prop in replacements:
                                replacement_prop = replacements[forbidden_prop]
                                block_lines[k] = block_line.replace(f'{forbidden_prop}:', f'{replacement_prop}:')
                                changes_made.append(f"Thay đổi {forbidden_prop} → {replacement_prop}")
                            else:
                                block_lines[k] = ''
                                changes_made.append(f"Xóa property: {forbidden_prop}")
                            modified = True
                
                result_lines.extend(block_lines)
                i = j
            else:
                result_lines.append(line)
                i += 1
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
        
        # Sửa lỗi
        fixed, changes = fix_pa2108_errors(original)
        
        # Kiểm tra có thay đổi không
        if original != fixed and changes:
            # Tạo backup
            backup_path = file_path + '.backup'
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
            print(f"  ⚪ Không có lỗi PA2108 cần sửa")
    
    except Exception as e:
        print(f"  ❌ Lỗi: {e}")

def main():
    print("🔧 Sửa các lỗi PA2108: Unknown property")
    print("="*50)
    
    # Tìm tất cả file YAML
    yaml_files = []
    for pattern in ['*.yaml', '*.yml']:
        yaml_files.extend(glob.glob(pattern, recursive=False))
        yaml_files.extend(glob.glob(f'**/{pattern}', recursive=True))
    
    yaml_files = sorted(set(yaml_files))
    
    print(f"📁 Tìm thấy {len(yaml_files)} file YAML")
    print("\n🚀 Bắt đầu xử lý...")
    
    for file_path in yaml_files:
        process_file(file_path)
    
    print("\n✅ Hoàn tất!")
    print("\n📋 Các lỗi đã fix:")
    print("- GroupContainer + OnSelect → Rectangle")
    print("- Rectangle + Variant → Xóa Variant")
    print("- Gallery VariableHeight + WrapCount → Xóa WrapCount")
    print("- Classic/Button + BorderRadius/Disabled/Align → Xóa")
    print("- Rectangle + Individual corner radius → BorderRadius")
    print("- Classic/TextInput + OnFocus/OnBlur/TextMode → Xóa/Thay")
    print("- Backup files được tạo tự động")

if __name__ == "__main__":
    main() 