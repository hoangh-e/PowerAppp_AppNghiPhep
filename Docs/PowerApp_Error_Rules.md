# Power Apps Error Rules và Cách Xử Lý

## Lỗi PA2108: Unknown property

### Mô tả
Lỗi PA2108 xảy ra khi sử dụng thuộc tính không hợp lệ cho một loại control cụ thể.

### Các trường hợp phổ biến:

#### 1. BorderRadius cho GroupContainer và các control khác
```yaml
# ❌ KHÔNG HỢP LỆ
- MyContainer:
    Control: GroupContainer
    Variant: ManualLayout
    Properties:
      BorderRadius: =12  # Lỗi PA2108: Unknown property 'BorderRadius' for control type 'GroupContainer' and variant 'ManualLayout'
```

```yaml
# ❌ KHÔNG HỢP LỆ - BorderRadius cho Label
- MyLabel:
    Control: Label
    Properties:
      BorderRadius: =12  # Lỗi PA2108: Unknown property 'BorderRadius' for control type 'Label'
```

```yaml
# ✅ HỢP LỆ - Xóa thuộc tính BorderRadius
- MyContainer:
    Control: GroupContainer
    Variant: ManualLayout
    Properties:
      # BorderRadius đã được xóa
      Fill: =RGBA(255, 255, 255, 1)
      BorderColor: =RGBA(230, 230, 230, 1)
      BorderThickness: =1
```

#### 2. RadiusBottomLeft, RadiusBottomRight, RadiusTopLeft, RadiusTopRight cho Rectangle
```yaml
# ❌ KHÔNG HỢP LỆ
- MyRectangle:
    Control: Rectangle
    Properties:
      RadiusBottomLeft: =8   # Lỗi PA2108
      RadiusBottomRight: =8  # Lỗi PA2108
      RadiusTopLeft: =8      # Lỗi PA2108
      RadiusTopRight: =8     # Lỗi PA2108
```

```yaml
# ✅ HỢP LỆ - Xóa các thuộc tính radius
- MyRectangle:
    Control: Rectangle
    Properties:
      Fill: =RGBA(255, 255, 255, 1)
```

#### 3. Disabled cho Classic/Button
```yaml
# ❌ KHÔNG HỢP LỆ
- MyButton:
    Control: Classic/Button
    Properties:
      Disabled: =true  # Lỗi PA2108
```

```yaml
# ✅ HỢP LỆ - Sử dụng DisplayMode thay thế
- MyButton:
    Control: Classic/Button
    Properties:
      DisplayMode: =If(condition, DisplayMode.Disabled, DisplayMode.Edit)
```

## Lỗi Self Properties

### Self.IsHovered và Self.IsFocused
```yaml
# ❌ KHÔNG HỢP LỆ
BorderColor: =If(Self.IsHovered || Self.IsFocused, RGBA(0, 120, 212, 1), RGBA(200, 200, 200, 1))
```

```yaml
# ✅ HỢP LỆ
BorderColor: =If(Self.Hover || Self.Focus, RGBA(0, 120, 212, 1), RGBA(200, 200, 200, 1))
```

## Scripts Tự Động

### 1. remove_invalid_properties.ps1
Xóa các thuộc tính không hợp lệ:
- BorderRadius
- RadiusBottomLeft, RadiusBottomRight, RadiusTopLeft, RadiusTopRight  
- Disabled

### 2. fix_self_properties.ps1
Sửa các thuộc tính Self:
- Self.IsHovered → Self.Hover
- Self.IsFocused → Self.Focus

## Cách Sử Dụng Scripts

```powershell
# Chạy script xóa thuộc tính không hợp lệ
.\scripts\remove_invalid_properties.ps1

# Chạy script sửa thuộc tính Self
.\scripts\fix_self_properties.ps1
```

## Ghi Chú
- Luôn backup code trước khi chạy scripts
- Kiểm tra kết quả sau khi chạy scripts
- Các scripts được thiết kế để xử lý hàng loạt tất cả file .yaml trong dự án 