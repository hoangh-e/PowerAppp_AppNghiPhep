# Master PowerShell Script to validate ALL Power App Rules
# Usage: .\validate_all_rules.ps1

param(
    [string]$SourcePath = "src",
    [switch]$StopOnError = $false,
    [switch]$Verbose = $false
)

Write-Host "🚀 POWER APP RULES - COMPREHENSIVE VALIDATION" -ForegroundColor Green -BackgroundColor Black
Write-Host "=============================================" -ForegroundColor Green -BackgroundColor Black
Write-Host "📁 Source Path: $SourcePath" -ForegroundColor Yellow
Write-Host "⏰ Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow
Write-Host ""

$totalErrors = 0
$totalWarnings = 0
$executedScripts = 0
$failedScripts = 0
$startTime = Get-Date

# Script execution results
$results = @()

function Execute-ValidationScript {
    param(
        [string]$ScriptName,
        [string]$Description,
        [string]$Priority
    )
    
    $script:executedScripts++
    
    Write-Host "[$script:executedScripts] 🔍 $Description" -ForegroundColor Cyan
    Write-Host "    Script: $ScriptName" -ForegroundColor Gray
    Write-Host "    Priority: $Priority" -ForegroundColor Gray
    
    $scriptPath = Join-Path $PSScriptRoot $ScriptName
    
    if (-not (Test-Path $scriptPath)) {
        Write-Host "    ❌ Script không tồn tại: $scriptPath" -ForegroundColor Red
        $script:failedScripts++
        $script:results += [PSCustomObject]@{
            Script = $ScriptName
            Description = $Description
            Priority = $Priority
            Status = "MISSING"
            ExitCode = -1
            Duration = "N/A"
            Errors = "Script file not found"
        }
        return $false
    }
    
    $executeStart = Get-Date
    
    try {
        # Execute script with parameters
        $exitCode = & $scriptPath -SourcePath $SourcePath
        $executeDuration = (Get-Date) - $executeStart
        
        if ($exitCode -eq 0) {
            Write-Host "    ✅ PASSED" -ForegroundColor Green
            $status = "PASSED"
        } else {
            Write-Host "    ❌ FAILED (Exit Code: $exitCode)" -ForegroundColor Red
            $script:failedScripts++
            $script:totalErrors++
            $status = "FAILED"
        }
        
        $script:results += [PSCustomObject]@{
            Script = $ScriptName
            Description = $Description
            Priority = $Priority
            Status = $status
            ExitCode = $exitCode
            Duration = $executeDuration.TotalSeconds
            Errors = if ($exitCode -ne 0) { "Check individual script output" } else { "None" }
        }
        
        if ($StopOnError -and $exitCode -ne 0) {
            Write-Host "    🛑 Stopping execution due to error (StopOnError flag)" -ForegroundColor Red
            return $false
        }
        
        return $true
        
    } catch {
        $executeDuration = (Get-Date) - $executeStart
        Write-Host "    💥 EXCEPTION: $($_.Exception.Message)" -ForegroundColor Red
        $script:failedScripts++
        $script:totalErrors++
        
        $script:results += [PSCustomObject]@{
            Script = $ScriptName
            Description = $Description
            Priority = $Priority
            Status = "EXCEPTION"
            ExitCode = -2
            Duration = $executeDuration.TotalSeconds
            Errors = $_.Exception.Message
        }
        
        if ($StopOnError) {
            Write-Host "    🛑 Stopping execution due to exception (StopOnError flag)" -ForegroundColor Red
            return $false
        }
        
        return $false
    }
}

Write-Host "🏁 PHASE 1: CRITICAL VALIDATIONS" -ForegroundColor White -BackgroundColor Red
Write-Host "================================" -ForegroundColor White -BackgroundColor Red

# Phase 1: CRITICAL Scripts
$phase1Scripts = @(
    @{ Name = "check_component_definitions.ps1"; Description = "Component Definition Structure"; Priority = "🔴 CRITICAL" },
    @{ Name = "check_yaml_syntax.ps1"; Description = "YAML Syntax Validation"; Priority = "🔴 CRITICAL" },
    @{ Name = "check_valid_icons.ps1"; Description = "Valid Icon References"; Priority = "🔴 CRITICAL" },
    @{ Name = "check_textmode_violations.ps1"; Description = "TextMode Property Violations"; Priority = "🔴 CRITICAL" }
)

