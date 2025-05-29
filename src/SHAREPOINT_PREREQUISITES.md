# 📋 ĐIỀU KIỆN TIÊN QUYẾT - TÍCH HỢP SHAREPOINT

## 🎯 TỔNG QUAN
Trước khi triển khai Power App với cơ sở dữ liệu SharePoint đã tối ưu hóa, cần hoàn thành các bước chuẩn bị sau:

---

## 1. 🏗️ **CẤU HÌNH SHAREPOINT SITE**

### **Bước 1.1: Tạo SharePoint Site**
```powershell
# Tạo SharePoint Team Site
New-PnPSite -Type TeamSite -Title "Leave Management System" -Alias "leave-mgmt-asiashine"

# Hoặc sử dụng SharePoint Admin Center
# https://admin.microsoft.com/sharepoint
```

### **Bước 1.2: Thiết lập Permissions**
- **Site Owner**: IT Admin, HR Manager
- **Site Member**: All employees cần access
- **Site Visitor**: External auditors (nếu cần)

---

## 2. 📊 **TẠO 11 SHAREPOINT LISTS**

### **Thứ tự tạo bắt buộc** (tránh lỗi lookup):

#### **2.1 Nhóm 1: Master Data (không phụ thuộc)**
1. **Quyen** - Hệ thống quyền
2. **LoaiNghi** - Danh mục loại nghỉ phép  
3. **NgayLe** - Lịch nghỉ lễ
4. **CauHinhHeThong** - Cấu hình hệ thống
5. **MauEmail** - Template email

#### **2.2 Nhóm 2: Reference Data (phụ thuộc nhóm 1)**
6. **DonVi** - Cấu trúc tổ chức
7. **VaiTro** - Vai trò (lookup Quyen)

#### **2.3 Nhóm 3: User Data (phụ thuộc nhóm 2)**
8. **NguoiDung** - Thông tin nhân viên (lookup DonVi, VaiTro)
9. **QuyTrinhDuyet** - Workflow (lookup DonVi, VaiTro, NguoiDung)

#### **2.4 Nhóm 4: Transaction Data (phụ thuộc tất cả)**
10. **SoNgayPhep** - Quota (lookup NguoiDung)
11. **DonNghiPhep** - Đơn nghỉ phép (lookup NguoiDung, LoaiNghi)

### **Script tạo Lists tự động:**
```powershell
# File: scripts/Create-SharePointLists.ps1
# Sẽ tạo chi tiết trong phần tiếp theo
```

---

## 3. 📋 **CẤU HÌNH COLUMNS CHO TỪNG LIST**

### **Tham khảo chi tiết:**
- **Schema**: `output/excel_sheet_Cơ_sở_dữ_liệu.txt`
- **Sample Data**: `sharepoint_sample_data.md`

### **Lưu ý quan trọng:**
- ✅ **Kiểu dữ liệu**: Text, Number, Date, DateTime, Choice, Boolean, Lookup
- ✅ **Required fields**: Theo đúng schema
- ✅ **Lookup relationships**: Thiết lập đúng foreign keys
- ✅ **Choice values**: Đúng format và options
- ✅ **Calculated fields**: Formula tính toán tự động

---

## 4. 📥 **IMPORT DỮ LIỆU MẪU**

### **Thứ tự import bắt buộc:**
```
1. Quyen → VaiTro → LoaiNghi → NgayLe → CauHinhHeThong → MauEmail
2. DonVi 
3. NguoiDung
4. QuyTrinhDuyet → SoNgayPhep
5. DonNghiPhep
```

### **Tools import:**
- **Excel**: Copy-paste từ `sharepoint_sample_data.md`
- **PowerShell**: Bulk import scripts
- **Power Automate**: Automated import flows

---

## 5. 🔐 **THIẾT LẬP PERMISSIONS**

### **5.1 SharePoint List Permissions:**
```
Employee:    Read/Write own records only
Manager:     Read team records, Write approvals  
Director:    Read department records, Write approvals
HR:          Read all, Write all (except system config)
Admin:       Full control
```

### **5.2 Item-level Security:**
- **DonNghiPhep**: Users chỉ xem/sửa đơn của mình
- **SoNgayPhep**: Users chỉ xem quota của mình
- **NguoiDung**: Users chỉ sửa thông tin cá nhân

---

## 6. 🔗 **POWER PLATFORM CONNECTIONS**

