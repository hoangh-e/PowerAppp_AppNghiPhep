#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script đơn giản để đọc file xlsx và pdf
"""

import pandas as pd
import os
from pathlib import Path

def read_excel_simple(file_path):
    """Đọc file Excel đơn giản"""
    try:
        # Đọc tất cả sheet
        all_sheets = pd.read_excel(file_path, sheet_name=None)
        
        print(f"📊 File Excel: {file_path}")
        print(f"📋 Số sheet: {len(all_sheets)}")
        
        for sheet_name, df in all_sheets.items():
            print(f"\n🔸 Sheet: '{sheet_name}'")
            print(f"   Kích thước: {df.shape[0]} hàng x {df.shape[1]} cột")
            print(f"   Cột: {list(df.columns)}")
            
            if not df.empty:
                print("   Dữ liệu mẫu:")
                print(df.head(3).to_string(index=False))
            print("-" * 40)
        
        return all_sheets
    except Exception as e:
        print(f"❌ Lỗi: {e}")
        return None

def read_pdf_simple(file_path):
    """Đọc file PDF đơn giản với PyPDF2"""
    try:
        import PyPDF2
        
        with open(file_path, 'rb') as file:
            pdf_reader = PyPDF2.PdfReader(file)
            num_pages = len(pdf_reader.pages)
            
            print(f"📄 File PDF: {file_path}")
            print(f"📃 Số trang: {num_pages}")
            
            # Đọc 3 trang đầu để test
            for i in range(min(3, num_pages)):
                page = pdf_reader.pages[i]
                text = page.extract_text()
                preview = text[:150].replace('\n', ' ')
                print(f"   Trang {i+1}: {preview}...")
            
            return True
    except ImportError:
        print("❌ Chưa cài PyPDF2. Chạy: pip install PyPDF2")
        return False
    except Exception as e:
        print(f"❌ Lỗi đọc PDF: {e}")
        return False

def main():
    """Hàm main"""
    print("🚀 Test đọc file...")
    
    # Đường dẫn file
    base_path = Path(__file__).parent.parent
    xlsx_file = base_path / "Docs" / "AppNghiPhep" / "Book1.xlsx"
    pdf_file = base_path / "Docs" / "URD_App_nghi_phep_AsiaShine - 11.10.2023.pdf"
    
    # Test Excel
    if xlsx_file.exists():
        print("\n📊 ĐANG TEST EXCEL...")
        read_excel_simple(xlsx_file)
    else:
        print(f"❌ Không tìm thấy: {xlsx_file}")
    
    # Test PDF
    if pdf_file.exists():
        print("\n📄 ĐANG TEST PDF...")
        read_pdf_simple(pdf_file)
    else:
        print(f"❌ Không tìm thấy: {pdf_file}")

if __name__ == "__main__":
    main() 