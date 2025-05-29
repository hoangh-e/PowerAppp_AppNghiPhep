# 📊 SAMPLE DATA CHO SHAREPOINT

## 🎯 Hướng dẫn nhập dữ liệu

### ⚠️ **LƯU Ý VỀ TIÊU ĐỀ CỘT:**
- **Sample data dưới đây** sử dụng tiêu đề cột đơn giản để dễ đọc
- **Khi tạo SharePoint Lists**, vui lòng tham khảo file `output/excel_sheet_Cơ_sở_dữ_liệu.txt` để có thông tin chi tiết về:
  - **Loại thuộc tính**: required/optional/auto/calculated/default
  - **Kiểu dữ liệu**: text/number/date/datetime/choice/boolean/GUID/lookup
  - **Constraints**: max length, range, unique, etc.
  - **Relationships**: Primary Key (PK), Foreign Key (FK)

### Thứ tự nhập dữ liệu (quan trọng):
1. **DonVi** → **Quyen** → **VaiTro** → **LoaiNghi** → **NgayLe** → **CauHinhHeThong** → **MauEmail**
2. **NguoiDung** 
3. **SoNgayPhep** → **QuyTrinhDuyet**
4. **DonNghiPhep**

---

## 🔄 THỨ TỰ IMPORT (QUAN TRỌNG)

**Bắt buộc import theo thứ tự sau để tránh lỗi reference:**

1. **Quyen** (Permissions) - Không phụ thuộc
2. **VaiTro** (Roles) - Phụ thuộc Quyen  
3. **LoaiNghi** (Leave Types) - Không phụ thuộc
4. **NgayLe** (Holidays) - Không phụ thuộc
5. **NguoiDung** (Users) - Phụ thuộc VaiTro
6. **QuyTrinhDuyet** (Approval Process) - Phụ thuộc VaiTro
7. **SoNgayPhep** (Leave Quota) - Phụ thuộc NguoiDung
8. **DonNghiPhep** (Leave Requests) - Phụ thuộc NguoiDung, LoaiNghi
9. **CauHinh** (Configuration) - Không phụ thuộc
10. **LichLamViec** (Work Calendar) - Không phụ thuộc
11. **NghiPhepTheoNhom** (Team Leave Summary) - Phụ thuộc NguoiDung

---

## 📋 **1. BẢNG DONVI**
*Tham khảo schema: MaDonVi (text required, PK), TenDonVi (text required), DonViCha (text optional, FK)*

| MaDonVi | TenDonVi | DonViCha |
|---------|----------|----------|
| ASIA | Công ty TNHH AsiaShine | |
| IT | Phòng Công nghệ thông tin | ASIA |
| HR | Phòng Nhân sự | ASIA |
| SALE | Phòng Kinh doanh | ASIA |
| FINANCE | Phòng Tài chính | ASIA |
| MARKETING | Phòng Marketing | ASIA |

---

## 🔐 QUYEN (Permissions) - HỆ THỐNG TỐI ƯU HÓA

