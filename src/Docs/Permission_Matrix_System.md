# 🔐 HỆ THỐNG PHÂN QUYỀN - ỨNG DỤNG QUẢN LÝ NGHỈ PHÉP

## 📊 **BẢNG QUYỀN HỆ THỐNG (SharePoint List: Quyen)**

| **MaQuyen** | **TenQuyen** | **MoTa** | **Giá Trị (Bit)** |
|-------------|--------------|----------|-------------------|
| PERSONAL_LEAVE | Quyền nghỉ phép cá nhân | Tạo, sửa, xóa, xem đơn nghỉ phép của bản thân | 1 (2^0) |
| SPECIAL_LEAVE | Tạo đơn nghỉ phép đặc biệt | Tạo đơn nghỉ phép vượt quy định | 2 (2^1) |
| VIEW_TEAM_LEAVE | Xem đơn nghỉ của team | Quyền xem đơn nghỉ phép của nhân viên dưới quyền | 4 (2^2) |
| VIEW_ALL_LEAVE | Xem tất cả đơn nghỉ | Quyền xem đơn nghỉ phép của tất cả nhân viên | 8 (2^3) |
| APPROVE_LEVEL_1 | Phê duyệt cấp 1 | Quyền phê duyệt đơn nghỉ phép cấp 1 (Manager) | 16 (2^4) |
| APPROVE_LEVEL_2 | Phê duyệt cấp 2 | Quyền phê duyệt đơn nghỉ phép cấp 2 (Director khối) | 32 (2^5) |
| APPROVE_LEVEL_3 | Phê duyệt cấp 3 | Quyền phê duyệt đơn nghỉ phép cấp 3 (Director điều hành) | 64 (2^6) |
| RECORD_LEAVE | Ghi nhận nghỉ phép | Quyền ghi nhận và xác nhận nghỉ phép đã thực hiện | 128 (2^7) |
| VIEW_DASHBOARD | Xem dashboard | Quyền xem dashboard và báo cáo thống kê | 256 (2^8) |
| EXPORT_REPORTS | Xuất báo cáo | Quyền xuất file báo cáo CSV, Excel | 512 (2^9) |
| MANAGE_LEAVE_QUOTA | Quản lý quota ngày phép | Quyền cập nhật số ngày phép hàng năm | 1024 (2^10) |
| MANAGE_HOLIDAYS | Quản lý ngày lễ | Quyền thêm, sửa, xóa ngày nghỉ lễ và cấu hình | 2048 (2^11) |
| MANAGE_USERS | Quản lý người dùng | Quyền thêm, sửa, xóa thông tin người dùng | 4096 (2^12) |
| MANAGE_ROLES | Quản lý vai trò | Quyền gán và chỉnh sửa vai trò người dùng | 8192 (2^13) |
| MANAGE_APPROVAL_PROCESS | Quản lý quy trình phê duyệt | Quyền thiết lập quy trình phê duyệt 3 cấp | 16384 (2^14) |
| SYSTEM_ADMIN | Quản trị hệ thống | Quyền cấu hình hệ thống và xem audit logs | 32768 (2^15) |

---

## 🎯 **MATRIX PHÂN QUYỀN THEO VAI TRÒ**

### **Dựa trên Requirements từ PDF (Trang 2-3):**

| **Chức năng** | **Employee** | **Manager** | **Director** | **HR** | **Admin** |
|---------------|--------------|-------------|--------------|--------|-----------|
| **Quản lý thông tin người dùng** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Quản lý số ngày nghỉ phép** | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Quản lý lịch nghỉ phép** | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Quản lý quy trình phê duyệt** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Quản lý role trong ứng dụng** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Tạo nghỉ phép** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Xem thông tin nghỉ phép** | ✅ (own) | ✅ (team) | ✅ (all) | ✅ (all) | ✅ (all) |
| **Phê duyệt nghỉ phép** | ❌ | ✅ (Level 1) | ✅ (Level 2&3) | ❌ (Ghi nhận) | ✅ (All) |
| **Theo dõi nghỉ phép** | ✅ (own) | ✅ (team) | ✅ (all) | ✅ (all) | ❌ |
| **Xuất file báo cáo** | ❌ | ❌ | ❌ | ❌ | ✅ |

---

## 🔢 **TÍNH TOÁN PERMISSION CHO TỪNG VAI TRÒ**

### **1. EMPLOYEE (Nhân viên)**
**Quyền được cấp:**
- ✅ PERSONAL_LEAVE (1) - Tạo đơn nghỉ phép cá nhân
- ✅ SPECIAL_LEAVE (2) - Tạo đơn nghỉ phép đặc biệt
- ✅ VIEW_DASHBOARD (256) - Xem dashboard cá nhân

**Calculation:**
```
Employee Permission = 1 + 2 + 256 = 259
```

