# 🔐 POWERFX - VÍ DỤ SỬ DỤNG HỆ THỐNG QUYỀN MỚI

**Ngày tạo:** $(Get-Date)  
**Mục đích:** Cung cấp ví dụ PowerFx để implement hệ thống quyền 20-bit mới trong Power Apps

---

## 🎯 CẤU TRÚC HỆ THỐNG QUYỀN

### **Danh sách 20 quyền với giá trị bit:**
```powerfx
// Constant values for permissions
Set(gblPermissions, {
    VIEW_OWN_LEAVE: 1,
    CREATE_LEAVE: 2,
    EDIT_OWN_LEAVE: 4,
    DELETE_OWN_LEAVE: 8,
    VIEW_TEAM_LEAVE: 16,
    VIEW_ALL_LEAVE: 32,
    APPROVE_LEVEL_1: 64,
    APPROVE_LEVEL_2: 128,
    APPROVE_LEVEL_3: 256,
    RECORD_LEAVE: 512,
    VIEW_REPORTS: 1024,
    EXPORT_REPORTS: 2048,
    MANAGE_LEAVE_QUOTA: 4096,
    MANAGE_HOLIDAYS: 8192,
    MANAGE_USERS: 16384,
    MANAGE_ROLES: 32768,
    MANAGE_APPROVAL_PROCESS: 65536,
    MANAGE_SYSTEM_CONFIG: 131072,
    AUDIT_LOGS: 262144,
    VIEW_PERSONAL_INFO: 524288
});
```

### **Tổng quyền theo vai trò:**
```powerfx
Set(gblRolePermissions, {
    EMPLOYEE: 524303,    // VIEW_OWN_LEAVE + CREATE_LEAVE + EDIT_OWN_LEAVE + DELETE_OWN_LEAVE + VIEW_PERSONAL_INFO
    MANAGER: 525407,     // EMPLOYEE + VIEW_TEAM_LEAVE + APPROVE_LEVEL_1 + VIEW_REPORTS  
    DIRECTOR: 533983,    // MANAGER + APPROVE_LEVEL_2 + APPROVE_LEVEL_3 + MANAGE_HOLIDAYS
    HR: 540207,          // EMPLOYEE + VIEW_ALL_LEAVE + RECORD_LEAVE + VIEW_REPORTS + EXPORT_REPORTS + MANAGE_LEAVE_QUOTA + MANAGE_HOLIDAYS
    ADMIN: 517152        // VIEW_ALL_LEAVE + VIEW_REPORTS + MANAGE_HOLIDAYS + MANAGE_USERS + MANAGE_ROLES + MANAGE_APPROVAL_PROCESS + MANAGE_SYSTEM_CONFIG + AUDIT_LOGS
});
```

---

## 🔧 HÀM KIỂM TRA QUYỀN

### **1. Hàm kiểm tra quyền cơ bản:**
```powerfx
// Function: HasPermission(userRole, requiredPermission)
// Kiểm tra xem user có quyền cụ thể hay không
HasPermission(userRole, permissionValue) = 
    Mod(
        LookUp(gblRolePermissions, Value = userRole).Value,
        permissionValue * 2
    ) >= permissionValue
```

### **2. Hàm kiểm tra nhiều quyền:**
```powerfx
// Function: HasAnyPermission(userRole, permissionList)
// Kiểm tra user có ít nhất 1 trong các quyền được yêu cầu
HasAnyPermission(userRole, permissionArray) = 
    CountRows(
        Filter(permissionArray, 
            HasPermission(userRole, Value)
        )
    ) > 0
```

### **3. Hàm kiểm tra tất cả quyền:**
```powerfx
// Function: HasAllPermissions(userRole, permissionList)  
// Kiểm tra user có đủ tất cả quyền được yêu cầu
HasAllPermissions(userRole, permissionArray) = 
    CountRows(permissionArray) = CountRows(
        Filter(permissionArray, 
            HasPermission(userRole, Value)
        )
    )
```

---

## 🎮 VÍ DỤ SỬ DỤNG TRONG POWER APPS

