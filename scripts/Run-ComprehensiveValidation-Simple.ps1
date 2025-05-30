# ====================================================================
# RUN COMPREHENSIVE VALIDATION (SIMPLIFIED)
# Script: Run-ComprehensiveValidation-Simple.ps1
# Purpose: Execute all available Power App rules validation scripts
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [switch]$Verbose
)

Write-Host "🎯 COMPREHENSIVE POWER APP VALIDATION" -ForegroundColor Magenta
Write-Host "=====================================" -ForegroundColor Magenta
Write-Host ""

$startTime = Get-Date
$totalViolations = 0
$results = @()

# Define validation scripts
$scripts = @(
    "Check-ComponentDefinitions.ps1",
    "Check-ControlRules.ps1", 
    "Check-PositionSize.ps1",
    "Check-TextFormatting.ps1",
    "Check-IconGuidelines.ps1"
)

Write-Host "VALIDATION PLAN:" -ForegroundColor Cyan
foreach ($script in $scripts) {
    Write-Host "  ✓ $script" -ForegroundColor Yellow
}
Write-Host ""

# Execute each validation script
foreach ($script in $scripts) {
    Write-Host "=" * 60 -ForegroundColor Gray
    Write-Host "EXECUTING: $script" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Gray
    
    if (Test-Path $script) {
        try {
            $output = & ".\$script" -SourcePath $SourcePath -Verbose:$Verbose
            $exitCode = $LASTEXITCODE
            
            if ($exitCode -eq 0) {
                Write-Host "✅ PASSED: $script" -ForegroundColor Green
            } else {
                Write-Host "❌ FAILED: $script (Exit Code: $exitCode)" -ForegroundColor Red
                $totalViolations += $exitCode
            }
            
            $results += [PSCustomObject]@{
                Script = $script
                ExitCode = $exitCode
                Status = if ($exitCode -eq 0) { "PASSED" } else { "FAILED" }
                Violations = $exitCode
            }
            
        }
        catch {
            Write-Host "💥 ERROR executing $script" -ForegroundColor Red
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            $results += [PSCustomObject]@{
                Script = $script
                ExitCode = -1
                Status = "ERROR"
                Violations = 0
            }
        }
    }
    else {
        Write-Host "⚠️  MISSING: $script not found" -ForegroundColor Yellow
        $results += [PSCustomObject]@{
            Script = $script
            ExitCode = -2
            Status = "MISSING"
            Violations = 0
        }
    }
    
    Write-Host ""
}

# Check fix scripts availability
Write-Host "=" * 60 -ForegroundColor Gray
Write-Host "CHECKING FIX SCRIPTS AVAILABILITY" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Gray

$fixScripts = @(
    "Fix-ComponentDefinitions.ps1",
    "Fix-ControlRules.ps1",
    "Fix-PositionSize.ps1", 
    "Fix-TextFormatting.ps1",
    "Fix-IconGuidelines.ps1"
)

$availableFixes = 0
foreach ($fixScript in $fixScripts) {
    if (Test-Path $fixScript) {
        Write-Host "  ✅ $fixScript - Available" -ForegroundColor Green
        $availableFixes++
    } else {
        Write-Host "  ❌ $fixScript - Missing" -ForegroundColor Red
    }
}

# Summary
$endTime = Get-Date
$duration = $endTime - $startTime

$passedScripts = ($results | Where-Object { $_.Status -eq "PASSED" }).Count
$failedScripts = ($results | Where-Object { $_.Status -eq "FAILED" }).Count
$errorScripts = ($results | Where-Object { $_.Status -eq "ERROR" }).Count
$missingScripts = ($results | Where-Object { $_.Status -eq "MISSING" }).Count

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Magenta
Write-Host "COMPREHENSIVE VALIDATION SUMMARY" -ForegroundColor Magenta
Write-Host "=" * 80 -ForegroundColor Magenta

Write-Host ""
Write-Host "EXECUTION SUMMARY:" -ForegroundColor Cyan
Write-Host "  Total Scripts: $($scripts.Count)" -ForegroundColor White
Write-Host "  Passed: $passedScripts" -ForegroundColor Green
Write-Host "  Failed: $failedScripts" -ForegroundColor Red
Write-Host "  Errors: $errorScripts" -ForegroundColor Red  
Write-Host "  Missing: $missingScripts" -ForegroundColor Yellow
Write-Host "  Total Violations: $totalViolations" -ForegroundColor $(if ($totalViolations -eq 0) { 'Green' } else { 'Red' })
Write-Host "  Duration: $($duration.TotalSeconds) seconds" -ForegroundColor White

Write-Host ""
Write-Host "FIX SCRIPTS AVAILABLE:" -ForegroundColor Cyan
Write-Host "  Available Fix Scripts: $availableFixes/$($fixScripts.Count)" -ForegroundColor White

if ($totalViolations -gt 0 -and $availableFixes -gt 0) {
    Write-Host ""
    Write-Host "💡 RECOMMENDED ACTIONS:" -ForegroundColor Yellow
    Write-Host "  Run available fix scripts to resolve violations:" -ForegroundColor Yellow
    foreach ($fixScript in $fixScripts) {
        if (Test-Path $fixScript) {
            Write-Host "    .\$fixScript -SourcePath $SourcePath" -ForegroundColor Cyan
        }
    }
}

Write-Host ""
Write-Host "DETAILED RESULTS:" -ForegroundColor Cyan
foreach ($result in $results) {
    $color = switch ($result.Status) {
        "PASSED" { "Green" }
        "FAILED" { "Red" }
        "ERROR" { "Red" }
        "MISSING" { "Yellow" }
    }
    
    $violationText = if ($result.Violations -gt 0) { " ($($result.Violations) violations)" } else { "" }
    Write-Host "  $($result.Status): $($result.Script)$violationText" -ForegroundColor $color
}

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Magenta

if ($failedScripts -gt 0 -or $errorScripts -gt 0) {
    Write-Host "🚨 VALIDATION FAILED - Issues detected" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ VALIDATION PASSED - All scripts completed successfully" -ForegroundColor Green
    exit 0
} 