# Scripts Đọc File Excel và PDF

Thư mục này chứa các script Python để đọc toàn bộ sheet của file Excel (.xlsx) và nội dung file PDF.

## 📁 Cấu trúc File

```
scripts/
├── read_files.py          # Script chính với đầy đủ tính năng
├── simple_reader.py       # Script đơn giản để test nhanh
├── requirements.txt       # Danh sách thư viện cần thiết
└── README.md             # File hướng dẫn này
```

## 🚀 Cài đặt

### 1. Cài đặt Python
Đảm bảo bạn đã cài Python 3.7+ trên máy.

### 2. Cài đặt thư viện
```bash
# Di chuyển vào thư mục scripts
cd scripts

# Cài đặt các thư viện cần thiết
pip install -r requirements.txt
```

### 3. Thư viện cần thiết
- `pandas`: Đọc file Excel
- `openpyxl`: Engine để đọc file .xlsx
- `PyPDF2`: Đọc file PDF cơ bản
- `pdfplumber`: Đọc file PDF nâng cao (bảng, layout phức tạp)

## 📊 Sử dụng

### Script Đơn Giản (Khuyến nghị để test)
```bash
python simple_reader.py
```

### Script Đầy Đủ Tính Năng
```bash
python read_files.py
```

## 🔧 Tính Năng

### 📈 Đọc File Excel
- ✅ Đọc tất cả sheet trong file
- ✅ Hiển thị thông tin chi tiết mỗi sheet
- ✅ Hiển thị tên cột và dữ liệu mẫu
- ✅ Lưu từng sheet vào file text riêng

### 📄 Đọc File PDF
- ✅ Đọc toàn bộ nội dung text
- ✅ Trích xuất bảng từ PDF
- ✅ Hiển thị preview từng trang
- ✅ Lưu nội dung và bảng vào file text

### 💾 Lưu Kết Quả
- ✅ Tự động tạo thư mục `output`
- ✅ Lưu từng sheet Excel thành file riêng
- ✅ Lưu nội dung PDF và bảng

## 📂 File Đầu Vào

Script sẽ tự động tìm và đọc:
- **Excel**: `Docs/AppNghiPhep/Book1.xlsx`
- **PDF**: `Docs/URD_App_nghi_phep_AsiaShine - 11.10.2023.pdf`

## 📤 File Đầu Ra

Kết quả sẽ được lưu trong thư mục `output/`:
- `excel_sheet_[tên_sheet].txt`: Nội dung từng sheet
- `pdf_content.txt`: Toàn bộ nội dung PDF
- `pdf_tables.txt`: Các bảng trích xuất từ PDF

## 🐛 Xử Lý Lỗi

### Lỗi thường gặp:
1. **ModuleNotFoundError**: Chưa cài thư viện
   ```bash
   pip install pandas openpyxl PyPDF2 pdfplumber
   ```

2. **FileNotFoundError**: File không tồn tại
   - Kiểm tra đường dẫn file
   - Đảm bảo file nằm đúng vị trí

3. **PermissionError**: Không có quyền đọc file
   - Kiểm tra quyền truy cập file
   - Đóng file nếu đang mở trong Excel

## 💡 Mẹo Sử dụng

1. **Test nhanh**: Dùng `simple_reader.py` trước
2. **File lớn**: Script sẽ chỉ hiển thị preview, toàn bộ nội dung lưu trong file output
3. **Encoding**: Script tự động xử lý UTF-8 cho tiếng Việt
4. **Bảng PDF**: `pdfplumber` tốt hơn `PyPDF2` cho bảng phức tạp

## 🔄 Tùy Chỉnh

Để đọc file khác, sửa đường dẫn trong hàm `main()`:
```python
xlsx_file = reader.base_path / "đường/dẫn/file.xlsx"
pdf_file = reader.base_path / "đường/dẫn/file.pdf"
```

## 📞 Hỗ Trợ

Nếu gặp vấn đề, kiểm tra:
1. Phiên bản Python (>= 3.7)
2. Thư viện đã cài đầy đủ
3. Đường dẫn file chính xác
4. Quyền truy cập file 