### **1. Khởi tạo thông tin user (OnStart App):**
```powerfx
// OnStart của App - Lấy thông tin user từ SharePoint
Set(varCurrentUser, 
    LookUp(NguoiDung, Email = User().Email)
);

// Lấy tổng quyền của user
Set(varUserPermissions, 
    LookUp(gblRolePermissions, Value = varCurrentUser.MaVaiTro).Value
);

// Set biến kiểm tra quyền nhanh
Set(varCanCreateLeave, HasPermission(varCurrentUser.MaVaiTro, gblPermissions.CREATE_LEAVE));
Set(varCanViewTeam, HasPermission(varCurrentUser.MaVaiTro, gblPermissions.VIEW_TEAM_LEAVE));
Set(varCanApproveLevel1, HasPermission(varCurrentUser.MaVaiTro, gblPermissions.APPROVE_LEVEL_1));
```

### **2. Hiển thị/ẩn controls theo quyền:**
```powerfx
// Button "Tạo đơn nghỉ phép" - Visible property
Visible: HasPermission(varCurrentUser.MaVaiTro, gblPermissions.CREATE_LEAVE)

// Button "Phê duyệt" - Visible property  
Visible: HasAnyPermission(varCurrentUser.MaVaiTro, 
    [gblPermissions.APPROVE_LEVEL_1, gblPermissions.APPROVE_LEVEL_2, gblPermissions.APPROVE_LEVEL_3]
)

// Gallery "Đơn nghỉ của team" - Visible property
Visible: HasPermission(varCurrentUser.MaVaiTro, gblPermissions.VIEW_TEAM_LEAVE)

// Button "Xuất báo cáo" - Visible property
Visible: HasPermission(varCurrentUser.MaVaiTro, gblPermissions.EXPORT_REPORTS)
```

### **3. Lọc dữ liệu theo quyền:**
```powerfx
// Gallery hiển thị đơn nghỉ phép - Items property
Items: Switch(
    true,
    // Nếu có quyền xem tất cả đơn
    HasPermission(varCurrentUser.MaVaiTro, gblPermissions.VIEW_ALL_LEAVE),
    DonNghiPhep,
    
    // Nếu có quyền xem đơn của team
    HasPermission(varCurrentUser.MaVaiTro, gblPermissions.VIEW_TEAM_LEAVE),
    Filter(DonNghiPhep, 
        LookUp(NguoiDung, MaNhanVien = MaNhanVien).MaQuanLy = varCurrentUser.MaNhanVien
    ),
    
    // Mặc định: chỉ xem đơn của mình
    Filter(DonNghiPhep, MaNhanVien = varCurrentUser.MaNhanVien)
)
```

### **4. Kiểm tra quyền phê duyệt theo cấp:**
```powerfx
// Button "Phê duyệt cấp 1" - OnSelect
OnSelect: If(
    HasPermission(varCurrentUser.MaVaiTro, gblPermissions.APPROVE_LEVEL_1),
    // Logic phê duyệt cấp 1
    Patch(PheDuyetDon, Defaults(PheDuyetDon), {
        MaDon: ThisItem.MaDon,
        Cap: 1,
        MaNguoiDuyet: varCurrentUser.MaNhanVien,
        QuyetDinh: "DaDuyet",
        NgayDuyet: Now(),
        GhiChu: txtGhiChu.Text
    }),
    // Không có quyền
    Notify("Bạn không có quyền phê duyệt cấp 1", NotificationType.Error)
)

// Button "Phê duyệt cấp 2" - OnSelect  
OnSelect: If(
    HasPermission(varCurrentUser.MaVaiTro, gblPermissions.APPROVE_LEVEL_2),
    // Logic phê duyệt cấp 2
    Patch(PheDuyetDon, Defaults(PheDuyetDon), {
        MaDon: ThisItem.MaDon,
        Cap: 2,
        MaNguoiDuyet: varCurrentUser.MaNhanVien,
        QuyetDinh: "DaDuyet",
        NgayDuyet: Now(),
        GhiChu: txtGhiChu.Text
    }),
    // Không có quyền
    Notify("Bạn không có quyền phê duyệt cấp 2", NotificationType.Error)
)
```

