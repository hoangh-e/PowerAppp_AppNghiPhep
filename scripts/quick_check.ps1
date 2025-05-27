# Quick check for multi-line formulas
Write-Host "KIEM TRA MULTI-LINE FORMULAS" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

$files = Get-ChildItem "src" -Recurse -Filter "*.yaml"
$totalErrors = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $multilineCount = ([regex]::Matches($content, "OnVisible:\s*\||OnSelect:\s*\|")).Count
    
    if ($multilineCount -gt 0) {
        Write-Host "$($file.Name): $multilineCount multi-line formulas" -ForegroundColor Red
        $totalErrors += $multilineCount
    } else {
        Write-Host "$($file.Name): OK" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "TONG KET:" -ForegroundColor Yellow
Write-Host "Multi-line formulas con lai: $totalErrors" -ForegroundColor $(if ($totalErrors -eq 0) { "Green" } else { "Red" }) 