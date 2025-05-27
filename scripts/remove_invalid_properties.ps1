# Script để xóa các thuộc tính không hợp lệ trong Power Apps YAML files
# Bổ sung xử lý lỗi PA2108: Unknown property 'BorderRadius' for control type 'GroupContainer' and variant 'ManualLayout'

# Lấy tất cả file YAML
$yamlFiles = Get-ChildItem -Recurse -Filter "*.yaml"

foreach ($file in $yamlFiles) {
    Write-Host "Processing: $($file.Name)"
    
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    
    # Xóa các thuộc tính BorderRadius (PA2108 error)
    $content = $content -replace '(?m)^\s*BorderRadius:\s*=.*\r?\n', ''
    
    # Xóa các thuộc tính RadiusBottomLeft, RadiusBottomRight, RadiusTopLeft, RadiusTopRight
    $content = $content -replace '(?m)^\s*RadiusBottomLeft:\s*=.*\r?\n', ''
    $content = $content -replace '(?m)^\s*RadiusBottomRight:\s*=.*\r?\n', ''
    $content = $content -replace '(?m)^\s*RadiusTopLeft:\s*=.*\r?\n', ''
    $content = $content -replace '(?m)^\s*RadiusTopRight:\s*=.*\r?\n', ''
    
    # Xóa thuộc tính Disabled cho Classic/Button
    $content = $content -replace '(?m)^\s*Disabled:\s*=.*\r?\n', ''
    
    # Chỉ ghi file nếu có thay đổi
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "  Updated: $($file.Name)"
    }
}

Write-Host "Completed processing all YAML files."
Write-Host "Fixed PA2108 errors: BorderRadius properties removed from all controls." 