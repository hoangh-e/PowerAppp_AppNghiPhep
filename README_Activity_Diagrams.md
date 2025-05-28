# Activity Diagrams - Ứng dụng Quản lý Nghỉ Phép AsiaShine

## Tổng quan

Tài liệu này chứa các Activity Diagram được tạo bằng PlantUML cho tất cả chức năng của ứng dụng quản lý nghỉ phép AsiaShine. Các diagram được thiết kế dựa trên đặc tả yêu cầu từ file URD và Excel specifications.

## Cấu trúc File

### 📁 Files chính
- `activity_diagrams.puml` - Chứa tất cả Activity diagrams bằng PlantUML
- `function_ui_comparison.md` - So sánh chức năng vs UI hiện có
- `README_Activity_Diagrams.md` - Tài liệu này

### 📁 Source data (thư mục output/)
- `excel_sheet_Đặc_tả_chức_năng.txt` - Đặc tả chi tiết các chức năng
- `excel_sheet_Các_chức_năng.txt` - Ma trận chức năng theo role
- `excel_sheet_Chức_năng_và_giao_diện.txt` - Mapping chức năng và UI
- `pdf_content.txt` - Nội dung URD document

## Danh sách Activity Diagrams

### 🔐 Authentication & Navigation
1. **F01_Navigation** - Điều hướng đến các chức năng chính
2. **F02_Authentication** - Xác thực người dùng

### 👤 User Management  
3. **F03_Personal_Info** - Xem thông tin cá nhân và ngày nghỉ còn lại
4. **F08_User_Management** - Quản lý người dùng (Admin)

### 📝 Leave Request Management
5. **F04_Create_Leave_Request** - Tạo đơn nghỉ phép
6. **F07_Approval_Process** - Phê duyệt đơn nghỉ phép (3 cấp)

### 📅 Calendar Views
7. **F05_Personal_Calendar** - Xem lịch nghỉ cá nhân  
8. **F06_Company_Calendar** - Xem lịch nghỉ toàn công ty

### ⚙️ System Configuration
9. **F09_Import_Leave_Days** - Nhập số ngày phép từ Excel
10. **F10_Holiday_Management** - Quản lý lịch nghỉ & ngày lễ
11. **F11_Workflow_Role_Setup** - Thiết lập quy trình & role

### 📊 Reporting & Analytics
12. **F12_Dashboard_Reports** - Dashboard báo cáo
13. **F13_Export_Reports** - Xuất báo cáo

## Chi tiết từng Activity Diagram

### F01_Navigation - Điều hướng chức năng
**Actor**: All Users  
**Mô tả**: Cho phép người dùng điều hướng đến các chức năng chính thông qua menu
**Flow**:
1. User truy cập ứng dụng
2. System hiển thị trang chủ với menu chính  
3. User chọn chức năng
4. System chuyển đến giao diện tương ứng

### F02_Authentication - Xác thực người dùng
**Actor**: All Users  
**Mô tả**: Xác thực danh tính người dùng trước khi truy cập hệ thống
**Flow**:
1. User nhập username/password
2. User nhấn đăng nhập
3. System kiểm tra thông tin
4. Nếu hợp lệ: tạo session và chuyển trang chủ
5. Nếu không hợp lệ: hiển thị lỗi

### F03_Personal_Info - Thông tin cá nhân
**Actor**: All Users  
**Mô tả**: Hiển thị thông tin cá nhân và số ngày nghỉ phép còn lại
**Flow**:
1. User truy cập trang thông tin cá nhân
2. System lấy dữ liệu từ SharePoint
3. System hiển thị thông tin (tên, chức vụ, phòng ban)
4. System tính toán và hiển thị số ngày nghỉ còn lại

### F04_Create_Leave_Request - Tạo đơn nghỉ phép  
**Actor**: Employee, Manager, Director, HR  
**Mô tả**: Cho phép tạo đơn xin nghỉ phép mới với validation
**Flow**:
1. User truy cập form tạo đơn
2. User nhập thông tin đơn nghỉ phép
3. System kiểm tra điều kiện thời gian tạo đơn
4. System kiểm tra số ngày nghỉ phép còn lại
5. Nếu hợp lệ: tạo đơn và gửi thông báo phê duyệt
6. Nếu vượt quá: cho phép tạo đơn nghỉ không lương

### F05_Personal_Calendar - Lịch nghỉ cá nhân
**Actor**: All Users  
**Mô tả**: Hiển thị lịch nghỉ phép cá nhân dạng calendar
**Flow**:
1. User truy cập calendar view cá nhân
2. System lấy dữ liệu nghỉ phép cá nhân
3. System hiển thị lịch nghỉ phép dạng calendar
4. Cho phép xem chi tiết từng ngày

### F06_Company_Calendar - Lịch nghỉ toàn công ty
**Actor**: Manager, Director, HR  
**Mô tả**: Xem lịch nghỉ của toàn bộ nhân viên theo phân quyền
**Flow**:
1. User truy cập calendar view toàn công ty
2. System kiểm tra quyền truy cập
3. System lấy dữ liệu theo phân quyền
4. System hiển thị lịch nghỉ phép tổng hợp
5. Cho phép lọc theo phòng ban/nhân viên