| MaQuyen | TenQuyen | MoTa | GiaTri |
|---------|----------|------|--------|
| PERSONAL_LEAVE | Quyền nghỉ phép cá nhân | Tạo, sửa, xóa, xem đơn nghỉ phép của bản thân | 1 |
| SPECIAL_LEAVE | Tạo đơn nghỉ phép đặc biệt | Tạo đơn nghỉ phép vượt quy định | 2 |
| VIEW_TEAM_LEAVE | Xem đơn nghỉ của team | Quyền xem đơn nghỉ phép của nhân viên dưới quyền | 4 |
| VIEW_ALL_LEAVE | Xem tất cả đơn nghỉ | Quyền xem đơn nghỉ phép của tất cả nhân viên | 8 |
| APPROVE_LEVEL_1 | Phê duyệt cấp 1 | Quyền phê duyệt đơn nghỉ phép cấp 1 (Manager) | 16 |
| APPROVE_LEVEL_2 | Phê duyệt cấp 2 | Quyền phê duyệt đơn nghỉ phép cấp 2 (Director khối) | 32 |
| APPROVE_LEVEL_3 | Phê duyệt cấp 3 | Quyền phê duyệt đơn nghỉ phép cấp 3 (Director điều hành) | 64 |
| RECORD_LEAVE | Ghi nhận nghỉ phép | Quyền ghi nhận và xác nhận nghỉ phép đã thực hiện | 128 |
| VIEW_DASHBOARD | Xem dashboard | Quyền xem dashboard và báo cáo thống kê | 256 |
| EXPORT_REPORTS | Xuất báo cáo | Quyền xuất file báo cáo CSV, Excel | 512 |
| MANAGE_LEAVE_QUOTA | Quản lý quota ngày phép | Quyền cập nhật số ngày phép hàng năm | 1024 |
| MANAGE_HOLIDAYS | Quản lý ngày lễ | Quyền thêm, sửa, xóa ngày nghỉ lễ và cấu hình | 2048 |
| MANAGE_USERS | Quản lý người dùng | Quyền thêm, sửa, xóa thông tin người dùng | 4096 |
| MANAGE_ROLES | Quản lý vai trò | Quyền gán và chỉnh sửa vai trò người dùng | 8192 |
| MANAGE_APPROVAL_PROCESS | Quản lý quy trình phê duyệt | Quyền thiết lập quy trình phê duyệt 3 cấp | 16384 |
| SYSTEM_ADMIN | Quản trị hệ thống | Quyền cấu hình hệ thống và xem audit logs | 32768 |

---

## 👥 VAITRO (Roles) - PHÂN QUYỀN TỐI ƯU HÓA

| MaVaiTro | TenVaiTro | MoTa | CacQuyen |
|----------|-----------|------|----------|
| EMPLOYEE | Nhân viên | Nhân viên thông thường | PERSONAL_LEAVE;SPECIAL_LEAVE;VIEW_DASHBOARD |
| MANAGER | Quản lý | Trưởng nhóm/phòng/bộ phận | PERSONAL_LEAVE;SPECIAL_LEAVE;VIEW_DASHBOARD;VIEW_TEAM_LEAVE;APPROVE_LEVEL_1 |
| DIRECTOR | Giám đốc | Giám đốc khối/điều hành | PERSONAL_LEAVE;SPECIAL_LEAVE;VIEW_DASHBOARD;VIEW_TEAM_LEAVE;APPROVE_LEVEL_1;APPROVE_LEVEL_2;APPROVE_LEVEL_3;MANAGE_HOLIDAYS |
| HR | Nhân sự | Chuyên viên nhân sự | PERSONAL_LEAVE;SPECIAL_LEAVE;VIEW_DASHBOARD;VIEW_ALL_LEAVE;RECORD_LEAVE;EXPORT_REPORTS;MANAGE_LEAVE_QUOTA;MANAGE_HOLIDAYS |
| ADMIN | Quản trị viên | Quản trị hệ thống | PERSONAL_LEAVE;VIEW_ALL_LEAVE;VIEW_DASHBOARD;MANAGE_HOLIDAYS;MANAGE_USERS;MANAGE_ROLES;MANAGE_APPROVAL_PROCESS;SYSTEM_ADMIN |

**Giá trị bit tương ứng:**
- **EMPLOYEE**: 259 (1+2+256)
- **MANAGER**: 279 (259+4+16) 
- **DIRECTOR**: 2423 (279+32+64+2048)
- **HR**: 4979 (259+8+128+512+1024+2048)
- **ADMIN**: 63753 (1+8+256+2048+4096+8192+16384+32768)

---

## 📋 **4. BẢNG LOAINGHI**
*Tham khảo schema: MaLoai (text required, PK), TenLoai (text required), CoLuong (boolean required), MoTa (text optional)*

