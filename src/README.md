# Ứng dụng Quản lý Nghỉ phép - Power App

Ứng dụng quản lý nghỉ phép được xây dựng trên nền tảng Microsoft Power Apps, hỗ trợ toàn bộ quy trình từ tạo đơn, phê duyệt đến theo dõi và báo cáo.

## 📁 Cấu trúc dự án

```
src/
├── Data/
│   └── DemoData.yaml                    # Dữ liệu demo cho ứng dụng
├── Components/
│   ├── HeaderComponent.yaml             # Component header chung
│   ├── NavigationComponent.yaml         # Component menu điều hướng
│   └── StatsCardComponent.yaml          # Component card thống kê
├── Screens/
│   ├── LoginScreen.yaml                # Màn hình đăng nhập
│   ├── DashboardScreen.yaml            # Màn hình dashboard chính
│   ├── LeaveRequestScreen.yaml         # Màn hình tạo đơn nghỉ phép
│   ├── MyLeavesScreen.yaml             # Màn hình danh sách đơn nghỉ phép
│   ├── CalendarScreen.yaml             # Màn hình lịch nghỉ phép
│   ├── ApprovalScreen.yaml             # Màn hình phê duyệt đơn nghỉ phép
│   ├── ReportsScreen.yaml              # Màn hình báo cáo và thống kê
│   ├── ManagementScreen.yaml           # Màn hình quản lý hệ thống
│   ├── ProfileScreen.yaml              # Màn hình thông tin cá nhân
│   ├── LeaveConfirmationScreen.yaml    # Màn hình ghi nhận kết quả nghỉ phép
│   └── AttachmentScreen.yaml           # Màn hình quản lý file đính kèm
└── README.md                           # File này
```

## 🎯 Tính năng chính

### 👤 Phân quyền người dùng
- **Employee**: Nhân viên thường
- **Manager**: Trưởng nhóm/phòng/bộ phận
- **Director**: Giám đốc khối/điều hành
- **HR**: Nhân sự
- **Admin**: Quản trị viên

### 📊 Dashboard
- Tổng quan số ngày phép (tổng, đã dùng, còn lại)
- Thống kê đơn nghỉ phép (chờ duyệt, đã duyệt, từ chối)
- Danh sách đơn gần đây
- Thao tác nhanh

### 📝 Quản lý đơn nghỉ phép
- Tạo đơn nghỉ phép với đầy đủ thông tin
- Tính toán tự động số ngày nghỉ
- Validation theo quy định công ty
- Bàn giao công việc

### 📋 Danh sách đơn nghỉ phép
- Xem tất cả đơn của bản thân
- Lọc theo trạng thái
- Tìm kiếm theo từ khóa
- Xem chi tiết từng đơn

## 🧩 Components

### HeaderComponent
**File**: `src/Components/HeaderComponent.yaml`

Component header chung cho toàn bộ ứng dụng.

**Custom Properties**:
- `Title` (Text): Tiêu đề trang
- `UserName` (Text): Tên người dùng
- `UserRole` (Text): Vai trò người dùng
- `ShowNotification` (Boolean): Hiển thị thông báo
- `NotificationCount` (Number): Số lượng thông báo

**Tính năng**:
- Logo và tiêu đề ứng dụng
- Thông tin người dùng hiện tại
- Badge thông báo với số lượng

### NavigationComponent
**File**: `src/Components/NavigationComponent.yaml`

Component menu điều hướng bên trái.

**Custom Properties**:
- `UserRole` (Text): Vai trò để hiển thị menu phù hợp
- `ActiveScreen` (Text): Màn hình đang active
- `OnNavigate` (Event): Sự kiện khi điều hướng

**Tính năng**:
- Menu điều hướng theo vai trò
- Highlight màn hình đang active
- Phân quyền hiển thị menu

### StatsCardComponent
**File**: `src/Components/StatsCardComponent.yaml`

Component card hiển thị thống kê.

**Custom Properties**:
- `Title` (Text): Tiêu đề card
- `Value` (Number): Giá trị số
- `Icon` (Text): Tên icon
- `Color` (Color): Màu chủ đạo
- `Subtitle` (Text): Mô tả phụ

**Tính năng**:
- Hiển thị số liệu với icon
- Màu sắc tùy chỉnh
- Layout responsive

## 🖥️ Screens

### LoginScreen
**File**: `src/Screens/LoginScreen.yaml`

Màn hình đăng nhập vào ứng dụng.

**Tính năng**:
- Form đăng nhập với email/password
- Validation đầu vào
- Demo authentication
- UI hiện đại với animation

