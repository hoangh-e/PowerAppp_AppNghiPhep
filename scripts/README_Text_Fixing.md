# 🔧 Scripts Sửa Lỗi Text Formatting trong YAML

Các scripts này được tạo để sửa lỗi text formatting trong các file YAML của Power App, đặc biệt là lỗi `: ` (dấu hai chấm + khoảng trắng) trong các chuỗi string.

## 📁 Danh sách Scripts

### 1. `run_fix_text.py` - Script Cơ bản
Script đơn giản để sửa lỗi `: ` thành `:` trong tất cả file YAML.

**Cách sử dụng:**
```bash
# Chạy trên toàn bộ project
python scripts/run_fix_text.py

# Hoặc chạy trực tiếp batch file (Windows)
scripts/fix_text.bat
```

**Tính năng:**
- ✅ Tìm tất cả file `.yaml` và `.yml` trong project
- ✅ Sửa `": "` thành `":"` trong chuỗi string
- ✅ Tự động tạo backup (`.backup`)
- ✅ Hiển thị thống kê thay đổi

### 2. `advanced_fix_text.py` - Script Nâng cao
Script có nhiều tùy chọn và xử lý thông minh hơn.

**Cách sử dụng:**
```bash
# Dry run - chỉ xem không thay đổi
python scripts/advanced_fix_text.py --dry-run

# Xử lý một file cụ thể
python scripts/advanced_fix_text.py --file src/Screens/AttachmentScreen.yaml

# Xử lý thư mục cụ thể
python scripts/advanced_fix_text.py --directory src/Components

# Bao gồm cả notification text (ít an toàn)
python scripts/advanced_fix_text.py --fix-notifications

# Không sửa lỗi colon space
python scripts/advanced_fix_text.py --no-colon-fix
```

**Tính năng nâng cao:**
- ✅ Dry run mode
- ✅ Xử lý file/thư mục cụ thể
- ✅ Bỏ qua notification text (an toàn hơn)
- ✅ Hiển thị diff chi tiết
- ✅ Tùy chọn bật/tắt từng loại sửa lỗi

### 3. `fix_text_formatting.py` - Script Đầy đủ
Script hoàn chỉnh với tất cả tính năng và error handling.

**Cách sử dụng:**
```bash
# Xử lý thư mục hiện tại
python scripts/fix_text_formatting.py

# Xử lý thư mục cụ thể
python scripts/fix_text_formatting.py src/

# Xử lý một file
python scripts/fix_text_formatting.py --file path/to/file.yaml

# Dry run
python scripts/fix_text_formatting.py --dry-run
```

## 🎯 Các Lỗi Được Sửa

### ❌ Lỗi Thường Gặp:
```yaml
# SAI
Text: ="Email: " & ThisItem.Email
Text: ="Trạng thái: " & status
Text: ="Đã chọn file: " & filename

# ĐÚNG  
Text: ="Email:" & " " & ThisItem.Email
Text: ="Trạng thái:" & " " & status
Text: ="Đã chọn file:" & " " & filename
```

### ✅ Patterns Được Sửa:
- `"Email: "` → `"Email:"`
- `"Tên: "` → `"Tên:"`
- `"Vai trò: "` → `"Vai trò:"`
- `"Đơn: "` → `"Đơn:"`
- `"File: "` → `"File:"`
- Và nhiều patterns khác...

### 🚫 Patterns Được Bỏ Qua (Script Nâng cao):
- Notification text: `"Đã xóa file: " & filename`
- URL và paths
- Các chuỗi chứa `notify`, `thông báo`, etc.

## 📊 Thống Kê Kết Quả

Sau khi chạy script cơ bản trên toàn bộ project:

```
✅ Đã sửa file YAML: 42/55 file
📊 Tổng số lỗi đã sửa: 203 lỗi `: ` thành `:`

Top files với nhiều lỗi nhất:
1. src/Screens/ReportsScreen.yaml: 126 lỗi
2. src/Screens/ReportsScreen_SharePoint.yaml: 14 lỗi
3. src/Screens/LeaveConfirmationScreen.yaml: 7 lỗi
4. src/Screens/LeaveRequestScreen_SharePoint.yaml: 7 lỗi
```

## 🛡️ An toàn

### Backup Tự động
- ✅ Mỗi file được sửa sẽ có backup `.backup`
- ✅ Có thể restore lại dễ dàng nếu cần

### Dry Run Mode
```bash
# Xem trước những gì sẽ thay đổi
python scripts/advanced_fix_text.py --dry-run
```

### Restore từ Backup
```bash
# Restore một file
cp file.yaml.backup file.yaml

# Restore tất cả (bash/git bash)
find . -name "*.backup" -exec sh -c 'cp "$1" "${1%.backup}"' _ {} \;

# PowerShell
Get-ChildItem -Recurse -Filter "*.backup" | ForEach-Object { 
    Copy-Item $_.FullName ($_.FullName -replace '\.backup$','') 
}
```

## 🚀 Cách Sử Dụng Nhanh

### Lần đầu chạy (được khuyến nghị):
```bash
# 1. Dry run để xem trước
python scripts/advanced_fix_text.py --dry-run

# 2. Chạy thật với script an toàn
python scripts/run_fix_text.py

# 3. Kiểm tra kết quả và commit nếu OK
```

### Chạy hàng ngày:
```bash
# Chạy script cơ bản - đơn giản và an toàn
python scripts/run_fix_text.py
```

## 🔍 Troubleshooting

### Lỗi Encoding
```bash
# Nếu gặp lỗi encoding, đảm bảo file được lưu với UTF-8
# Script sẽ tự động xử lý UTF-8
```

### Lỗi Permission
```bash
# Chạy với quyền admin nếu cần (Windows)
# Hoặc chmod +x scripts/*.py (Linux/Mac)
```

### Backup Bị Mất
```bash
# Scripts luôn tạo backup trước khi sửa
# File backup sẽ có extension .backup
```

## 📝 Lưu Ý

1. **Luôn commit code trước khi chạy script**
2. **Chạy dry-run trước khi sửa thật**
3. **Kiểm tra kết quả sau khi sửa**
4. **Script chỉ sửa trong chuỗi string được bao bởi dấu ngoặc kép**
5. **Không ảnh hưởng đến YAML syntax**

## 🎉 Kết Luận

Scripts này giúp:
- ✅ Tiết kiệm thời gian sửa lỗi thủ công
- ✅ Đảm bảo consistency across project  
- ✅ Backup tự động để đảm bảo an toàn
- ✅ Tuân thủ Power App YAML formatting rules

**Happy coding! 🚀** 