### **2. MANAGER (Trưởng nhóm/Trưởng bộ phận/Trưởng phòng)**
**Quyền được cấp:**
- ✅ PERSONAL_LEAVE (1) - Tạo đơn nghỉ phép cá nhân
- ✅ SPECIAL_LEAVE (2) - Tạo đơn nghỉ phép đặc biệt
- ✅ VIEW_TEAM_LEAVE (4) - Xem đơn nghỉ của team
- ✅ APPROVE_LEVEL_1 (16) - Phê duyệt cấp 1 (≤12 ngày)
- ✅ VIEW_DASHBOARD (256) - Xem dashboard team

**Calculation:**
```
Manager Permission = 1 + 2 + 4 + 16 + 256 = 279
```

### **3. DIRECTOR (Giám đốc khối & Giám đốc điều hành)**
**Quyền được cấp:**
- ✅ PERSONAL_LEAVE (1) - Tạo đơn nghỉ phép cá nhân
- ✅ SPECIAL_LEAVE (2) - Tạo đơn nghỉ phép đặc biệt
- ✅ VIEW_TEAM_LEAVE (4) - Xem đơn nghỉ của team
- ✅ VIEW_ALL_LEAVE (8) - Xem tất cả đơn nghỉ
- ✅ APPROVE_LEVEL_2 (32) - Phê duyệt cấp 2 (Giám đốc khối)
- ✅ APPROVE_LEVEL_3 (64) - Phê duyệt cấp 3 (Giám đốc điều hành)
- ✅ VIEW_DASHBOARD (256) - Xem dashboard toàn bộ
- ✅ EXPORT_REPORTS (512) - Xuất báo cáo

**Calculation:**
```
Director Permission = 1 + 2 + 4 + 8 + 32 + 64 + 256 + 512 = 879
```

### **4. HR (C&B, HR)**
**Quyền được cấp:**
- ✅ PERSONAL_LEAVE (1) - Tạo đơn nghỉ phép cá nhân
- ✅ SPECIAL_LEAVE (2) - Tạo đơn nghỉ phép đặc biệt
- ✅ VIEW_ALL_LEAVE (8) - Xem tất cả đơn nghỉ
- ✅ RECORD_LEAVE (128) - Ghi nhận nghỉ phép (không phê duyệt)
- ✅ VIEW_DASHBOARD (256) - Xem dashboard toàn bộ
- ✅ EXPORT_REPORTS (512) - Xuất báo cáo
- ✅ MANAGE_LEAVE_QUOTA (1024) - Quản lý quota ngày phép
- ✅ MANAGE_HOLIDAYS (2048) - Quản lý ngày lễ

**Calculation:**
```
HR Permission = 1 + 2 + 8 + 128 + 256 + 512 + 1024 + 2048 = 3979
```

### **5. ADMIN (IT)**
**Quyền được cấp:**
- ✅ PERSONAL_LEAVE (1) - Tạo đơn nghỉ phép cá nhân
- ✅ SPECIAL_LEAVE (2) - Tạo đơn nghỉ phép đặc biệt
- ✅ VIEW_TEAM_LEAVE (4) - Xem đơn nghỉ của team
- ✅ VIEW_ALL_LEAVE (8) - Xem tất cả đơn nghỉ
- ✅ APPROVE_LEVEL_1 (16) - Phê duyệt cấp 1
- ✅ APPROVE_LEVEL_2 (32) - Phê duyệt cấp 2
- ✅ APPROVE_LEVEL_3 (64) - Phê duyệt cấp 3
- ✅ RECORD_LEAVE (128) - Ghi nhận nghỉ phép
- ✅ VIEW_DASHBOARD (256) - Xem dashboard
- ✅ EXPORT_REPORTS (512) - Xuất báo cáo
- ✅ MANAGE_LEAVE_QUOTA (1024) - Quản lý quota ngày phép
- ✅ MANAGE_HOLIDAYS (2048) - Quản lý ngày lễ
- ✅ MANAGE_USERS (4096) - Quản lý người dùng
- ✅ MANAGE_ROLES (8192) - Quản lý vai trò
- ✅ MANAGE_APPROVAL_PROCESS (16384) - Quản lý quy trình phê duyệt
- ✅ SYSTEM_ADMIN (32768) - Quản trị hệ thống

**Calculation:**
```
Admin Permission = 2^16 - 1 = 65535 (All permissions)
```

---

## 📋 **BẢNG TỔNG HỢP PERMISSION VALUES**

| **Vai trò** | **Permission Value** | **Binary** | **Quyền chính** |
|-------------|---------------------|------------|-----------------|
| **Employee** | 259 | 100000011 | Personal Leave + Dashboard + SPECIAL LEAVE|
| **Manager** | 279 | 100010111 | + Team View + Approve L1 |
| **Director** | 879 | 1101101111 | + All View + Approve L2&L3 + Export |
| **HR** | 3979 | 111110001011 | + Record + Manage Quota/Holidays |
| **Admin** | 65535 | 1111111111111111 | All Permissions |

---

## 🔍 **PERMISSION CHECK EXAMPLES**

### **Kiểm tra quyền với CheckPermission function:**