**Demo Account**:
- Email: `an.nguyen@asiashine.com`
- Password: `123456`

### DashboardScreen
**File**: `src/Screens/DashboardScreen.yaml`

Màn hình dashboard chính sau khi đăng nhập.

**Tính năng**:
- 6 card thống kê chính
- Danh sách đơn nghỉ phép gần đây
- Thao tác nhanh (tạo đơn mới, xem lịch)
- Layout responsive với grid system

**Thống kê hiển thị**:
- Tổng số ngày phép năm
- Số ngày đã sử dụng
- Số ngày còn lại
- Đơn chờ phê duyệt
- Đơn đã phê duyệt
- Đơn bị từ chối

### LeaveRequestScreen
**File**: `src/Screens/LeaveRequestScreen.yaml`

Màn hình tạo đơn xin nghỉ phép.

**Tính năng**:
- Form đầy đủ thông tin nhân viên
- Chọn loại nghỉ phép
- Date picker cho ngày bắt đầu/kết thúc
- Tính toán tự động số ngày nghỉ
- Chọn người bàn giao công việc
- Validation form đầy đủ
- Submit với feedback

**Validation**:
- Ngày kết thúc >= ngày bắt đầu
- Lý do nghỉ phép bắt buộc
- Người bàn giao bắt buộc
- Nội dung bàn giao bắt buộc

### MyLeavesScreen
**File**: `src/Screens/MyLeavesScreen.yaml`

Màn hình xem danh sách đơn nghỉ phép của bản thân.

**Tính năng**:
- Danh sách tất cả đơn nghỉ phép
- Filter theo trạng thái (All, Pending, Approved, Rejected)
- Tìm kiếm theo lý do, loại nghỉ
- Hiển thị đầy đủ thông tin từng đơn
- Button tạo đơn mới
- Button xem chi tiết từng đơn

**Thông tin hiển thị**:
- Mã đơn và ngày tạo
- Loại nghỉ phép
- Thời gian nghỉ (từ ngày - đến ngày)
- Số ngày nghỉ
- Lý do nghỉ phép
- Trạng thái với màu sắc phân biệt

## 📊 Dữ liệu Demo

### Users (Người dùng)
- **EMP001**: Nguyễn Văn An (Employee)
- **EMP002**: Trần Thị Bình (Manager)
- **EMP003**: Lê Văn Cường (Director)
- **EMP004**: Phạm Thị Dung (Director)
- **HR001**: Võ Thị Hoa (HR)

### Leave Balance (Số ngày phép)
Mỗi nhân viên có:
- Tổng số ngày phép năm 2024
- Số ngày đã sử dụng
- Số ngày còn lại
- Số ngày nghỉ không lương

### Leave Requests (Đơn nghỉ phép)
5 đơn nghỉ phép mẫu với các trạng thái khác nhau:
- Đã phê duyệt (Approved)
- Chờ phê duyệt (Pending)
- Bị từ chối (Rejected)

### Holidays (Ngày lễ)
Danh sách các ngày lễ trong năm 2024:
- Tết Dương lịch
- Tết Nguyên đán
- Ngày Giải phóng miền Nam
- Ngày Quốc tế Lao động
- Ngày Quốc khánh

## 🎨 Design System

### Màu sắc chính
- **Primary Blue**: `RGBA(0, 120, 212, 1)` - Màu chủ đạo
- **Success Green**: `RGBA(40, 167, 69, 1)` - Trạng thái thành công
- **Warning Yellow**: `RGBA(255, 193, 7, 1)` - Trạng thái chờ
- **Danger Red**: `RGBA(220, 53, 69, 1)` - Trạng thái lỗi
- **Background**: `RGBA(248, 250, 252, 1)` - Nền ứng dụng
- **White**: `RGBA(255, 255, 255, 1)` - Nền card/container

### Typography
- **Font Family**: Open Sans
- **Sizes**: 10px - 24px
- **Weights**: Normal, Semibold, Bold

### Spacing
- **Padding**: 10px, 15px, 20px, 30px
- **Margins**: 10px, 20px, 30px
- **Border Radius**: 6px, 8px, 12px, 15px

## 🚀 Cách sử dụng

1. **Import Components**: Import các component vào Power Apps
2. **Import Screens**: Import các screen vào ứng dụng
3. **Setup Data**: Kết nối với SharePoint hoặc sử dụng demo data
4. **Configure Navigation**: Thiết lập điều hướng giữa các màn hình
5. **Test**: Test toàn bộ flow từ đăng nhập đến tạo đơn

## 📱 Responsive Design

