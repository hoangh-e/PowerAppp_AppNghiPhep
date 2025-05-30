# Basic validation test script
param([string]$SourcePath = "src")

Write-Host "Basic Power App Validation Test" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host ""

$totalViolations = 0
$scripts = @("Check-ComponentDefinitions.ps1", "Check-ControlRules.ps1", "Check-PositionSize.ps1", "Check-TextFormatting.ps1", "Check-IconGuidelines.ps1")

foreach ($script in $scripts) {
    Write-Host "Testing: $script" -ForegroundColor Yellow
    if (Test-Path $script) {
        try {
            & ".\$script" -SourcePath $SourcePath | Out-Null
            $exitCode = $LASTEXITCODE
            if ($exitCode -eq 0) {
                Write-Host "  PASSED" -ForegroundColor Green
            } else {
                Write-Host "  FAILED - $exitCode violations" -ForegroundColor Red
                $totalViolations += $exitCode
            }
        }
        catch {
            Write-Host "  ERROR" -ForegroundColor Red
        }
    } else {
        Write-Host "  MISSING" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Total Violations: $totalViolations" -ForegroundColor $(if ($totalViolations -eq 0) { 'Green' } else { 'Red' })

if ($totalViolations -gt 0) {
    Write-Host "Fix scripts available:" -ForegroundColor Cyan
    $fixes = @("Fix-ComponentDefinitions.ps1", "Fix-ControlRules.ps1", "Fix-PositionSize.ps1", "Fix-TextFormatting.ps1", "Fix-IconGuidelines.ps1")
    foreach ($fix in $fixes) {
        if (Test-Path $fix) {
            Write-Host "  .\$fix -SourcePath $SourcePath" -ForegroundColor White
        }
    }
}

exit $totalViolations 