| MaLoai | TenLoai | CoLuong | MoTa |
|--------|---------|---------|------|
| AL | Nghỉ phép năm | true | Nghỉ phép có lương theo quy định |
| SL | Nghỉ ốm | true | Nghỉ ốm có lương |
| UL | Nghỉ không lương | false | Nghỉ việc riêng không lương |
| ML | Nghỉ thai sản | true | Nghỉ thai sản có lương |
| BL | Nghỉ tang | true | Nghỉ tang có lương |
| CL | Nghỉ cưới | true | Nghỉ cưới có lương |
| EL | Nghỉ khẩn cấp | true | Nghỉ khẩn cấp có lương |

---

## 📋 **5. BẢNG NGAYLE**
*Tham khảo schema: MaNgayLe (number auto, PK), Ngay (text required), TenNgayLe (text required), Buoi (choice required), Nam (number required)*

| MaNgayLe | Ngay | TenNgayLe | Buoi | Nam |
|----------|------|-----------|------|-----|
| 1 | 01/01 | Tết Dương lịch | CaNgay | 2024 |
| 2 | 08/02 | Tết Nguyên đán (28 Tết) | CaNgay | 2024 |
| 3 | 09/02 | Tết Nguyên đán (29 Tết) | CaNgay | 2024 |
| 4 | 10/02 | Tết Nguyên đán (Mùng 1) | CaNgay | 2024 |
| 5 | 11/02 | Tết Nguyên đán (Mùng 2) | CaNgay | 2024 |
| 6 | 12/02 | Tết Nguyên đán (Mùng 3) | CaNgay | 2024 |
| 7 | 13/02 | Tết Nguyên đán (Mùng 4) | CaNgay | 2024 |
| 8 | 14/02 | Tết Nguyên đán (Mùng 5) | CaNgay | 2024 |
| 9 | 18/04 | Giỗ tổ Hùng Vương | CaNgay | 2024 |
| 10 | 30/04 | Ngày Giải phóng miền Nam | CaNgay | 2024 |
| 11 | 01/05 | Ngày Quốc tế Lao động | CaNgay | 2024 |
| 12 | 02/09 | Ngày Quốc khánh | CaNgay | 2024 |

---

## 📋 **6. BẢNG CAUHINHETHONG**
*Tham khảo schema: MaCauHinh (text required, PK), TenCauHinh (text required), GiaTri (text required), KieuDuLieu (choice required), MoTa (text optional), MaDonVi (text optional, FK), NgayCapNhat (datetime auto), NguoiCapNhat (text required, FK)*

| MaCauHinh | TenCauHinh | GiaTri | KieuDuLieu | MoTa | MaDonVi | NgayCapNhat | NguoiCapNhat |
|-----------|------------|--------|------------|------|---------|-------------|--------------|
| MAX_LEAVE_DAYS | Số ngày phép tối đa | 20 | Number | Số ngày phép tối đa trong năm | | 2024-01-01T00:00:00Z | ADM001 |
| MIN_ADVANCE_DAYS | Số ngày báo trước tối thiểu | 3 | Number | Số ngày phải báo trước khi nghỉ phép | | 2024-01-01T00:00:00Z | ADM001 |
| MAX_CONTINUOUS_DAYS | Số ngày nghỉ liên tục tối đa | 10 | Number | Số ngày nghỉ liên tục tối đa | | 2024-01-01T00:00:00Z | ADM001 |
| AUTO_APPROVE_DAYS | Ngày tự động phê duyệt | 7 | Number | Số ngày tự động phê duyệt nếu không có phản hồi | | 2024-01-01T00:00:00Z | ADM001 |
| COMPANY_NAME | Tên công ty | Công ty TNHH AsiaShine | Text | Tên công ty hiển thị | | 2024-01-01T00:00:00Z | ADM001 |
| EMAIL_NOTIFICATION | Bật thông báo email | true | Boolean | Có gửi email thông báo hay không | | 2024-01-01T00:00:00Z | ADM001 |