### **5. Navigation menu theo quyền:**
```powerfx
// Gallery menu - Items property
Items: Filter([
    {Title: "Trang chủ", Screen: "HomeScreen", Icon: "Home", Permission: 0},
    {Title: "Đơn của tôi", Screen: "MyLeaveScreen", Icon: "DocumentSearch", Permission: gblPermissions.VIEW_OWN_LEAVE},
    {Title: "Tạo đơn mới", Screen: "CreateLeaveScreen", Icon: "Add", Permission: gblPermissions.CREATE_LEAVE},
    {Title: "Đơn cần duyệt", Screen: "ApprovalScreen", Icon: "CheckMark", Permission: gblPermissions.APPROVE_LEVEL_1},
    {Title: "Quản lý team", Screen: "TeamManageScreen", Icon: "People", Permission: gblPermissions.VIEW_TEAM_LEAVE},
    {Title: "Báo cáo", Screen: "ReportsScreen", Icon: "BarChart4", Permission: gblPermissions.VIEW_REPORTS},
    {Title: "Quản lý người dùng", Screen: "UserManageScreen", Icon: "Contact", Permission: gblPermissions.MANAGE_USERS},
    {Title: "Cấu hình", Screen: "SettingsScreen", Icon: "Settings", Permission: gblPermissions.MANAGE_SYSTEM_CONFIG}
], 
Permission = 0 Or HasPermission(varCurrentUser.MaVaiTro, Permission)
)
```

### **6. Validate quyền khi submit form:**
```powerfx
// Button "Lưu đơn nghỉ phép" - OnSelect
OnSelect: Switch(
    true,
    // Kiểm tra quyền tạo đơn
    Not(HasPermission(varCurrentUser.MaVaiTro, gblPermissions.CREATE_LEAVE)),
    Notify("Bạn không có quyền tạo đơn nghỉ phép", NotificationType.Error),
    
    // Kiểm tra quyền sửa đơn (nếu đang edit)
    varEditMode And Not(HasPermission(varCurrentUser.MaVaiTro, gblPermissions.EDIT_OWN_LEAVE)),
    Notify("Bạn không có quyền sửa đơn nghỉ phép", NotificationType.Error),
    
    // Validate dữ liệu
    IsBlank(dpNgayBatDau.SelectedDate) Or IsBlank(dpNgayKetThuc.SelectedDate),
    Notify("Vui lòng chọn ngày bắt đầu và kết thúc", NotificationType.Error),
    
    // Submit đơn
    Patch(DonNghiPhep, 
        If(varEditMode, LookUp(DonNghiPhep, MaDon = varCurrentDon.MaDon), Defaults(DonNghiPhep)),
        {
            MaNhanVien: varCurrentUser.MaNhanVien,
            NgayBatDau: dpNgayBatDau.SelectedDate,
            NgayKetThuc: dpNgayKetThuc.SelectedDate,
            MaLoai: cmbLoaiNghi.Selected.MaLoai,
            LyDo: txtLyDo.Text,
            TrangThai: "ChoDuyet"
        }
    );
    Notify("Đã lưu đơn nghỉ phép thành công", NotificationType.Success);
    Navigate(MyLeaveScreen)
)
```

---

## 🔍 LOGGING VÀ AUDIT

### **7. Ghi log hành động của user:**
```powerfx
// Function: LogUserAction(action, details)
LogUserAction(actionType, actionDetails) = 
    Patch(AuditLogs, Defaults(AuditLogs), {
        MaNhanVien: varCurrentUser.MaNhanVien,
        HanhDong: actionType,
        ChiTiet: actionDetails,
        ThoiGian: Now(),
        DiaChi_IP: "System",
        TrangThai: "ThanhCong"
    })

// Ví dụ sử dụng trong OnSelect của button
OnSelect: 
    LogUserAction("CREATE_LEAVE", "Tạo đơn nghỉ phép từ " & Text(dpNgayBatDau.SelectedDate) & " đến " & Text(dpNgayKetThuc.SelectedDate));
    // ... logic tạo đơn
```