foreach ($script in $phase1Scripts) {
    $continue = Execute-ValidationScript -ScriptName $script.Name -Description $script.Description -Priority $script.Priority
    if (-not $continue -and $StopOnError) { break }
    Write-Host ""
}

Write-Host "🏁 PHASE 2: CRITICAL PHASE 2 VALIDATIONS" -ForegroundColor White -BackgroundColor Red
Write-Host "=========================================" -ForegroundColor White -BackgroundColor Red

# Phase 2: NEW CRITICAL Scripts (Phase 2 from roadmap)
$phase2CriticalScripts = @(
    @{ Name = "check_text_formatting.ps1"; Description = "Text Concatenation Formatting"; Priority = "🔴 CRITICAL" },
    @{ Name = "check_control_references.ps1"; Description = "Control Name References"; Priority = "🔴 CRITICAL" },
    @{ Name = "check_component_controls.ps1"; Description = "Component Control Usage"; Priority = "🔴 CRITICAL" },
    @{ Name = "check_missing_properties.ps1"; Description = "Required Properties Validation"; Priority = "🔴 CRITICAL" }
)

foreach ($script in $phase2CriticalScripts) {
    $continue = Execute-ValidationScript -ScriptName $script.Name -Description $script.Description -Priority $script.Priority
    if (-not $continue -and $StopOnError) { break }
    Write-Host ""
}

Write-Host "🏁 PHASE 3: HIGH PRIORITY VALIDATIONS" -ForegroundColor White -BackgroundColor DarkRed
Write-Host "=====================================" -ForegroundColor White -BackgroundColor DarkRed

# Phase 3: HIGH Priority Scripts (includes new Phase 3 scripts)
$phase3Scripts = @(
    @{ Name = "check_button_properties.ps1"; Description = "Button Properties Validation"; Priority = "🟠 HIGH" },
    @{ Name = "check_rectangle_properties.ps1"; Description = "Rectangle Properties Validation"; Priority = "🟠 HIGH" },
    @{ Name = "check_rgba_functions.ps1"; Description = "RGBA Functions Validation"; Priority = "🟠 HIGH" },
    @{ Name = "check_absolute_positioning.ps1"; Description = "Absolute Positioning Violations"; Priority = "🟠 HIGH" },
    @{ Name = "check_fixed_numbers.ps1"; Description = "Fixed Numbers Usage"; Priority = "🟠 HIGH" },
    @{ Name = "validate_power_app_rules.ps1"; Description = "Comprehensive Rules Check"; Priority = "🟠 HIGH" }
)

foreach ($script in $phase3Scripts) {
    $continue = Execute-ValidationScript -ScriptName $script.Name -Description $script.Description -Priority $script.Priority
    if (-not $continue -and $StopOnError) { break }
    Write-Host ""
}

Write-Host "🏁 PHASE 4: MEDIUM PRIORITY VALIDATIONS" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "=======================================" -ForegroundColor Black -BackgroundColor Yellow

# Phase 4: MEDIUM Priority Scripts (renamed from Phase 3)
$phase4Scripts = @(
    @{ Name = "fix_multiline_formulas.ps1"; Description = "Multi-line Formula Validation"; Priority = "🟡 MEDIUM" },
    @{ Name = "fix_self_properties.ps1"; Description = "Self Properties Validation"; Priority = "🟡 MEDIUM" },
    @{ Name = "remove_invalid_properties.ps1"; Description = "Invalid Properties Removal"; Priority = "🟡 MEDIUM" }
)

foreach ($script in $phase4Scripts) {
    $continue = Execute-ValidationScript -ScriptName $script.Name -Description $script.Description -Priority $script.Priority
    if (-not $continue -and $StopOnError) { break }
    Write-Host ""
}

# Calculate total execution time
$totalDuration = (Get-Date) - $startTime

# Generate comprehensive report
Write-Host "📊 VALIDATION SUMMARY REPORT" -ForegroundColor White -BackgroundColor Blue
Write-Host "============================" -ForegroundColor White -BackgroundColor Blue

Write-Host ""
Write-Host "⏱️  EXECUTION SUMMARY:" -ForegroundColor Cyan
Write-Host "   Total Scripts Executed: $executedScripts" -ForegroundColor Yellow
Write-Host "   Scripts Passed: $($executedScripts - $failedScripts)" -ForegroundColor Green
Write-Host "   Scripts Failed: $failedScripts" -ForegroundColor Red
Write-Host "   Total Duration: $([math]::Round($totalDuration.TotalMinutes, 2)) minutes" -ForegroundColor Yellow
Write-Host ""