---

## 📋 **7. BẢNG MAUEMAIL**

| MaMau | TenMau | TieuDe | NoiDung | ThamSo | LoaiSuKien | TrangThai | NgayTao | NgayCapNhat |
|-------|--------|--------|---------|---------|------------|-----------|---------|-------------|
| NEW_REQUEST | Đơn nghỉ phép mới | [AsiaShine] Đơn nghỉ phép mới từ {TenNhanVien} | `<p>Xin chào {TenNguoiDuyet},</p><p>Bạn có đơn nghỉ phép mới cần phê duyệt:</p><ul><li>Nhân viên: {TenNhanVien}</li><li>Loại nghỉ: {LoaiNghi}</li><li>Thời gian: {NgayBatDau} - {NgayKetThuc}</li><li>Số ngày: {SoNgayNghi}</li><li>Lý do: {LyDo}</li></ul><p>Vui lòng truy cập hệ thống để phê duyệt.</p>` | {"TenNhanVien":"text","TenNguoiDuyet":"text","LoaiNghi":"text","NgayBatDau":"date","NgayKetThuc":"date","SoNgayNghi":"number","LyDo":"text"} | TaoDon | HoatDong | 2024-01-01T00:00:00Z | 2024-01-01T00:00:00Z |
| APPROVED | Đơn được phê duyệt | [AsiaShine] Đơn nghỉ phép đã được phê duyệt | `<p>Xin chào {TenNhanVien},</p><p>Đơn nghỉ phép của bạn đã được phê duyệt:</p><ul><li>Mã đơn: {MaDon}</li><li>Thời gian: {NgayBatDau} - {NgayKetThuc}</li><li>Người phê duyệt: {TenNguoiDuyet}</li><li>Ý kiến: {GhiChu}</li></ul><p>Chúc bạn có kỳ nghỉ vui vẻ!</p>` | {"TenNhanVien":"text","MaDon":"text","NgayBatDau":"date","NgayKetThuc":"date","TenNguoiDuyet":"text","GhiChu":"text"} | PheDuyet | HoatDong | 2024-01-01T00:00:00Z | 2024-01-01T00:00:00Z |
| REJECTED | Đơn bị từ chối | [AsiaShine] Đơn nghỉ phép bị từ chối | `<p>Xin chào {TenNhanVien},</p><p>Đơn nghỉ phép của bạn đã bị từ chối:</p><ul><li>Mã đơn: {MaDon}</li><li>Thời gian: {NgayBatDau} - {NgayKetThuc}</li><li>Người từ chối: {TenNguoiDuyet}</li><li>Lý do từ chối: {GhiChu}</li></ul><p>Vui lòng liên hệ để biết thêm chi tiết.</p>` | {"TenNhanVien":"text","MaDon":"text","NgayBatDau":"date","NgayKetThuc":"date","TenNguoiDuyet":"text","GhiChu":"text"} | TuChoi | HoatDong | 2024-01-01T00:00:00Z | 2024-01-01T00:00:00Z |
| EXPIRED | Đơn hết hạn | [AsiaShine] Đơn nghỉ phép hết hạn phê duyệt | `<p>Xin chào {TenNguoiDuyet},</p><p>Đơn nghỉ phép sau đây đã hết hạn phê duyệt:</p><ul><li>Nhân viên: {TenNhanVien}</li><li>Mã đơn: {MaDon}</li><li>Thời gian: {NgayBatDau} - {NgayKetThuc}</li><li>Hạn phê duyệt: {ThoiHanDuyet}</li></ul><p>Vui lòng xử lý ngay.</p>` | {"TenNhanVien":"text","TenNguoiDuyet":"text","MaDon":"text","NgayBatDau":"date","NgayKetThuc":"date","ThoiHanDuyet":"datetime"} | HetHan | HoatDong | 2024-01-01T00:00:00Z | 2024-01-01T00:00:00Z |

---

