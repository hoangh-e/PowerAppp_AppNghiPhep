# I. Function Description

## 1. Role description table

| Num | Role in app | Short | Description |
|-----|-------------|-------|-------------|
| 1 | Employee | EMP | Nhân viên - Có thể tạo đơn nghỉ phép, xem thông tin cá nhân và lịch nghỉ của mình |
| 2 | Manager | MGR | Trưởng nhóm/phòng/bộ phận - Có quyền phê duyệt cấp 1, xem lịch nghỉ đơn vị |
| 3 | Director | DIR | Giám đốc khối/điều hành - Có quyền phê duyệt cấp 2-3, xem toàn bộ dữ liệu |
| 4 | HR | HR | Nhân sự - Quản lý số ngày phép, ghi nhận nghỉ phép, xuất báo cáo |
| 5 | Admin | ADM | Quản trị viên - Quản lý người dùng, cấu hình hệ thống, phân quyền |

## 2. Matrix function table

| Num | Function | EMP | MGR | DIR | HR | ADM |
|-----|----------|-----|-----|-----|----|----|
| | **Quản lý thông tin hệ thống** | | | | | |
| 1 | Quản lý thông tin người dùng | | | | | x |
| 2 | Quản lý số ngày nghỉ phép | | | | x | |
| 3 | Quản lý lịch nghỉ phép | | | x | x | x |
| 4 | Quản lý quy trình phê duyệt | | | | | x |
| 5 | Quản lý role trong ứng dụng | | | | | x |
| | **Quản lý nghỉ phép** | | | | | |
| 6 | Tạo đơn nghỉ phép | x | x | x | x | |
| 7 | Tạo đơn nghỉ phép vượt quy định (đặc biệt) | x | x | x | x | |
| 8 | Xem thông tin lịch nghỉ cá nhân | x | x | x | x | |
| 9 | Xem lịch nghỉ phép toàn hệ thống | | x | x | x | |
| 10 | Phê duyệt cấp 1 (Trưởng nhóm/phòng/bộ phận) | | x | | | |
| 11 | Phê duyệt cấp 2 (Giám đốc khối) | | | x | | |
| 12 | Phê duyệt cấp 3 (Giám đốc điều hành) | | | x | | |
| 13 | Ghi nhận nghỉ phép (sau phê duyệt) | | | | x | |
| | **Dashboard báo cáo** | | | | | |
| 14 | Theo dõi tình hình nghỉ phép (Dashboard) | x | x | x | x | |
| 15 | Xuất báo cáo thống kê (CSV, theo tháng/năm) | | | | x | |

## 3. Functions master info

| Num | Name | Info |
|-----|------|------|
| 1 | Điều hướng đến các chức năng chính | F01 |
| | Điều hướng menu chính | F01-1 |
| 2 | Xác thực người dùng | F02 |
| | Đăng nhập hệ thống | F02-1 |
| 3 | Xem thông tin cá nhân | F03 |
| | Hiển thị thông tin người dùng | F03-1 |
| | Hiển thị số ngày nghỉ phép còn lại | F03-2 |
| 4 | Tạo đơn nghỉ phép | F04 |
| | Tạo đơn nghỉ phép thường | F04-1 |
| | Kiểm tra điều kiện ngày nghỉ | F04-2 |
| | Gửi yêu cầu phê duyệt | F04-3 |
| 5 | Xem lịch nghỉ cá nhân | F05 |
| | Hiển thị calendar cá nhân | F05-1 |
| 6 | Xem lịch nghỉ toàn công ty | F06 |
| | Hiển thị calendar toàn công ty | F06-1 |
| 7 | Phê duyệt đơn nghỉ phép | F07 |
| | Phê duyệt cấp 1 (Manager) | F07-1 |
| | Phê duyệt cấp 2 (Giám đốc khối) | F07-2 |
| | Phê duyệt cấp 3 (Giám đốc điều hành) | F07-3 |
| 8 | Quản lý người dùng | F08 |
| | Tạo/Sửa thông tin người dùng | F08-1 |
| | Xóa người dùng | F08-2 |
| 9 | Nhập số ngày phép | F09 |
| | Import dữ liệu từ Excel | F09-1 |
| | Cập nhật số ngày phép theo năm | F09-2 |
| 10 | Quản lý lịch nghỉ & ngày lễ | F10 |
| | Thêm/Sửa/Xóa ngày nghỉ cố định | F10-1 |
| | Cấu hình buổi/ngày làm việc trong tuần | F10-2 |
| 11 | Thiết lập quy trình & role | F11 |
| | Thiết lập quy trình phê duyệt 3 cấp | F11-1 |
| | Gán/chỉnh sửa role người dùng | F11-2 |
| 12 | Dashboard báo cáo | F12 |
| | Xem tổng số ngày nghỉ theo tháng | F12-1 |
| | Xem theo nhân viên/phòng ban | F12-2 |
| 13 | Xuất báo cáo | F13 |
| | Xuất file CSV tổng hợp theo tháng/năm | F13-1 |
| | Xuất chi tiết theo từng người dùng | F13-2 |

## 4. User multi roles matrix

| Num | Role | EMP | MGR | DIR | HR | ADM | Note |
|-----|------|-----|-----|-----|----|----|------|
| 1 | EMP | X | | | | | Nhân viên cơ bản |
| 2 | MGR | | x | | | | Trưởng nhóm/phòng/bộ phận |
| 3 | DIR | | | x | | | Giám đốc khối/điều hành |
| 4 | HR | | | | x | | Nhân sự C&B |
| 5 | ADM | | | | | x | Quản trị hệ thống |

**Ghi chú:**
- Một người dùng có thể có nhiều role (ví dụ: Manager có thể kiêm Employee)
- Role cao hơn thường bao gồm quyền của role thấp hơn
- Admin có quyền cao nhất trong việc cấu hình hệ thống
- HR có quyền đặc biệt trong việc quản lý dữ liệu nghỉ phép 