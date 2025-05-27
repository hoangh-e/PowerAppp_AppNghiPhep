#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script để đọc toàn bộ sheet của file xlsx và file pdf
Author: PowerApp Assistant
Date: 2024
"""

import pandas as pd
import PyPDF2
import pdfplumber
import os
import sys
from pathlib import Path

class FileReader:
    def __init__(self, base_path=None):
        """
        Khởi tạo FileReader
        
        Args:
            base_path (str): Đường dẫn gốc, mặc định là thư mục hiện tại
        """
        if base_path is None:
            self.base_path = Path(__file__).parent.parent
        else:
            self.base_path = Path(base_path)
    
    def read_xlsx_all_sheets(self, file_path):
        """
        Đọc toàn bộ sheet của file Excel
        
        Args:
            file_path (str): Đường dẫn đến file xlsx
            
        Returns:
            dict: Dictionary chứa tất cả sheet với tên sheet làm key
        """
        try:
            # Đọc tất cả sheet
            all_sheets = pd.read_excel(file_path, sheet_name=None)
            
            print(f"📊 Đã đọc file Excel: {file_path}")
            print(f"📋 Số lượng sheet: {len(all_sheets)}")
            
            for sheet_name, df in all_sheets.items():
                print(f"\n🔸 Sheet: '{sheet_name}'")
                print(f"   - Số hàng: {len(df)}")
                print(f"   - Số cột: {len(df.columns)}")
                print(f"   - Tên cột: {list(df.columns)}")
                
                # Hiển thị 5 hàng đầu
                if not df.empty:
                    print(f"   - 5 hàng đầu:")
                    print(df.head().to_string(index=False))
                else:
                    print("   - Sheet trống")
                print("-" * 50)
            
            return all_sheets
            
        except Exception as e:
            print(f"❌ Lỗi khi đọc file Excel {file_path}: {str(e)}")
            return None
    
    def read_pdf_with_pypdf2(self, file_path):
        """
        Đọc file PDF sử dụng PyPDF2
        
        Args:
            file_path (str): Đường dẫn đến file PDF
            
        Returns:
            str: Nội dung text của PDF
        """
        try:
            text_content = ""
            
            with open(file_path, 'rb') as file:
                pdf_reader = PyPDF2.PdfReader(file)
                num_pages = len(pdf_reader.pages)
                
                print(f"📄 Đọc PDF với PyPDF2: {file_path}")
                print(f"📃 Số trang: {num_pages}")
                
                for page_num in range(num_pages):
                    page = pdf_reader.pages[page_num]
                    page_text = page.extract_text()
                    text_content += f"\n--- TRANG {page_num + 1} ---\n"
                    text_content += page_text
                    
                    # Hiển thị preview 200 ký tự đầu của mỗi trang
                    preview = page_text[:200].replace('\n', ' ')
                    print(f"   Trang {page_num + 1}: {preview}...")
            
            return text_content
            
        except Exception as e:
            print(f"❌ Lỗi khi đọc PDF với PyPDF2 {file_path}: {str(e)}")
            return None
    
    def read_pdf_with_pdfplumber(self, file_path):
        """
        Đọc file PDF sử dụng pdfplumber (tốt hơn cho bảng và layout phức tạp)
        
        Args:
            file_path (str): Đường dẫn đến file PDF
            
        Returns:
            dict: Dictionary chứa text và tables
        """
        try:
            result = {
                'text': "",
                'tables': []
            }
            
            with pdfplumber.open(file_path) as pdf:
                print(f"📄 Đọc PDF với pdfplumber: {file_path}")
                print(f"📃 Số trang: {len(pdf.pages)}")
                
                for page_num, page in enumerate(pdf.pages):
                    # Trích xuất text
                    page_text = page.extract_text()
                    if page_text:
                        result['text'] += f"\n--- TRANG {page_num + 1} ---\n"
                        result['text'] += page_text
                        
                        # Hiển thị preview
                        preview = page_text[:200].replace('\n', ' ')
                        print(f"   Trang {page_num + 1}: {preview}...")
                    
                    # Trích xuất bảng
                    tables = page.extract_tables()
                    if tables:
                        print(f"   🔸 Tìm thấy {len(tables)} bảng trong trang {page_num + 1}")
                        for table_num, table in enumerate(tables):
                            result['tables'].append({
                                'page': page_num + 1,
                                'table_number': table_num + 1,
                                'data': table
                            })
            
            return result
            
        except Exception as e:
            print(f"❌ Lỗi khi đọc PDF với pdfplumber {file_path}: {str(e)}")
            return None
    
    def save_results_to_files(self, xlsx_data, pdf_data, output_dir="output"):
        """
        Lưu kết quả đọc file vào các file text
        
        Args:
            xlsx_data (dict): Dữ liệu từ Excel
            pdf_data (dict): Dữ liệu từ PDF
            output_dir (str): Thư mục output
        """
        output_path = self.base_path / output_dir
        output_path.mkdir(exist_ok=True)
        
        # Lưu dữ liệu Excel
        if xlsx_data:
            for sheet_name, df in xlsx_data.items():
                file_name = f"excel_sheet_{sheet_name.replace(' ', '_')}.txt"
                file_path = output_path / file_name
                
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(f"SHEET: {sheet_name}\n")
                    f.write("=" * 50 + "\n")
                    f.write(df.to_string(index=False))
                
                print(f"💾 Đã lưu sheet '{sheet_name}' vào: {file_path}")
        
        # Lưu dữ liệu PDF
        if pdf_data and 'text' in pdf_data:
            pdf_file_path = output_path / "pdf_content.txt"
            with open(pdf_file_path, 'w', encoding='utf-8') as f:
                f.write("NỘI DUNG PDF\n")
                f.write("=" * 50 + "\n")
                f.write(pdf_data['text'])
            
            print(f"💾 Đã lưu nội dung PDF vào: {pdf_file_path}")
            
            # Lưu bảng từ PDF
            if pdf_data.get('tables'):
                tables_file_path = output_path / "pdf_tables.txt"
                with open(tables_file_path, 'w', encoding='utf-8') as f:
                    f.write("BẢNG TRONG PDF\n")
                    f.write("=" * 50 + "\n")
                    
                    for table_info in pdf_data['tables']:
                        f.write(f"\nTrang {table_info['page']}, Bảng {table_info['table_number']}:\n")
                        f.write("-" * 30 + "\n")
                        
                        for row in table_info['data']:
                            f.write(" | ".join([str(cell) if cell else "" for cell in row]) + "\n")
                        f.write("\n")
                
                print(f"💾 Đã lưu bảng PDF vào: {tables_file_path}")

def main():
    """Hàm main để chạy script"""
    print("🚀 Bắt đầu đọc file xlsx và pdf...")
    print("=" * 60)
    
    # Khởi tạo FileReader
    reader = FileReader()
    
    # Đường dẫn đến các file
    xlsx_file = reader.base_path / "Docs" / "AppNghiPhep" / "Book1.xlsx"
    pdf_file = reader.base_path / "Docs" / "URD_App_nghi_phep_AsiaShine - 11.10.2023.pdf"
    
    # Kiểm tra file tồn tại
    if not xlsx_file.exists():
        print(f"❌ File Excel không tồn tại: {xlsx_file}")
        return
    
    if not pdf_file.exists():
        print(f"❌ File PDF không tồn tại: {pdf_file}")
        return
    
    # Đọc file Excel
    print("\n📊 ĐANG ĐỌC FILE EXCEL...")
    xlsx_data = reader.read_xlsx_all_sheets(xlsx_file)
    
    # Đọc file PDF
    print("\n📄 ĐANG ĐỌC FILE PDF...")
    pdf_data = reader.read_pdf_with_pdfplumber(pdf_file)
    
    # Lưu kết quả
    print("\n💾 ĐANG LƯU KẾT QUẢ...")
    reader.save_results_to_files(xlsx_data, pdf_data)
    
    print("\n✅ Hoàn thành! Kiểm tra thư mục 'output' để xem kết quả.")

if __name__ == "__main__":
    main() 