```javascript
// Manager có quyền APPROVE_LEVEL_1?
CheckPermission(279, 16) = Mod(Int(279 / 16), 2) = Mod(17, 2) = 1 ✅ TRUE

// Manager có quyền APPROVE_LEVEL_2?
CheckPermission(279, 32) = Mod(Int(279 / 32), 2) = Mod(8, 2) = 0 ❌ FALSE

// Director có quyền APPROVE_LEVEL_2?
CheckPermission(879, 32) = Mod(Int(879 / 32), 2) = Mod(27, 2) = 1 ✅ TRUE

// HR có quyền RECORD_LEAVE?
CheckPermission(3979, 128) = Mod(Int(3979 / 128), 2) = Mod(31, 2) = 1 ✅ TRUE

// HR có quyền APPROVE_LEVEL_1?
CheckPermission(3979, 16) = Mod(Int(3979 / 16), 2) = Mod(248, 2) = 0 ❌ FALSE
```

---

## 🎯 **QUY TRÌNH PHÊ DUYỆT THEO PERMISSION**

### **Approval Workflow Logic:**

```
Đơn nghỉ phép ≤ 12 ngày:
Employee → Manager (APPROVE_LEVEL_1) → HR (RECORD_LEAVE)

Đơn nghỉ phép > 12 ngày:
Employee → Manager (APPROVE_LEVEL_1) → Director (APPROVE_LEVEL_2) → HR (RECORD_LEAVE)

Đơn nghỉ phép > 12 ngày (Director điều hành):
Employee → Manager (APPROVE_LEVEL_1) → Director Khối (APPROVE_LEVEL_2) → Director Điều hành (APPROVE_LEVEL_3) → HR (RECORD_LEAVE)
```

### **Role Mapping cho Approval:**
- **Cấp 1**: Manager (Permission: 279) - APPROVE_LEVEL_1
- **Cấp 2**: Director Khối (Permission: 879) - APPROVE_LEVEL_2  
- **Cấp 3**: Director Điều hành (Permission: 879) - APPROVE_LEVEL_3
- **Ghi nhận**: HR (Permission: 3979) - RECORD_LEAVE

---

## 🔧 **IMPLEMENTATION TRONG APP/FORMULAS**

```javascript
// Updated UserPermissions object
UserPermissions = {
  PERSONAL_LEAVE: 1,
  SPECIAL_LEAVE: 2,
  VIEW_TEAM_LEAVE: 4,
  VIEW_ALL_LEAVE: 8,
  APPROVE_LEVEL_1: 16,
  APPROVE_LEVEL_2: 32,
  APPROVE_LEVEL_3: 64,
  RECORD_LEAVE: 128,
  VIEW_DASHBOARD: 256,
  EXPORT_REPORTS: 512,
  MANAGE_LEAVE_QUOTA: 1024,
  MANAGE_HOLIDAYS: 2048,
  MANAGE_USERS: 4096,
  MANAGE_ROLES: 8192,
  MANAGE_APPROVAL_PROCESS: 16384,
  SYSTEM_ADMIN: 32768
};

// Updated RolePermissionCombinations
RolePermissionCombinations = {
  Employee: 259,    // PERSONAL_LEAVE + SPECIAL_LEAVE + VIEW_DASHBOARD
  Manager: 279,     // Employee + VIEW_TEAM_LEAVE + APPROVE_LEVEL_1
  Director: 879,    // Manager + VIEW_ALL_LEAVE + APPROVE_LEVEL_2 + APPROVE_LEVEL_3 + EXPORT_REPORTS
  HR: 3979,         // Base + VIEW_ALL_LEAVE + RECORD_LEAVE + EXPORT_REPORTS + MANAGE_LEAVE_QUOTA + MANAGE_HOLIDAYS
  Admin: 65535      // All permissions
};
```

---

## 📝 **VALIDATION RULES**

### **Screen Access Rules:**
- **Dashboard**: Requires VIEW_DASHBOARD (256)
- **MyLeave**: Requires PERSONAL_LEAVE (1)
- **Approval**: Requires APPROVE_LEVEL_1 (16) OR APPROVE_LEVEL_2 (32) OR APPROVE_LEVEL_3 (64) OR RECORD_LEAVE (128)
- **Reports**: Requires EXPORT_REPORTS (512)
- **Admin**: Requires SYSTEM_ADMIN (32768)

### **Feature Access Rules:**
- **Create Leave**: PERSONAL_LEAVE (1)
- **View Team Leaves**: VIEW_TEAM_LEAVE (4)
- **View All Leaves**: VIEW_ALL_LEAVE (8)
- **Approve Requests**: APPROVE_LEVEL_1/2/3 (16/32/64)
- **Record Leave**: RECORD_LEAVE (128)
- **Export Reports**: EXPORT_REPORTS (512)
- **Manage Users**: MANAGE_USERS (4096)

**Hệ thống phân quyền này đảm bảo tuân thủ chính xác requirements từ PDF và cung cấp kiểm soát truy cập chi tiết cho từng chức năng.** 