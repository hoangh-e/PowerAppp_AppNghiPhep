# Quick Fix for Remaining Icon Issues
param([string]$SourcePath = "src")

Write-Host "🔧 QUICK ICON FIX" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan

$fixes = 0
$files = Get-ChildItem -Path $SourcePath -Recurse -Include "*.yaml"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    
    # Fix common icon mistakes
    $content = $content -replace 'Icon:\s*=\s*Icon\.Calendar(?!Blank)', 'Icon: =Icon.CalendarBlank'
    $content = $content -replace 'Icon:\s*=\s*Icon\.HamburgerMenu', 'Icon: =Icon.Hamburger'
    $content = $content -replace 'Icon:\s*=\s*Icon\.CalendarBlankBlank', 'Icon: =Icon.CalendarBlank'
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "  ✅ Fixed: $($file.Name)" -ForegroundColor Green
        $fixes++
    }
}

Write-Host ""
if ($fixes -gt 0) {
    Write-Host "Total fixes applied: $fixes" -ForegroundColor Green
} else {
    Write-Host "Total fixes applied: $fixes" -ForegroundColor Yellow
}
exit 0 