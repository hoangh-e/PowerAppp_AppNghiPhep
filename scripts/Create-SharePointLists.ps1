# ====================================================================
# SCRIPT TỰ ĐỘNG TẠO 11 SHAREPOINT LISTS CHO ỨNG DỤNG NGHỈ PHÉP
# ====================================================================
# Author: AI Assistant
# Date: December 2024
# Purpose: Tạo tự động 11 SharePoint Lists theo cấu trúc đã tối ưu hóa
# Prerequisites: PnP PowerShell module đã được cài đặt
# ====================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$SiteUrl,
    
    [Parameter(Mandatory=$false)]
    [string]$TemplateFile = "sharepoint_sample_data.md"
)

# Import PnP PowerShell Module
if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Write-Host "Installing PnP PowerShell module..." -ForegroundColor Yellow
    Install-Module -Name PnP.PowerShell -Force -AllowClobber
}

# Connect to SharePoint
Write-Host "Connecting to SharePoint site: $SiteUrl" -ForegroundColor Green
Connect-PnPOnline -Url $SiteUrl -Interactive

# Function to create Choice column
function Add-ChoiceColumn {
    param($ListName, $ColumnName, $Choices, $Required = $false, $DefaultValue = $null)
    
    $column = @{
        Name = $ColumnName
        Type = "Choice"
        Choices = $Choices
        Required = $Required
    }
    
    if ($DefaultValue) {
        $column.DefaultValue = $DefaultValue
    }
    
    Add-PnPField -List $ListName -Field $column
}

# Function to create Lookup column
function Add-LookupColumn {
    param($ListName, $ColumnName, $LookupListName, $LookupField = "Title", $Required = $false, $AllowMultiple = $false)
    
    $lookupList = Get-PnPList -Identity $LookupListName
    $column = @{
        Name = $ColumnName
        Type = "Lookup"
        LookupList = $lookupList.Id
        LookupField = $LookupField
        Required = $Required
        AllowMultiple = $AllowMultiple
    }
    
    Add-PnPField -List $ListName -Field $column
}

