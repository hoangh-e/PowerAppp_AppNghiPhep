# 📊 PHÂN TÍCH VÀ CẢI THIỆN CƠ SỞ DỮ LIỆU

## 🔍 Đánh giá cơ sở dữ liệu hiện tại

### ✅ **Điểm mạnh của thiết kế hiện tại:**

1. **Cấu trúc cơ bản đầy đủ**: Có đủ các bảng chính cần thiết
2. **Quan hệ rõ ràng**: Foreign key được định nghĩa đúng
3. **Phân quyền**: Có bảng vai trò và quy trình phê duyệt
4. **Tính toán**: Có trường calculated cho số ngày còn lại

### ❌ **Vấn đề cần cải thiện:**

#### 1. **Thiếu bảng quan trọng**
- Không có bảng **Thông báo** (Notifications)
- Không có bảng **Lịch sử thay đổi** (Audit Log)
- Không có bảng **Cấu hình hệ thống** (System Settings)

#### 2. **Thiếu trường quan trọng**
- Bảng `NguoiDung`: Thiếu trường `NgayVaoLam`, `TrangThai`, `Avatar`
- Bảng `DonNghiPhep`: Thiếu trường `BuoiNghi`, `NguoiTao`, `NgayCapNhat`
- Bảng `PheDuyetDon`: Thiếu trường `ThoiHanDuyet`, `NgayHetHan`

#### 3. **Kiểu dữ liệu chưa tối ưu**
- `TepDinhKem` nên là `Attachments` (multiple files)
- `TrangThai` nên có giá trị mặc định
- Thiếu validation cho các trường quan trọng

#### 4. **Thiếu index và constraint**
- Không có unique constraint cho Email
- Thiếu index cho các trường thường query
- Thiếu check constraint cho logic nghiệp vụ

## 🔧 **CẢI THIỆN ĐỀ XUẤT**

### 1. **Bổ sung bảng mới**

#### Bảng `ThongBao` (Notifications)
```sql
ThongBao:
  MaThongBao: number (auto) - Primary Key
  MaNguoiNhan: text - FK → NguoiDung.MaNhanVien
  TieuDe: text - Tiêu đề thông báo
  NoiDung: text (long) - Nội dung chi tiết
  LoaiThongBao: choice - ['DonMoi', 'PheDuyet', 'TuChoi', 'HetHan']
  MaDonLienQuan: GUID - FK → DonNghiPhep.MaDon (optional)
  DaDoc: boolean - Default: false
  NgayTao: datetime - Thời điểm tạo
  NgayDoc: datetime - Thời điểm đọc (optional)
```

#### Bảng `LichSuThayDoi` (Audit Log)
```sql
LichSuThayDoi:
  MaLichSu: number (auto) - Primary Key
  BangDuLieu: text - Tên bảng bị thay đổi
  MaBanGhi: text - ID của bản ghi
  HanhDong: choice - ['Tao', 'Sua', 'Xoa']
  DuLieuCu: text (long) - JSON dữ liệu cũ
  DuLieuMoi: text (long) - JSON dữ liệu mới
  MaNguoiThucHien: text - FK → NguoiDung.MaNhanVien
  NgayThucHien: datetime - Thời điểm thay đổi
  GhiChu: text - Mô tả thay đổi
```

#### Bảng `CauHinhHeThong` (System Settings)
```sql
CauHinhHeThong:
  MaCauHinh: text - Primary Key (VD: 'MAX_LEAVE_DAYS')
  TenCauHinh: text - Tên hiển thị
  GiaTri: text - Giá trị cấu hình
  KieuDuLieu: choice - ['Text', 'Number', 'Boolean', 'JSON']
  MoTa: text - Mô tả cấu hình
  MaDonVi: text - FK → DonVi.MaDonVi (optional)
  NgayCapNhat: datetime - Lần cập nhật cuối
  NguoiCapNhat: text - FK → NguoiDung.MaNhanVien
```

### 2. **Cải thiện bảng hiện có**

#### Bảng `NguoiDung` - Bổ sung trường
```sql
NguoiDung:
  # Các trường hiện có...
  NgayVaoLam: date - Ngày bắt đầu làm việc
  NgaySinh: date - Ngày sinh
  GioiTinh: choice - ['Nam', 'Nu', 'Khac']
  DiaChi: text - Địa chỉ liên hệ
  TrangThai: choice - ['HoatDong', 'TamNghi', 'DaNghi'] - Default: 'HoatDong'
  Avatar: image - Ảnh đại diện
  MaQuanLy: text - FK → NguoiDung.MaNhanVien (Người quản lý trực tiếp)
  NgayTao: datetime - Ngày tạo tài khoản
  NgayCapNhat: datetime - Lần cập nhật cuối
```

#### Bảng `DonNghiPhep` - Bổ sung trường
```sql
DonNghiPhep:
  # Các trường hiện có...
  BuoiNghi: choice - ['CaNgay', 'BuoiSang', 'BuoiChieu'] - Default: 'CaNgay'
  NguoiTao: text - FK → NguoiDung.MaNhanVien (Có thể khác MaNhanVien)
  NgayCapNhat: datetime - Lần cập nhật cuối
  NguoiCapNhat: text - FK → NguoiDung.MaNhanVien
  ThoiHanPheDuyet: datetime - Thời hạn phê duyệt
  UuTien: choice - ['Binh Thuong', 'Khan Cap', 'Rat Khan Cap'] - Default: 'Binh Thuong'
  GhiChuHR: text (long) - Ghi chú của HR khi ghi nhận
  NgayGhiNhan: datetime - Ngày HR ghi nhận kết quả
```

