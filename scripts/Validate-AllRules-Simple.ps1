# ====================================================================
# VALIDATE ALL POWER APP RULES (SIMPLE VERSION)
# Script: Validate-AllRules-Simple.ps1
# Purpose: Execute core validation scripts
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [switch]$Verbose
)

Write-Host "🎯 POWER APP RULES VALIDATION (SIMPLE)" -ForegroundColor Magenta
Write-Host "=====================================" -ForegroundColor Magenta
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$totalViolations = 0
$results = @()

# Core validation scripts
$scripts = @(
    "Check-FileStructure.ps1",
    "Check-ControlRules.ps1", 
    "Check-PositionSizeRules.ps1",
    "Check-PropertiesIcons.ps1",
    "Check-NamingConventions.ps1"
)

foreach ($scriptName in $scripts) {
    $scriptFile = Join-Path $scriptPath $scriptName
    
    Write-Host "Testing: $scriptName" -ForegroundColor Cyan
    
    if (Test-Path $scriptFile) {
        try {
            $result = & $scriptFile -SourcePath $SourcePath
            $exitCode = $LASTEXITCODE
            
            if ($exitCode -eq 0) {
                Write-Host "  ✅ PASSED" -ForegroundColor Green
            } else {
                Write-Host "  ❌ FAILED (Exit: $exitCode)" -ForegroundColor Red
                $totalViolations += 1
            }
        }
        catch {
            Write-Host "  💥 ERROR: $($_.Exception.Message)" -ForegroundColor Red
            $totalViolations += 1
        }
    } else {
        Write-Host "  ⚠️ MISSING" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

Write-Host "=" * 50 -ForegroundColor Gray
Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "  Scripts tested: $($scripts.Count)" -ForegroundColor White
Write-Host "  Failed/Error: $totalViolations" -ForegroundColor $(if ($totalViolations -eq 0) { "Green" } else { "Red" })

if ($totalViolations -eq 0) {
    Write-Host "✅ ALL SCRIPTS WORKING" -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ $totalViolations SCRIPT(S) FAILED" -ForegroundColor Red
    exit 1
} 