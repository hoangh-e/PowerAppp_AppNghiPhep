param([string]$SourcePath = "src")

Write-Host "Quick Icon Fix" -ForegroundColor Green
$fixes = 0
$files = Get-ChildItem -Path $SourcePath -Recurse -Include "*.yaml"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    
    $content = $content -replace 'Icon:\s*=\s*Icon\.Calendar(?!Blank)', 'Icon: =Icon.CalendarBlank'
    $content = $content -replace 'Icon:\s*=\s*Icon\.HamburgerMenu', 'Icon: =Icon.Hamburger'
    $content = $content -replace 'Icon:\s*=\s*Icon\.CalendarBlankBlank', 'Icon: =Icon.CalendarBlank'
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "Fixed: $($file.Name)"
        $fixes++
    }
}

Write-Host "Total fixes: $fixes" 