## 📋 **8. BẢNG NGUOIDUNG**
*Tham khảo schema: MaNhanVien (text required, PK), HoTen (text required), Email (text required, unique), SoDienThoai (text optional), ChucDanh (text optional), MaDonVi (text required, FK), MaVaiTro (text required, FK), NgayVaoLam (date optional), NgaySinh (date optional), GioiTinh (choice optional), DiaChi (text optional), TrangThai (choice required), Avatar (text optional), MaQuanLy (text optional, FK), NgayTao (datetime auto), NgayCapNhat (datetime auto)*

| MaNhanVien | HoTen | Email | SoDienThoai | ChucDanh | MaDonVi | MaVaiTro | NgayVaoLam | NgaySinh | GioiTinh | DiaChi | TrangThai | Avatar | MaQuanLy | NgayTao | NgayCapNhat |
|------------|-------|-------|-------------|----------|---------|----------|------------|----------|----------|--------|-----------|--------|----------|---------|-------------|
| EMP001 | Nguyễn Văn An | an.nguyen@asiashine.com | 0901234567 | Nhân viên IT | IT | EMPLOYEE | 2023-01-15 | 1995-05-20 | Nam | 123 Nguyễn Huệ, Q1, TP.HCM | HoatDong | | MGR001 | 2023-01-15T00:00:00Z | 2024-01-01T00:00:00Z |
| MGR001 | Trần Thị Bình | binh.tran@asiashine.com | 0901234568 | Trưởng phòng IT | IT | MANAGER | 2022-03-01 | 1988-08-15 | Nu | 456 Lê Lợi, Q1, TP.HCM | HoatDong | | DIR001 | 2022-03-01T00:00:00Z | 2024-01-01T00:00:00Z |
| DIR001 | Lê Văn Cường | cuong.le@asiashine.com | 0901234569 | Giám đốc khối | ASIA | DIRECTOR | 2021-01-01 | 1985-12-10 | Nam | 789 Pasteur, Q3, TP.HCM | HoatDong | | | 2021-01-01T00:00:00Z | 2024-01-01T00:00:00Z |
| DIR002 | Phạm Thị Dung | dung.pham@asiashine.com | 0901234570 | Giám đốc điều hành | ASIA | DIRECTOR | 2020-06-01 | 1982-03-25 | Nu | 321 Võ Văn Tần, Q3, TP.HCM | HoatDong | | | 2020-06-01T00:00:00Z | 2024-01-01T00:00:00Z |
| HR001 | Võ Thị Hoa | hoa.vo@asiashine.com | 0901234571 | Chuyên viên HR | HR | HR | 2022-08-15 | 1990-07-08 | Nu | 654 Cách Mạng Tháng 8, Q10, TP.HCM | HoatDong | | MGR002 | 2022-08-15T00:00:00Z | 2024-01-01T00:00:00Z |
| MGR002 | Hoàng Văn Đức | duc.hoang@asiashine.com | 0901234572 | Trưởng phòng HR | HR | MANAGER | 2021-05-01 | 1987-11-20 | Nam | 987 Điện Biên Phủ, Q3, TP.HCM | HoatDong | | DIR001 | 2021-05-01T00:00:00Z | 2024-01-01T00:00:00Z |
| ADM001 | Nguyễn Thị Mai | mai.nguyen@asiashine.com | 0901234573 | Quản trị hệ thống | IT | ADMIN | 2021-09-01 | 1992-04-12 | Nu | 147 Nguyễn Thị Minh Khai, Q1, TP.HCM | HoatDong | | MGR001 | 2021-09-01T00:00:00Z | 2024-01-01T00:00:00Z |
| EMP002 | Trần Văn Hùng | hung.tran@asiashine.com | 0901234574 | Nhân viên Sale | SALE | EMPLOYEE | 2023-06-01 | 1996-09-18 | Nam | 258 Hai Bà Trưng, Q1, TP.HCM | HoatDong | | MGR003 | 2023-06-01T00:00:00Z | 2024-01-01T00:00:00Z |
| MGR003 | Lê Thị Lan | lan.le@asiashine.com | 0901234575 | Trưởng phòng Sale | SALE | MANAGER | 2022-01-15 | 1989-06-30 | Nu | 369 Trần Hưng Đạo, Q5, TP.HCM | HoatDong | | DIR001 | 2022-01-15T00:00:00Z | 2024-01-01T00:00:00Z |
| EMP003 | Phạm Văn Tài | tai.pham@asiashine.com | 0901234576 | Nhân viên Marketing | MARKETING | EMPLOYEE | 2023-09-01 | 1997-01-22 | Nam | 741 Nguyễn Văn Cừ, Q5, TP.HCM | HoatDong | | MGR004 | 2023-09-01T00:00:00Z | 2024-01-01T00:00:00Z |
| MGR004 | Vũ Thị Nga | nga.vu@asiashine.com | 0901234577 | Trưởng phòng Marketing | MARKETING | MANAGER | 2022-04-01 | 1986-10-05 | Nu | 852 Lý Thường Kiệt, Q10, TP.HCM | HoatDong | | DIR001 | 2022-04-01T00:00:00Z | 2024-01-01T00:00:00Z |