### **6.1 Connections cần tạo:**
1. **SharePoint**: Connection đến site
2. **Office 365 Users**: User profile data
3. **Office 365 Outlook**: Email notifications
4. **Dataverse** (nếu cần advanced features)

### **6.2 Connection Settings:**
```json
{
  "SharePoint": {
    "SiteUrl": "https://yourtenant.sharepoint.com/sites/leave-mgmt-asiashine",
    "Authentication": "Windows"
  },
  "Office365Users": {
    "Authentication": "OAuth2"
  }
}
```

---

## 7. 🚀 **POWER AUTOMATE FLOWS**

### **7.1 Required Flows:**
1. **Email Notification Flow**: Gửi email khi có đơn mới/phê duyệt
2. **Approval Reminder Flow**: Nhắc nhở deadline
3. **Data Validation Flow**: Kiểm tra dữ liệu
4. **Backup Flow**: Tự động backup weekly

### **7.2 Flow Triggers:**
- **When an item is created**: DonNghiPhep
- **When an item is modified**: DonNghiPhep (status change)
- **Scheduled**: Reminder và backup flows

---

## 8. ⚙️ **POWER APPS SETTINGS**

### **8.1 App-level Settings:**
```json
{
  "DataSources": [
    "SharePoint.DonVi",
    "SharePoint.NguoiDung", 
    "SharePoint.DonNghiPhep",
    "SharePoint.SoNgayPhep",
    "SharePoint.QuyTrinhDuyet",
    "SharePoint.LoaiNghi",
    "SharePoint.NgayLe",
    "SharePoint.Quyen",
    "SharePoint.VaiTro",
    "SharePoint.CauHinhHeThong",
    "SharePoint.MauEmail"
  ],
  "EnableFormulas": true,
  "EnableDelegation": true
}
```

### **8.2 Performance Settings:**
- **Data row limit**: 2000 rows per query
- **Delegation**: Enable cho large lists
- **Caching**: Local variables cho frequent data

---

## 9. 🧪 **TESTING REQUIREMENTS**

### **9.1 Data Integrity Tests:**
- ✅ All foreign key relationships work
- ✅ Calculated fields update correctly
- ✅ Permissions enforce properly
- ✅ Validation rules trigger

### **9.2 Performance Tests:**
- ✅ Page load < 3 seconds
- ✅ Data submission < 2 seconds
- ✅ Search/filter responsive
- ✅ Works on mobile devices

### **9.3 User Acceptance Tests:**
- ✅ Each role can access correct features
- ✅ Workflow phê duyệt hoạt động
- ✅ Email notifications gửi đúng
- ✅ Reports generate correctly

---

## 10. 📚 **DOCUMENTATION**

### **10.1 Technical Docs:**
- ✅ API documentation
- ✅ Database schema
- ✅ PowerFx formulas
- ✅ Troubleshooting guide

### **10.2 User Docs:**
- ✅ User manual by role
- ✅ Quick start guide
- ✅ Video tutorials
- ✅ FAQ

---

## 🚦 **READINESS CHECKLIST**

### **Phase 1: Infrastructure** ✅
- [ ] SharePoint site created
- [ ] 11 Lists created with correct schema
- [ ] Sample data imported
- [ ] Permissions configured

### **Phase 2: Integration** ✅  
- [ ] Power Apps connections established
- [ ] Power Automate flows created
- [ ] Email templates configured
- [ ] Testing environment ready

### **Phase 3: Deployment** ✅
- [ ] User acceptance testing passed
- [ ] Performance benchmarks met
- [ ] Security review completed
- [ ] Documentation finalized

---

## ⚠️ **COMMON PITFALLS TO AVOID**

1. **❌ Wrong column types**: Sẽ gây lỗi Power Apps formulas
2. **❌ Missing relationships**: Dữ liệu bị orphaned
3. **❌ Incorrect permissions**: Users không thể access data
4. **❌ Large list limits**: SharePoint 5000 item threshold
5. **❌ Non-delegable formulas**: Performance issues

---

## 📞 **SUPPORT CONTACTS**

- **SharePoint Admin**: IT Department
- **Power Platform Admin**: Power Platform Center of Excellence
- **Business Owner**: HR Department
- **Technical Support**: Power Apps Support Team

---

**🎯 HOÀN THÀNH TẤT CẢ CÁC BƯỚC TRÊN TRƯỚC KHI TRIỂN KHAI POWER APP!** 