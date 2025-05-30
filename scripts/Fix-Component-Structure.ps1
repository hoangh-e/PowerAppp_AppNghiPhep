# Fix Component Structure Issues
param([string]$SourcePath = "src")

Write-Host "🔧 COMPONENT STRUCTURE FIX" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan

$fixes = 0
$files = Get-ChildItem -Path $SourcePath -Recurse -Include "*.yaml"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    
    # Fix Event properties missing DataType
    # Pattern: PropertyKind: Event followed by missing DataType
    $eventPattern = '(?s)(PropertyKind:\s*Event[^\r\n]*[\r\n]+\s*DisplayName:[^\r\n]*[\r\n]+\s*Description:[^\r\n]*[\r\n]+\s*ReturnType:[^\r\n]*[\r\n]+)'
    if ($content -match $eventPattern) {
        $content = $content -replace $eventPattern, ($matches[1] + "        DataType: Text`r`n        ")
        Write-Host "  ✅ Added DataType to Event property in: $($file.Name)" -ForegroundColor Green
        $fixes++
    }
    
    # Alternative pattern for events with Default but missing DataType
    $eventPattern2 = '(?s)(PropertyKind:\s*Event[^\r\n]*[\r\n]+\s*DisplayName:[^\r\n]*[\r\n]+\s*Description:[^\r\n]*[\r\n]+\s*ReturnType:[^\r\n]*[\r\n]+\s*Default:[^\r\n]*)'
    if ($content -match $eventPattern2) {
        $replacement = $matches[1] -replace '(ReturnType:[^\r\n]*[\r\n]+)', ('$1        DataType: Text' + "`r`n        ")
        $content = $content -replace [regex]::Escape($matches[1]), $replacement
        Write-Host "  ✅ Added DataType to Event property (pattern 2) in: $($file.Name)" -ForegroundColor Green
        $fixes++
    }
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
    }
}

Write-Host ""
Write-Host "Total fixes applied: $fixes" -ForegroundColor Green
exit 0 