#### Bảng `PheDuyetDon` - Bổ sung trường
```sql
PheDuyetDon:
  # Các trường hiện có...
  ThoiHanDuyet: datetime - Thời hạn phê duyệt
  NgayHetHan: datetime - Ngày hết hạn tự động
  ViTriPheDuyet: text - Vị trí phê duyệt (VD: "Trưởng phòng IT")
  TepDinhKem: Attachments - File đính kèm khi phê duyệt
```

### 3. **Bổ sung bảng hỗ trợ**

#### Bảng `TepDinhKem` (Attachments)
```sql
TepDinhKem:
  MaTep: GUID - Primary Key
  MaDon: GUID - FK → DonNghiPhep.MaDon
  TenTep: text - Tên file gốc
  DuongDan: text - Đường dẫn lưu trữ
  KichThuoc: number - Kích thước file (bytes)
  LoaiTep: text - MIME type
  MoTa: text - Mô tả file
  NguoiTai: text - FK → NguoiDung.MaNhanVien
  NgayTai: datetime - Ngày upload
```

#### Bảng `MauEmail` (Email Templates)
```sql
MauEmail:
  MaMau: text - Primary Key
  TenMau: text - Tên template
  TieuDe: text - Subject email
  NoiDung: text (long) - HTML content
  ThamSo: text (long) - JSON parameters
  LoaiSuKien: choice - ['TaoDon', 'PheDuyet', 'TuChoi', 'HetHan']
  TrangThai: choice - ['HoatDong', 'TamNghi'] - Default: 'HoatDong'
  NgayTao: datetime
  NgayCapNhat: datetime
```

### 4. **Cải thiện ràng buộc và validation**

#### Unique Constraints
```sql
NguoiDung.Email - UNIQUE
DonNghiPhep.MaDon - UNIQUE (đã có)
ThongBao.MaThongBao - UNIQUE
```

#### Check Constraints
```sql
DonNghiPhep.NgayKetThuc >= NgayBatDau
DonNghiPhep.SoNgayNghi > 0
SoNgayPhep.TongNgayDuocPhep >= 0
SoNgayPhep.SoNgayDaNghi >= 0
PheDuyetDon.Cap IN (1, 2, 3)
```

#### Default Values
```sql
DonNghiPhep.TrangThai = 'ChoDuyet'
DonNghiPhep.NgayTao = NOW()
NguoiDung.TrangThai = 'HoatDong'
ThongBao.DaDoc = false
```

### 5. **Index để tối ưu performance**

```sql
-- Index cho query thường xuyên
CREATE INDEX idx_donnghiphep_manhanvien ON DonNghiPhep(MaNhanVien)
CREATE INDEX idx_donnghiphep_trangthai ON DonNghiPhep(TrangThai)
CREATE INDEX idx_donnghiphep_ngaytao ON DonNghiPhep(NgayTao)
CREATE INDEX idx_pheduyetdon_manguoiduyet ON PheDuyetDon(MaNguoiDuyet)
CREATE INDEX idx_thongbao_manguoinhan ON ThongBao(MaNguoiNhan)
CREATE INDEX idx_thongbao_dadoc ON ThongBao(DaDoc)
```

## 📋 **BẢNG CƠ SỞ DỮ LIỆU HOÀN CHỈNH SAU CẢI THIỆN**

### Tổng quan các bảng:
1. **DonVi** - Cấu trúc tổ chức
2. **NguoiDung** - Thông tin nhân viên (đã cải thiện)
3. **LoaiNghi** - Danh mục loại nghỉ phép
4. **NgayLe** - Lịch nghỉ lễ
5. **SoNgayPhep** - Quota nghỉ phép
6. **DonNghiPhep** - Đơn nghỉ phép (đã cải thiện)
7. **PheDuyetDon** - Quy trình phê duyệt (đã cải thiện)
8. **QuyTrinhDuyet** - Cấu hình workflow
9. **ThongBao** - Hệ thống thông báo (mới)
10. **LichSuThayDoi** - Audit log (mới)
11. **CauHinhHeThong** - System settings (mới)
12. **TepDinhKem** - File attachments (mới)
13. **MauEmail** - Email templates (mới)

## ✅ **KẾT LUẬN**

Cơ sở dữ liệu hiện tại có **nền tảng tốt** nhưng cần **bổ sung và cải thiện** để đáp ứng đầy đủ yêu cầu của ứng dụng thực tế:

### Cần làm ngay:
1. ✅ Bổ sung 5 bảng mới (ThongBao, LichSuThayDoi, CauHinhHeThong, TepDinhKem, MauEmail)
2. ✅ Cải thiện 3 bảng hiện có (NguoiDung, DonNghiPhep, PheDuyetDon)
3. ✅ Thêm constraints và validation
4. ✅ Tạo index cho performance

### Có thể làm sau:
- Partitioning cho bảng lớn
- Stored procedures cho logic phức tạp
- Views cho báo cáo
- Backup và recovery strategy 