### F07_Approval_Process - Phê duyệt đơn nghỉ phép
**Actor**: Manager, Director  
**Mô tả**: Phê duyệt hoặc từ chối đơn nghỉ phép theo quy trình 3 cấp
**Flow**:
1. User nhận thông báo đơn chờ phê duyệt
2. User xem danh sách đơn chờ duyệt
3. User chọn và xem chi tiết đơn
4. User quyết định phê duyệt hoặc từ chối
5. Nếu phê duyệt: chuyển cấp tiếp theo hoặc hoàn thành
6. Nếu từ chối: gửi thông báo từ chối

### F08_User_Management - Quản lý người dùng
**Actor**: Admin  
**Mô tả**: Thêm, sửa, xóa thông tin người dùng trong hệ thống
**Flow**:
1. Admin truy cập giao diện quản lý người dùng
2. Admin chọn hành động (thêm/sửa/xóa)
3. System thực hiện thao tác tương ứng
4. System gửi thông báo đến người dùng liên quan

### F09_Import_Leave_Days - Nhập số ngày phép
**Actor**: HR  
**Mô tả**: Import dữ liệu số ngày phép từ file Excel
**Flow**:
1. HR truy cập form upload Excel
2. HR chọn và upload file Excel
3. System kiểm tra định dạng file
4. System đọc và kiểm tra dữ liệu
5. System cập nhật số ngày phép vào SharePoint
6. System gửi mail thông báo đến tất cả nhân viên

### F10_Holiday_Management - Quản lý lịch nghỉ & ngày lễ
**Actor**: HR, Admin  
**Mô tả**: Quản lý danh sách ngày nghỉ lễ và thiết lập lịch làm việc
**Flow**:
1. User truy cập giao diện quản lý lịch nghỉ
2. User chọn chức năng (quản lý ngày lễ hoặc lịch làm việc)
3. User thực hiện thao tác (thêm/sửa/xóa)
4. System cập nhật lịch nghỉ toàn hệ thống

### F11_Workflow_Role_Setup - Thiết lập quy trình & role
**Actor**: Admin  
**Mô tả**: Cấu hình quy trình phê duyệt và phân quyền người dùng
**Flow**:
1. Admin truy cập form cấu hình
2. Admin chọn chức năng (quy trình hoặc role)
3. Nếu thiết lập quy trình: kiểm tra không có đơn chờ duyệt
4. Admin thực hiện cấu hình
5. System lưu cấu hình và gửi thông báo

### F12_Dashboard_Reports - Dashboard báo cáo
**Actor**: Manager, Director, HR  
**Mô tả**: Hiển thị dashboard với biểu đồ báo cáo tình hình nghỉ phép
**Flow**:
1. User truy cập dashboard báo cáo
2. System kiểm tra quyền và lấy dữ liệu theo phân quyền
3. System hiển thị biểu đồ tổng quan
4. User sử dụng bộ lọc
5. System cập nhật biểu đồ theo bộ lọc

### F13_Export_Reports - Xuất báo cáo
**Actor**: HR, Director  
**Mô tả**: Xuất dữ liệu nghỉ phép theo định dạng CSV
**Flow**:
1. User truy cập chức năng xuất báo cáo
2. User chọn tiêu chí xuất báo cáo
3. User chọn định dạng xuất
4. System tạo báo cáo theo yêu cầu
5. System xuất file CSV
6. User tải file về máy

## Quy ước trong Diagrams

### Actors (Người thực hiện)
- **All Users**: Tất cả người dùng đã đăng nhập
- **Employee**: Nhân viên
- **Manager**: Trưởng nhóm/phòng/bộ phận  
- **Director**: Giám đốc khối/điều hành
- **HR**: Nhân sự
- **Admin**: Quản trị viên

### Swimlanes
- **|User|**: Hành động của người dùng
- **|System|**: Xử lý của hệ thống
- **|Manager/Director/HR|**: Hành động của role cụ thể

### Decision Points
- **if-then-else**: Điều kiện phân nhánh
- **yes/no**: Kết quả điều kiện

### Notes
- **note right**: Ghi chú bổ sung thông tin
- **end note**: Kết thúc ghi chú nhiều dòng

## Cách sử dụng

### Xem diagrams
1. Mở file `activity_diagrams.puml` bằng PlantUML viewer
2. Hoặc sử dụng online tool: http://www.plantuml.com/plantuml/
3. Copy nội dung từng diagram để xem riêng lẻ

### Chỉnh sửa diagrams
1. Sử dụng PlantUML syntax
2. Tuân thủ quy ước đặt tên: `@startuml F##_FunctionName`
3. Thêm title mô tả chức năng
4. Sử dụng swimlanes để phân chia trách nhiệm

## Liên kết với UI Implementation

Xem file `function_ui_comparison.md` để biết:
- Chức năng nào đã có UI
- Chức năng nào cần triển khai
- Ưu tiên phát triển
- Components có thể tái sử dụng

## Tài liệu tham khảo

- **URD Document**: `Docs/AppNghiPhep/URD_App_nghi_phep_AsiaShine - 11.10.2023.pdf`
- **Excel Specifications**: `Docs/AppNghiPhep/Book1.xlsx`
- **PlantUML Documentation**: https://plantuml.com/activity-diagram-beta
- **Power Apps Documentation**: https://docs.microsoft.com/en-us/powerapps/

---

*Tài liệu được tạo tự động từ đặc tả yêu cầu và phân tích UI hiện có.* 