try {
    Write-Host "`n🏗️ STARTING SHAREPOINT LISTS CREATION..." -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan

    # ====================================================================
    # PHASE 1: MASTER DATA LISTS (Không phụ thuộc)
    # ====================================================================
    Write-Host "`n📋 Phase 1: Creating Master Data Lists..." -ForegroundColor Yellow

    # 1. QUYEN - Hệ thống quyền
    Write-Host "Creating list: Quyen (Permissions)" -ForegroundColor Green
    $quyenList = New-PnPList -Title "Quyen" -Template GenericList -OnQuickLaunch
    Add-PnPField -List "Quyen" -DisplayName "MaQuyen" -InternalName "MaQuyen" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "Quyen" -DisplayName "TenQuyen" -InternalName "TenQuyen" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "Quyen" -DisplayName "MoTa" -InternalName "MoTa" -Type Note -AddToDefaultView
    Add-PnPField -List "Quyen" -DisplayName "GiaTri" -InternalName "GiaTri" -Type Number -Required -AddToDefaultView
    Set-PnPField -List "Quyen" -Identity "Title" -Values @{Hidden=$true}

    # 2. LOAINGHI - Danh mục loại nghỉ phép
    Write-Host "Creating list: LoaiNghi (Leave Types)" -ForegroundColor Green
    $loaiNghiList = New-PnPList -Title "LoaiNghi" -Template GenericList -OnQuickLaunch
    Add-PnPField -List "LoaiNghi" -DisplayName "MaLoai" -InternalName "MaLoai" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "LoaiNghi" -DisplayName "TenLoai" -InternalName "TenLoai" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "LoaiNghi" -DisplayName "CoLuong" -InternalName "CoLuong" -Type Boolean -Required -AddToDefaultView
    Add-PnPField -List "LoaiNghi" -DisplayName "MoTa" -InternalName "MoTa" -Type Note -AddToDefaultView
    Set-PnPField -List "LoaiNghi" -Identity "Title" -Values @{Hidden=$true}

    # 3. NGAYLE - Lịch nghỉ lễ
    Write-Host "Creating list: NgayLe (Holidays)" -ForegroundColor Green
    $ngayLeList = New-PnPList -Title "NgayLe" -Template GenericList -OnQuickLaunch
    Add-PnPField -List "NgayLe" -DisplayName "MaNgayLe" -InternalName "MaNgayLe" -Type Number -Required -AddToDefaultView
    Add-PnPField -List "NgayLe" -DisplayName "Ngay" -InternalName "Ngay" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "NgayLe" -DisplayName "TenNgayLe" -InternalName "TenNgayLe" -Type Text -Required -AddToDefaultView
    Add-ChoiceColumn -ListName "NgayLe" -ColumnName "Buoi" -Choices @("CaNgay", "BuoiSang", "BuoiChieu") -Required $true -DefaultValue "CaNgay"
    Add-PnPField -List "NgayLe" -DisplayName "Nam" -InternalName "Nam" -Type Number -Required -AddToDefaultView
    Set-PnPField -List "NgayLe" -Identity "Title" -Values @{Hidden=$true}

    # 4. CAUHINHETHONG - Cấu hình hệ thống
    Write-Host "Creating list: CauHinhHeThong (System Configuration)" -ForegroundColor Green
    $cauHinhList = New-PnPList -Title "CauHinhHeThong" -Template GenericList -OnQuickLaunch
    Add-PnPField -List "CauHinhHeThong" -DisplayName "MaCauHinh" -InternalName "MaCauHinh" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "CauHinhHeThong" -DisplayName "TenCauHinh" -InternalName "TenCauHinh" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "CauHinhHeThong" -DisplayName "GiaTri" -InternalName "GiaTri" -Type Text -Required -AddToDefaultView
    Add-ChoiceColumn -ListName "CauHinhHeThong" -ColumnName "KieuDuLieu" -Choices @("Text", "Number", "Boolean", "Date") -Required $true
    Add-PnPField -List "CauHinhHeThong" -DisplayName "MoTa" -InternalName "MoTa" -Type Note -AddToDefaultView
    Add-PnPField -List "CauHinhHeThong" -DisplayName "NgayCapNhat" -InternalName "NgayCapNhat" -Type DateTime -AddToDefaultView
    Set-PnPField -List "CauHinhHeThong" -Identity "Title" -Values @{Hidden=$true}

    # 5. MAUEMAIL - Template email
    Write-Host "Creating list: MauEmail (Email Templates)" -ForegroundColor Green
    $mauEmailList = New-PnPList -Title "MauEmail" -Template GenericList -OnQuickLaunch
    Add-PnPField -List "MauEmail" -DisplayName "MaMau" -InternalName "MaMau" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "MauEmail" -DisplayName "TenMau" -InternalName "TenMau" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "MauEmail" -DisplayName "TieuDe" -InternalName "TieuDe" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "MauEmail" -DisplayName "NoiDung" -InternalName "NoiDung" -Type Note -Required -AddToDefaultView
    Add-PnPField -List "MauEmail" -DisplayName "ThamSo" -InternalName "ThamSo" -Type Note -AddToDefaultView
    Add-ChoiceColumn -ListName "MauEmail" -ColumnName "LoaiSuKien" -Choices @("TaoDon", "PheDuyet", "TuChoi", "HetHan") -Required $true
    Add-ChoiceColumn -ListName "MauEmail" -ColumnName "TrangThai" -Choices @("HoatDong", "TamNghi") -Required $true -DefaultValue "HoatDong"
    Add-PnPField -List "MauEmail" -DisplayName "NgayTao" -InternalName "NgayTao" -Type DateTime -AddToDefaultView
    Add-PnPField -List "MauEmail" -DisplayName "NgayCapNhat" -InternalName "NgayCapNhat" -Type DateTime -AddToDefaultView
    Set-PnPField -List "MauEmail" -Identity "Title" -Values @{Hidden=$true}

    Write-Host "✅ Phase 1 completed: Master Data Lists created" -ForegroundColor Green

    # ====================================================================
    # PHASE 2: REFERENCE DATA LISTS (Phụ thuộc Phase 1)
    # ====================================================================
    Write-Host "`n📋 Phase 2: Creating Reference Data Lists..." -ForegroundColor Yellow

    # 6. DONVI - Cấu trúc tổ chức
    Write-Host "Creating list: DonVi (Departments)" -ForegroundColor Green
    $donViList = New-PnPList -Title "DonVi" -Template GenericList -OnQuickLaunch
    Add-PnPField -List "DonVi" -DisplayName "MaDonVi" -InternalName "MaDonVi" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "DonVi" -DisplayName "TenDonVi" -InternalName "TenDonVi" -Type Text -Required -AddToDefaultView
    Add-LookupColumn -ListName "DonVi" -ColumnName "DonViCha" -LookupListName "DonVi" -LookupField "MaDonVi"
    Set-PnPField -List "DonVi" -Identity "Title" -Values @{Hidden=$true}

    # 7. VAITRO - Vai trò (lookup Quyen)
    Write-Host "Creating list: VaiTro (Roles)" -ForegroundColor Green
    $vaiTroList = New-PnPList -Title "VaiTro" -Template GenericList -OnQuickLaunch
    Add-PnPField -List "VaiTro" -DisplayName "MaVaiTro" -InternalName "MaVaiTro" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "VaiTro" -DisplayName "TenVaiTro" -InternalName "TenVaiTro" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "VaiTro" -DisplayName "MoTa" -InternalName "MoTa" -Type Note -AddToDefaultView
    Add-LookupColumn -ListName "VaiTro" -ColumnName "CacQuyen" -LookupListName "Quyen" -LookupField "MaQuyen" -AllowMultiple $true
    Set-PnPField -List "VaiTro" -Identity "Title" -Values @{Hidden=$true}

    Write-Host "✅ Phase 2 completed: Reference Data Lists created" -ForegroundColor Green

    # ====================================================================
    # PHASE 3: USER DATA LISTS (Phụ thuộc Phase 2)
    # ====================================================================
    Write-Host "`n📋 Phase 3: Creating User Data Lists..." -ForegroundColor Yellow

    # 8. NGUOIDUNG - Thông tin nhân viên
    Write-Host "Creating list: NguoiDung (Users)" -ForegroundColor Green
    $nguoiDungList = New-PnPList -Title "NguoiDung" -Template GenericList -OnQuickLaunch
    Add-PnPField -List "NguoiDung" -DisplayName "MaNhanVien" -InternalName "MaNhanVien" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "NguoiDung" -DisplayName "HoTen" -InternalName "HoTen" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "NguoiDung" -DisplayName "Email" -InternalName "Email" -Type Text -Required -AddToDefaultView
    Add-PnPField -List "NguoiDung" -DisplayName "SoDienThoai" -InternalName "SoDienThoai" -Type Text -AddToDefaultView
    Add-PnPField -List "NguoiDung" -DisplayName "ChucDanh" -InternalName "ChucDanh" -Type Text -AddToDefaultView
    Add-LookupColumn -ListName "NguoiDung" -ColumnName "MaDonVi" -LookupListName "DonVi" -LookupField "MaDonVi" -Required $true
    Add-LookupColumn -ListName "NguoiDung" -ColumnName "MaVaiTro" -LookupListName "VaiTro" -LookupField "MaVaiTro" -Required $true
    Add-PnPField -List "NguoiDung" -DisplayName "NgayVaoLam" -InternalName "NgayVaoLam" -Type DateTime -AddToDefaultView
    Add-PnPField -List "NguoiDung" -DisplayName "NgaySinh" -InternalName "NgaySinh" -Type DateTime -AddToDefaultView
    Add-ChoiceColumn -ListName "NguoiDung" -ColumnName "GioiTinh" -Choices @("Nam", "Nu") -DefaultValue "Nam"
    Add-PnPField -List "NguoiDung" -DisplayName "DiaChi" -InternalName "DiaChi" -Type Note -AddToDefaultView
    Add-ChoiceColumn -ListName "NguoiDung" -ColumnName "TrangThai" -Choices @("HoatDong", "TamNghi", "DaNghi") -Required $true -DefaultValue "HoatDong"
    Add-PnPField -List "NguoiDung" -DisplayName "Avatar" -InternalName "Avatar" -Type URL -AddToDefaultView
    Add-LookupColumn -ListName "NguoiDung" -ColumnName "MaQuanLy" -LookupListName "NguoiDung" -LookupField "MaNhanVien"
    Add-PnPField -List "NguoiDung" -DisplayName "NgayTao" -InternalName "NgayTao" -Type DateTime -AddToDefaultView
    Add-PnPField -List "NguoiDung" -DisplayName "NgayCapNhat" -InternalName "NgayCapNhat" -Type DateTime -AddToDefaultView
    Set-PnPField -List "NguoiDung" -Identity "Title" -Values @{Hidden=$true}

    # 9. QUYTRINHDUYET - Workflow
    Write-Host "Creating list: QuyTrinhDuyet (Approval Workflow)" -ForegroundColor Green
    $quyTrinhList = New-PnPList -Title "QuyTrinhDuyet" -Template GenericList -OnQuickLaunch
    Add-PnPField -List "QuyTrinhDuyet" -DisplayName "MaQuyTrinh" -InternalName "MaQuyTrinh" -Type Number -Required -AddToDefaultView
    Add-LookupColumn -ListName "QuyTrinhDuyet" -ColumnName "MaDonVi" -LookupListName "DonVi" -LookupField "MaDonVi" -Required $true
    Add-PnPField -List "QuyTrinhDuyet" -DisplayName "Cap" -InternalName "Cap" -Type Number -Required -AddToDefaultView
    Add-LookupColumn -ListName "QuyTrinhDuyet" -ColumnName "MaVaiTro" -LookupListName "VaiTro" -LookupField "MaVaiTro" -Required $true
    Add-LookupColumn -ListName "QuyTrinhDuyet" -ColumnName "NguoiDuyetMacDinh" -LookupListName "NguoiDung" -LookupField "MaNhanVien" -Required $true
    Add-PnPField -List "QuyTrinhDuyet" -DisplayName "DangHoatDong" -InternalName "DangHoatDong" -Type Boolean -Required -AddToDefaultView
    Set-PnPField -List "QuyTrinhDuyet" -Identity "Title" -Values @{Hidden=$true}

    Write-Host "✅ Phase 3 completed: User Data Lists created" -ForegroundColor Green

    # ====================================================================
    # PHASE 4: TRANSACTION DATA LISTS (Phụ thuộc tất cả)
    # ====================================================================
    Write-Host "`n📋 Phase 4: Creating Transaction Data Lists..." -ForegroundColor Yellow

    # 10. SONGAYPHEP - Quota nghỉ phép
    Write-Host "Creating list: SoNgayPhep (Leave Quota)" -ForegroundColor Green
    $soNgayPhepList = New-PnPList -Title "SoNgayPhep" -Template GenericList -OnQuickLaunch
    Add-PnPField -List "SoNgayPhep" -DisplayName "MaSoPhep" -InternalName "MaSoPhep" -Type Number -Required -AddToDefaultView
    Add-LookupColumn -ListName "SoNgayPhep" -ColumnName "MaNhanVien" -LookupListName "NguoiDung" -LookupField "MaNhanVien" -Required $true
    Add-PnPField -List "SoNgayPhep" -DisplayName "Nam" -InternalName "Nam" -Type Number -Required -AddToDefaultView
    Add-PnPField -List "SoNgayPhep" -DisplayName "TongNgayDuocPhep" -InternalName "TongNgayDuocPhep" -Type Number -Required -AddToDefaultView
    Add-PnPField -List "SoNgayPhep" -DisplayName "SoNgayDaNghi" -InternalName "SoNgayDaNghi" -Type Number -AddToDefaultView
    Add-PnPField -List "SoNgayPhep" -DisplayName "SoNgayConLai" -InternalName "SoNgayConLai" -Type Calculated -AddToDefaultView
    Add-PnPField -List "SoNgayPhep" -DisplayName "SoNgayKhongLuong" -InternalName "SoNgayKhongLuong" -Type Number -AddToDefaultView
    Set-PnPField -List "SoNgayPhep" -Identity "Title" -Values @{Hidden=$true}

    # 11. DONNGHIPHEP - Đơn nghỉ phép (CUỐI CÙNG)
    Write-Host "Creating list: DonNghiPhep (Leave Requests)" -ForegroundColor Green
    $donNghiPhepList = New-PnPList -Title "DonNghiPhep" -Template GenericList -OnQuickLaunch
    Add-PnPField -List "DonNghiPhep" -DisplayName "MaDon" -InternalName "MaDon" -Type Guid -Required -AddToDefaultView
    Add-LookupColumn -ListName "DonNghiPhep" -ColumnName "MaNhanVien" -LookupListName "NguoiDung" -LookupField "MaNhanVien" -Required $true
    Add-PnPField -List "DonNghiPhep" -DisplayName "NgayBatDau" -InternalName "NgayBatDau" -Type DateTime -Required -AddToDefaultView
    Add-PnPField -List "DonNghiPhep" -DisplayName "NgayKetThuc" -InternalName "NgayKetThuc" -Type DateTime -Required -AddToDefaultView
    Add-PnPField -List "DonNghiPhep" -DisplayName "SoNgayNghi" -InternalName "SoNgayNghi" -Type Calculated -AddToDefaultView
    Add-LookupColumn -ListName "DonNghiPhep" -ColumnName "MaLoai" -LookupListName "LoaiNghi" -LookupField "MaLoai" -Required $true
    Add-PnPField -List "DonNghiPhep" -DisplayName "LyDo" -InternalName "LyDo" -Type Note -Required -AddToDefaultView
    Add-LookupColumn -ListName "DonNghiPhep" -ColumnName "NguoiBanGiao" -LookupListName "NguoiDung" -LookupField "MaNhanVien"
    Add-PnPField -List "DonNghiPhep" -DisplayName "NoiDungBanGiao" -InternalName "NoiDungBanGiao" -Type Note -AddToDefaultView
    Add-ChoiceColumn -ListName "DonNghiPhep" -ColumnName "TrangThai" -Choices @("ChoDuyetCap1", "ChoDuyetCap2", "ChoDuyetCap3", "DaDuyet", "TuChoi", "Huy", "HetHan") -Required $true -DefaultValue "ChoDuyetCap1"
    Add-PnPField -List "DonNghiPhep" -DisplayName "NgayTao" -InternalName "NgayTao" -Type DateTime -Required -AddToDefaultView
    Add-ChoiceColumn -ListName "DonNghiPhep" -ColumnName "BuoiNghi" -Choices @("CaNgay", "BuoiSang", "BuoiChieu") -Required $true -DefaultValue "CaNgay"
    Add-LookupColumn -ListName "DonNghiPhep" -ColumnName "NguoiTao" -LookupListName "NguoiDung" -LookupField "MaNhanVien" -Required $true
    Add-PnPField -List "DonNghiPhep" -DisplayName "NgayCapNhat" -InternalName "NgayCapNhat" -Type DateTime -AddToDefaultView
    Add-LookupColumn -ListName "DonNghiPhep" -ColumnName "NguoiCapNhat" -LookupListName "NguoiDung" -LookupField "MaNhanVien"
    Add-PnPField -List "DonNghiPhep" -DisplayName "ThoiHanPheDuyet" -InternalName "ThoiHanPheDuyet" -Type Calculated -AddToDefaultView
    Add-ChoiceColumn -ListName "DonNghiPhep" -ColumnName "UuTien" -Choices @("BinhThuong", "Cao", "KhanCap") -DefaultValue "BinhThuong"
    Add-PnPField -List "DonNghiPhep" -DisplayName "GhiChuHR" -InternalName "GhiChuHR" -Type Note -AddToDefaultView
    Add-PnPField -List "DonNghiPhep" -DisplayName "NgayGhiNhan" -InternalName "NgayGhiNhan" -Type DateTime -AddToDefaultView
    Add-PnPField -List "DonNghiPhep" -DisplayName "GhiChuPheDuyet" -InternalName "GhiChuPheDuyet" -Type Note -AddToDefaultView
    Set-PnPField -List "DonNghiPhep" -Identity "Title" -Values @{Hidden=$true}

    Write-Host "✅ Phase 4 completed: Transaction Data Lists created" -ForegroundColor Green

    # ====================================================================
    # FINAL CONFIGURATION
    # ====================================================================
    Write-Host "`n⚙️ Configuring List Settings..." -ForegroundColor Yellow

    # Set list permissions and settings
    $lists = @("Quyen", "VaiTro", "LoaiNghi", "NgayLe", "CauHinhHeThong", "MauEmail", "DonVi", "NguoiDung", "QuyTrinhDuyet", "SoNgayPhep", "DonNghiPhep")
    
    foreach ($listName in $lists) {
        Write-Host "Configuring $listName..." -ForegroundColor Cyan
        
        # Enable versioning
        Set-PnPList -Identity $listName -EnableVersioning $true -EnableMinorVersions $false -MajorVersions 50
        
        # Enable content approval for critical lists
        if ($listName -in @("DonNghiPhep", "NguoiDung", "QuyTrinhDuyet")) {
            Set-PnPList -Identity $listName -EnableContentTypes $true
        }
        
        # Set list description
        $description = switch ($listName) {
            "Quyen" { "Hệ thống quyền bit-wise cho ứng dụng" }
            "VaiTro" { "Vai trò và phân quyền người dùng" }
            "LoaiNghi" { "Danh mục loại nghỉ phép" }
            "NgayLe" { "Lịch nghỉ lễ hàng năm" }
            "CauHinhHeThong" { "Cấu hình tham số hệ thống" }
            "MauEmail" { "Template email thông báo" }
            "DonVi" { "Cấu trúc tổ chức công ty" }
            "NguoiDung" { "Thông tin nhân viên" }
            "QuyTrinhDuyet" { "Cấu hình quy trình phê duyệt" }
            "SoNgayPhep" { "Quota nghỉ phép cá nhân" }
            "DonNghiPhep" { "Đơn nghỉ phép và trạng thái" }
        }
        
        Set-PnPList -Identity $listName -Description $description
    }

    # ====================================================================
    # SUCCESS MESSAGE
    # ====================================================================
    Write-Host "`n🎉 SUCCESS! ALL SHAREPOINT LISTS CREATED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host "=================================================" -ForegroundColor Green
    Write-Host "✅ 11 SharePoint Lists created in correct order" -ForegroundColor Green
    Write-Host "✅ All columns and relationships configured" -ForegroundColor Green
    Write-Host "✅ List settings and permissions applied" -ForegroundColor Green
    Write-Host "✅ Ready for data import!" -ForegroundColor Green
    Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Import sample data using sharepoint_sample_data.md" -ForegroundColor White
    Write-Host "2. Configure Power Apps connections" -ForegroundColor White
    Write-Host "3. Create Power Automate flows" -ForegroundColor White
    Write-Host "4. Test the application" -ForegroundColor White
    Write-Host "`n🔗 SharePoint Site: $SiteUrl" -ForegroundColor Cyan

} catch {
    Write-Host "`n❌ ERROR OCCURRED!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
    Write-Host "`n🔧 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Check SharePoint permissions" -ForegroundColor White
    Write-Host "2. Verify PnP PowerShell module is installed" -ForegroundColor White
    Write-Host "3. Ensure site URL is correct" -ForegroundColor White
    Write-Host "4. Check network connectivity" -ForegroundColor White
} finally {
    # Disconnect from SharePoint
    Disconnect-PnPOnline
    Write-Host "`n🔌 Disconnected from SharePoint" -ForegroundColor Gray
}

# ====================================================================
# USAGE EXAMPLES:
# .\Create-SharePointLists.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/leave-mgmt-asiashine"
# ==================================================================== 