---

## 📋 **9. BẢNG SONGAYPHEP**

| MaSoPhep | MaNhanVien | Nam | TongNgayDuocPhep | SoNgayDaNghi | SoNgayConLai | SoNgayKhongLuong |
|----------|------------|-----|------------------|--------------|--------------|------------------|
| 1 | EMP001 | 2024 | 20 | 8 | 12 | 2 |
| 2 | MGR001 | 2024 | 22 | 5 | 17 | 0 |
| 3 | DIR001 | 2024 | 25 | 10 | 15 | 1 |
| 4 | DIR002 | 2024 | 25 | 7 | 18 | 0 |
| 5 | HR001 | 2024 | 20 | 6 | 14 | 1 |
| 6 | MGR002 | 2024 | 22 | 9 | 13 | 0 |
| 7 | ADM001 | 2024 | 20 | 4 | 16 | 0 |
| 8 | EMP002 | 2024 | 18 | 3 | 15 | 1 |
| 9 | MGR003 | 2024 | 22 | 8 | 14 | 0 |
| 10 | EMP003 | 2024 | 18 | 2 | 16 | 0 |
| 11 | MGR004 | 2024 | 22 | 6 | 16 | 1 |

---

## 📋 **10. BẢNG QUYTRINHDUYET**

| MaQuyTrinh | MaDonVi | Cap | MaVaiTro | NguoiDuyetMacDinh | DangHoatDong |
|------------|---------|-----|----------|-------------------|--------------|
| 1 | IT | 1 | MANAGER | MGR001 | true |
| 2 | IT | 2 | DIRECTOR | DIR001 | true |
| 3 | IT | 3 | DIRECTOR | DIR002 | true |
| 4 | HR | 1 | MANAGER | MGR002 | true |
| 5 | HR | 2 | DIRECTOR | DIR001 | true |
| 6 | HR | 3 | DIRECTOR | DIR002 | true |
| 7 | SALE | 1 | MANAGER | MGR003 | true |
| 8 | SALE | 2 | DIRECTOR | DIR001 | true |
| 9 | SALE | 3 | DIRECTOR | DIR002 | true |
| 10 | MARKETING | 1 | MANAGER | MGR004 | true |
| 11 | MARKETING | 2 | DIRECTOR | DIR001 | true |
| 12 | MARKETING | 3 | DIRECTOR | DIR002 | true |

---

