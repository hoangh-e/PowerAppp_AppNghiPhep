# Script để sửa các thuộc tính Self không hợp lệ trong Power Apps YAML files

# Lấy tất cả file YAML
$yamlFiles = Get-ChildItem -Recurse -Filter "*.yaml"

foreach ($file in $yamlFiles) {
    Write-Host "Processing: $($file.Name)"
    
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    
    # Sửa Self.IsHovered thành Self.Hover
    $content = $content -replace 'Self\.IsHovered', 'Self.Hover'
    
    # Sửa Self.IsFocused thành Self.Focus
    $content = $content -replace 'Self\.IsFocused', 'Self.Focus'
    
    # Chỉ ghi file nếu có thay đổi
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "  Updated: $($file.Name)"
    }
}

Write-Host "Completed processing all YAML files." 