# Results by priority
$criticalResults = $results | Where-Object { $_.Priority -match "CRITICAL" }
$highResults = $results | Where-Object { $_.Priority -match "HIGH" }
$mediumResults = $results | Where-Object { $_.Priority -match "MEDIUM" }

Write-Host "📈 RESULTS BY PRIORITY:" -ForegroundColor Cyan
Write-Host "   🔴 CRITICAL: $($criticalResults.Count) scripts, $($criticalResults | Where-Object { $_.Status -eq "FAILED" } | Measure-Object).Count failed" -ForegroundColor Red
Write-Host "   🟠 HIGH: $($highResults.Count) scripts, $($highResults | Where-Object { $_.Status -eq "FAILED" } | Measure-Object).Count failed" -ForegroundColor Yellow
Write-Host "   🟡 MEDIUM: $($mediumResults.Count) scripts, $($mediumResults | Where-Object { $_.Status -eq "FAILED" } | Measure-Object).Count failed" -ForegroundColor Yellow
Write-Host ""

# Detailed results
if ($Verbose -or $failedScripts -gt 0) {
    Write-Host "🔍 DETAILED RESULTS:" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($result in $results) {
        $statusColor = switch ($result.Status) {
            "PASSED" { "Green" }
            "FAILED" { "Red" }
            "MISSING" { "Magenta" }
            "EXCEPTION" { "Red" }
            default { "White" }
        }
        
        Write-Host "   [$($result.Priority)] $($result.Script)" -ForegroundColor White
        Write-Host "      Status: $($result.Status)" -ForegroundColor $statusColor
        Write-Host "      Duration: $([math]::Round($result.Duration, 2))s" -ForegroundColor Gray
        if ($result.Status -ne "PASSED") {
            Write-Host "      Errors: $($result.Errors)" -ForegroundColor Red
        }
        Write-Host ""
    }
}

# Save detailed report to file
$reportPath = "src/COMPREHENSIVE_VALIDATION_REPORT.md"
$currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$reportContent = "# COMPREHENSIVE POWER APP RULES VALIDATION REPORT" + "`n`n"
$reportContent += "**Execution Time:** $currentTime" + "`n"
$reportContent += "**Source Path:** $SourcePath" + "`n"
$reportContent += "**Total Duration:** $([math]::Round($totalDuration.TotalMinutes, 2)) minutes" + "`n`n"

$reportContent += "## 📊 SUMMARY" + "`n`n"
$reportContent += "| Metric | Value |" + "`n"
$reportContent += "|--------|-------|" + "`n"
$reportContent += "| Total Scripts | $executedScripts |" + "`n"
$reportContent += "| Scripts Passed | $($executedScripts - $failedScripts) |" + "`n"
$reportContent += "| Scripts Failed | $failedScripts |" + "`n"
$reportContent += "| Success Rate | $([math]::Round((($executedScripts - $failedScripts) / $executedScripts) * 100, 2))% |" + "`n`n"

$reportContent += "## 🔍 DETAILED RESULTS" + "`n`n"
foreach ($result in $results) {
    $reportContent += "### $($result.Script)" + "`n"
    $reportContent += "- **Description:** $($result.Description)" + "`n"
    $reportContent += "- **Priority:** $($result.Priority)" + "`n"
    $reportContent += "- **Status:** $($result.Status)" + "`n"
    $reportContent += "- **Duration:** $([math]::Round($result.Duration, 2)) seconds" + "`n"
    if ($result.Status -ne "PASSED") {
        $reportContent += "- **Errors:** $($result.Errors)" + "`n"
    }
    $reportContent += "`n"
}

$reportContent | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "📄 Detailed report saved to: $reportPath" -ForegroundColor Green
Write-Host ""

# Final status
if ($failedScripts -eq 0) {
    Write-Host "🎉 ALL VALIDATIONS PASSED! Power App rules compliance achieved!" -ForegroundColor Green -BackgroundColor Black
    exit 0
} else {
    Write-Host "❌ VALIDATIONS FAILED! $failedScripts out of $executedScripts scripts failed." -ForegroundColor Red -BackgroundColor Black
    Write-Host "   Please check individual script outputs and fix violations before proceeding." -ForegroundColor Red
    exit 1
} 