## 📋 **11. BẢNG DONNGHIPHEP - MỞ RỘNG TRẠNG THÁI**
*Tham khảo schema: MaDon (GUID, PK), MaNhanVien (text required, FK), NgayBatDau (date required), NgayKetThuc (date required), SoNgayNghi (number calculated), MaLoai (text required, FK), LyDo (text required), NguoiBanGiao (text optional, FK), NoiDungBanGiao (text optional), TrangThai (choice required), NgayTao (datetime auto), BuoiNghi (choice required), NguoiTao (text required, FK), NgayCapNhat (datetime auto), NguoiCapNhat (text optional, FK), ThoiHanPheDuyet (datetime calculated), UuTien (choice default), GhiChuHR (text optional), NgayGhiNhan (date optional), GhiChuPheDuyet (text optional)*

**Trạng thái mở rộng:**
- `ChoDuyetCap1` - Chờ Manager phê duyệt (cấp 1)
- `ChoDuyetCap2` - Chờ Director phê duyệt (cấp 2)  
- `ChoDuyetCap3` - Chờ CEO phê duyệt (cấp 3)
- `DaDuyet` - Đã phê duyệt hoàn tất
- `TuChoi` - Bị từ chối
- `Huy` - Đã hủy
- `HetHan` - Hết hạn phê duyệt

| MaDon | MaNhanVien | NgayBatDau | NgayKetThuc | SoNgayNghi | MaLoai | LyDo | NguoiBanGiao | NoiDungBanGiao | TrangThai | NgayTao | BuoiNghi | NguoiTao | NgayCapNhat | NguoiCapNhat | ThoiHanPheDuyet | UuTien | GhiChuHR | NgayGhiNhan | GhiChuPheDuyet |
|-------|------------|------------|-------------|------------|--------|------|--------------|----------------|-----------|---------|----------|----------|-------------|--------------|-----------------|--------|----------|-------------|----------------|
| 550e8400-e29b-41d4-a716-446655440001 | EMP001 | 2024-03-15 | 2024-03-17 | 3 | AL | Nghỉ phép thăm gia đình | MGR001 | Hoàn thành task A, chuyển giao task B cho team | DaDuyet | 2024-03-10T09:00:00Z | CaNgay | EMP001 | 2024-03-12T14:30:00Z | MGR001 | 2024-03-13T17:00:00Z | BinhThuong | Đã ghi nhận | 2024-03-18T08:00:00Z | Đồng ý nghỉ phép |
| 550e8400-e29b-41d4-a716-446655440002 | EMP001 | 2024-04-20 | 2024-04-22 | 3 | SL | Nghỉ ốm | MGR001 | Tạm hoãn meeting, chuyển task cho An | DaDuyet | 2024-04-19T08:30:00Z | CaNgay | EMP001 | 2024-04-19T16:45:00Z | MGR001 | 2024-04-20T17:00:00Z | KhanCap | Đã ghi nhận | 2024-04-23T08:00:00Z | Nghỉ ốm cần thiết |
| 550e8400-e29b-41d4-a716-446655440003 | MGR001 | 2024-05-10 | 2024-05-12 | 3 | AL | Nghỉ phép cá nhân | DIR001 | Ủy quyền cho An xử lý các vấn đề phòng ban | ChoDuyetCap2 | 2024-05-05T10:15:00Z | CaNgay | MGR001 | 2024-05-05T10:15:00Z | MGR001 | 2024-05-08T17:00:00Z | BinhThuong | | | |
| 550e8400-e29b-41d4-a716-446655440004 | EMP002 | 2024-06-01 | 2024-06-01 | 1 | AL | Nghỉ việc riêng | MGR003 | Hoàn thành báo cáo tháng 5 | DaDuyet | 2024-05-28T14:20:00Z | BuoiSang | EMP002 | 2024-05-30T09:10:00Z | MGR003 | 2024-05-31T17:00:00Z | BinhThuong | Đã ghi nhận | 2024-06-02T08:00:00Z | OK cho nửa ngày |
| 550e8400-e29b-41d4-a716-446655440005 | HR001 | 2024-07-15 | 2024-07-19 | 5 | AL | Nghỉ phép hè | MGR002 | Chuyển giao công việc tuyển dụng cho đồng nghiệp | ChoDuyetCap1 | 2024-07-08T11:30:00Z | CaNgay | HR001 | 2024-07-08T11:30:00Z | HR001 | 2024-07-11T17:00:00Z | BinhThuong | | | |
| 550e8400-e29b-41d4-a716-446655440006 | EMP003 | 2024-08-05 | 2024-08-07 | 3 | CL | Nghỉ cưới | MGR004 | Hoàn thành campaign tháng 8 trước khi nghỉ | TuChoi | 2024-07-30T16:45:00Z | CaNgay | EMP003 | 2024-08-01T10:20:00Z | MGR004 | 2024-08-02T17:00:00Z | BinhThuong | | | Thời điểm bận, cần hoãn lại |
| 550e8400-e29b-41d4-a716-446655440007 | DIR001 | 2024-09-20 | 2024-09-27 | 6 | AL | Nghỉ phép dài hạn | DIR002 | Ủy quyền toàn bộ quyết định cho Phạm Thị Dung | ChoDuyetCap3 | 2024-09-10T13:15:00Z | CaNgay | DIR001 | 2024-09-10T13:15:00Z | DIR001 | 2024-09-13T17:00:00Z | BinhThuong | | | |