### **8. Kiểm tra và hiển thị audit logs (chỉ Admin):**
```powerfx
// Gallery audit logs - Visible property
Visible: HasPermission(varCurrentUser.MaVaiTro, gblPermissions.AUDIT_LOGS)

// Gallery audit logs - Items property  
Items: If(
    HasPermission(varCurrentUser.MaVaiTro, gblPermissions.AUDIT_LOGS),
    SortByColumns(AuditLogs, "ThoiGian", Descending),
    Blank()
)
```

---

## 🎭 COMPLEX SCENARIOS

### **9. Phê duyệt đa cấp với kiểm tra quyền:**
```powerfx
// Function: GetNextApprovalLevel(currentLevel, userRole)
GetNextApprovalLevel(currentLevel, userRole) = Switch(
    currentLevel,
    0, If(HasPermission(userRole, gblPermissions.APPROVE_LEVEL_1), 1, -1),
    1, If(HasPermission(userRole, gblPermissions.APPROVE_LEVEL_2), 2, -1),  
    2, If(HasPermission(userRole, gblPermissions.APPROVE_LEVEL_3), 3, -1),
    -1
)

// Button "Phê duyệt" - OnSelect với logic phức tạp
OnSelect: 
    Set(varCurrentLevel, LookUp(PheDuyetDon, MaDon = ThisItem.MaDon And QuyetDinh = "DaDuyet").Cap);
    Set(varNextLevel, GetNextApprovalLevel(varCurrentLevel, varCurrentUser.MaVaiTro));
    
    If(varNextLevel > 0,
        // Có quyền phê duyệt
        Patch(PheDuyetDon, Defaults(PheDuyetDon), {
            MaDon: ThisItem.MaDon,
            Cap: varNextLevel,
            MaNguoiDuyet: varCurrentUser.MaNhanVien,
            QuyetDinh: "DaDuyet",
            NgayDuyet: Now(),
            GhiChu: txtGhiChu.Text
        });
        LogUserAction("APPROVE_LEAVE_LEVEL_" & varNextLevel, "Phê duyệt đơn " & ThisItem.MaDon),
        
        // Không có quyền
        Notify("Bạn không có quyền phê duyệt cấp này", NotificationType.Error)
    )
```

### **10. Dynamic role-based dashboard:**
```powerfx
// Container dashboard - Visible và Items theo vai trò
// Employee Dashboard
Container_Employee.Visible: varCurrentUser.MaVaiTro = "EMPLOYEE"

// Manager Dashboard  
Container_Manager.Visible: HasAnyPermission(varCurrentUser.MaVaiTro, 
    [gblPermissions.VIEW_TEAM_LEAVE, gblPermissions.APPROVE_LEVEL_1]
)

// HR Dashboard
Container_HR.Visible: HasAnyPermission(varCurrentUser.MaVaiTro,
    [gblPermissions.RECORD_LEAVE, gblPermissions.EXPORT_REPORTS, gblPermissions.MANAGE_LEAVE_QUOTA]
)

// Admin Dashboard
Container_Admin.Visible: HasAnyPermission(varCurrentUser.MaVaiTro,
    [gblPermissions.MANAGE_USERS, gblPermissions.MANAGE_ROLES, gblPermissions.AUDIT_LOGS]
)
```

---

## ✅ BEST PRACTICES

### **1. Performance Optimization:**
- Cache permissions trong variables: `Set(varUserPermissions, ...)`
- Sử dụng lookup tables thay vì tính toán lặp lại
- Minimize SharePoint calls bằng cách cache user info

### **2. Security Best Practices:**
- Luôn validate permissions ở cả client và server side
- Log tất cả hành động quan trọng
- Sử dụng consistent permission checking functions

### **3. Maintainability:**
- Centralize permission constants trong global variables
- Use descriptive function names: `HasPermission()`, `CanApprove()`
- Document complex permission logic

### **4. Error Handling:**
- Graceful fallback khi không có quyền
- Clear error messages cho users
- Proper logging cho debugging

**🎉 Hệ thống quyền mới đã ready để implement trong Power Apps!** 