Tất cả các component và screen đều được thiết kế responsive:
- Sử dụng relative positioning
- Layout linh hoạt với Parent.Width/Height
- Tối ưu cho cả desktop và tablet

## 🔧 Customization

### Thêm màn hình mới
1. Tạo file YAML mới trong `src/Screens/`
2. Sử dụng HeaderComponent và NavigationComponent
3. Thêm vào menu trong NavigationComponent

### Thêm component mới
1. Tạo file YAML trong `src/Components/`
2. Định nghĩa CustomProperties
3. Sử dụng trong các screen

### Tùy chỉnh dữ liệu
1. Chỉnh sửa `src/Data/DemoData.yaml`
2. Hoặc kết nối với data source thực tế
3. Update các biến trong OnVisible của screens

### CalendarScreen
**File**: `src/Screens/CalendarScreen.yaml`

Màn hình lịch nghỉ phép và ngày lễ.

**Tính năng**:
- Calendar view theo tháng/năm
- Chế độ xem cá nhân hoặc toàn công ty
- Hiển thị đơn nghỉ phép với màu sắc phân biệt
- Filter theo tháng/năm
- Legend chú thích trạng thái

### ApprovalScreen
**File**: `src/Screens/ApprovalScreen.yaml`

Màn hình phê duyệt đơn nghỉ phép (dành cho Manager/Director).

**Tính năng**:
- Danh sách đơn chờ phê duyệt theo cấp
- Chi tiết đơn nghỉ phép đầy đủ
- Form phê duyệt với ý kiến
- Workflow phê duyệt đa cấp
- Thống kê đơn cần xử lý

### ReportsScreen
**File**: `src/Screens/ReportsScreen.yaml`

Màn hình báo cáo và thống kê (dành cho HR/Director).

**Tính năng**:
- Dashboard thống kê tổng quan
- Biểu đồ cột theo tháng
- Biểu đồ tròn theo phòng ban
- Bảng chi tiết theo phòng ban và nhân viên
- Xuất báo cáo CSV/Excel

### ManagementScreen
**File**: `src/Screens/ManagementScreen.yaml`

Màn hình quản lý hệ thống (dành cho Admin/HR).

**Tính năng**:
- **Tab Người dùng**: Quản lý nhân viên, role, trạng thái
- **Tab Số ngày phép**: Quản lý quota, import Excel
- **Tab Ngày lễ**: Quản lý lịch nghỉ chung
- **Tab Quy trình**: Thiết lập workflow phê duyệt

### ProfileScreen
**File**: `src/Screens/ProfileScreen.yaml`

Màn hình thông tin cá nhân và số ngày phép.

**Tính năng**:
- Thông tin nhân viên với khả năng chỉnh sửa
- Avatar và thông tin cơ bản
- Thống kê số ngày phép chi tiết
- Lịch sử đơn nghỉ phép cá nhân
- Progress bar tỷ lệ sử dụng

### LeaveConfirmationScreen
**File**: `src/Screens/LeaveConfirmationScreen.yaml`

Màn hình ghi nhận kết quả nghỉ phép (dành cho HR).

**Tính năng**:
- Danh sách đơn nghỉ phép đã được phê duyệt
- Filter theo trạng thái ghi nhận
- Form xác nhận kết quả nghỉ phép
- Thống kê đơn chờ ghi nhận/đã ghi nhận
- Ghi chú xác nhận cho từng đơn

### AttachmentScreen
**File**: `src/Screens/AttachmentScreen.yaml`

Màn hình quản lý file đính kèm đơn nghỉ phép (dành cho HR/Admin).

**Tính năng**:
- Upload file đính kèm cho đơn nghỉ phép
- Danh sách tất cả file đính kèm
- Xem, tải xuống, xóa file
- Hỗ trợ PDF, Word, Excel, Image
- Giới hạn kích thước file 10MB

## 📋 Tài liệu bổ sung

- **[FEATURES_SUMMARY.md](FEATURES_SUMMARY.md)**: Tổng kết đầy đủ các tính năng đã triển khai
- **[REQUIREMENTS_COMPLIANCE.md](REQUIREMENTS_COMPLIANCE.md)**: So sánh chi tiết với yêu cầu gốc

## 📋 TODO

- [ ] Push notification
- [ ] Email integration
- [ ] Mobile optimization
- [ ] Offline support
- [ ] Advanced reporting
- [ ] Integration with HR systems

## 🤝 Đóng góp

1. Fork dự án
2. Tạo feature branch
3. Commit changes
4. Push to branch
5. Tạo Pull Request

## 📄 License

MIT License - xem file LICENSE để biết thêm chi tiết. 