---

## 🎯 **HƯỚNG DẪN NHẬP DỮ LIỆU VÀO SHAREPOINT**

### Bước 1: Tạo SharePoint Lists
1. Truy cập SharePoint site
2. Tạo các List theo thứ tự ưu tiên
3. Cấu hình columns theo đúng kiểu dữ liệu
4. Thiết lập lookup relationships

### Bước 2: Import dữ liệu
1. **Excel Import**: Copy paste từ bảng trên vào Excel, sau đó import vào SharePoint
2. **Manual Entry**: Nhập thủ công cho dữ liệu nhỏ
3. **PowerAutomate**: Sử dụng flow để import hàng loạt

### Bước 3: Validation
1. Kiểm tra foreign key relationships
2. Test các calculated fields
3. Verify permissions và access

### Bước 4: Testing
1. Test với Power App
2. Kiểm tra performance
3. Validate business logic

## ✅ **LƯU Ý QUAN TRỌNG**

1. **GUID Format**: Sử dụng đúng format GUID cho các trường ID
2. **DateTime Format**: Sử dụng ISO 8601 format (YYYY-MM-DDTHH:mm:ssZ)
3. **Choice Values**: Đảm bảo giá trị choice khớp với định nghĩa
4. **Relationships**: Kiểm tra tất cả foreign key references hợp lệ
5. **Trạng thái mở rộng**: Sử dụng trạng thái chi tiết để quản lý quy trình phê duyệt 3 cấp

## 🔄 **QUY TRÌNH PHÊ DUYỆT ĐƠN GIẢN HÓA**

### Logic phê duyệt:
```
1. Tạo đơn → TrangThai = "ChoDuyetCap1"
2. Manager phê duyệt → TrangThai = "ChoDuyetCap2" (nếu cần) hoặc "DaDuyet"
3. Director phê duyệt → TrangThai = "ChoDuyetCap3" (nếu cần) hoặc "DaDuyet"  
4. CEO phê duyệt → TrangThai = "DaDuyet"
```

### Truy vấn đơn giản:
- Đơn chờ Manager: `Filter(DonNghiPhep, TrangThai = "ChoDuyetCap1")`
- Đơn chờ Director: `Filter(DonNghiPhep, TrangThai = "ChoDuyetCap2")`
- Đơn chờ CEO: `Filter(DonNghiPhep, TrangThai = "ChoDuyetCap3")`
- Đơn hoàn tất: `Filter(DonNghiPhep, TrangThai = "DaDuyet")`

Dữ liệu mẫu này cung cấp đầy đủ scenarios để test toàn bộ chức năng của ứng dụng Power App với hệ thống đơn giản hóa! 