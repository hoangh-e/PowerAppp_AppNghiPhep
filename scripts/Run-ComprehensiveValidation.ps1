# ====================================================================
# RUN COMPREHENSIVE VALIDATION
# Script: Run-ComprehensiveValidation.ps1
# Purpose: Execute all available Power App rules validation scripts
# Rules Reference: Complete .cursorrules implementation
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [switch]$FixIssues,
    [switch]$Verbose,
    [switch]$GenerateReport
)

Write-Host "🎯 COMPREHENSIVE POWER APP VALIDATION" -ForegroundColor Magenta
Write-Host "=====================================" -ForegroundColor Magenta
Write-Host "Rules Reference: Complete .cursorrules implementation" -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$totalViolations = 0
$allResults = @()

# Define validation scripts that exist and work
$validationScripts = @(
    @{
        Name = "Check-ComponentDefinitions.ps1"
        Description = "Section 1.2 - Component Definition Structure"
        Critical = $true
    },
    @{
        Name = "Check-ControlRules.ps1"
        Description = "Section 2 - Control Rules"
        Critical = $true
    },
    @{
        Name = "Check-PositionSize.ps1"
        Description = "Section 3 - Position & Size Rules"
        Critical = $true
    },
    @{
        Name = "Check-TextFormatting.ps1"
        Description = "Section 5.6 & 8.18 - Text Formatting Rules"
        Critical = $false
    },
    @{
        Name = "Check-IconGuidelines.ps1"
        Description = "Section 6 - Icon Guidelines"
        Critical = $false
    }
)

Write-Host "VALIDATION PLAN:" -ForegroundColor Cyan
foreach ($script in $validationScripts) {
    $status = if ($script.Critical) { "CRITICAL" } else { "STANDARD" }
    Write-Host "  ✓ $($script.Name) - $($script.Description) [$status]" -ForegroundColor $(if ($script.Critical) { "Red" } else { "Yellow" })
}
Write-Host ""

# Execute each validation script
foreach ($script in $validationScripts) {
    $scriptFile = Join-Path $scriptPath $script.Name
    
    Write-Host "=" * 60 -ForegroundColor Gray
    Write-Host "EXECUTING: $($script.Name)" -ForegroundColor Cyan
    Write-Host "Description: $($script.Description)" -ForegroundColor White
    Write-Host "=" * 60 -ForegroundColor Gray
    
    if (Test-Path $scriptFile) {
        try {
            # Execute the script and capture results
            $result = & $scriptFile -SourcePath $SourcePath -Verbose:$Verbose
            $exitCode = $LASTEXITCODE
            
            if ($exitCode -eq 0) {
                Write-Host "✅ PASSED: $($script.Name)" -ForegroundColor Green
            } else {
                Write-Host "❌ FAILED: $($script.Name) (Exit Code: $exitCode)" -ForegroundColor Red
                if ($script.Critical) {
                    Write-Host "   ⚠️  CRITICAL FAILURE - This may prevent app from functioning" -ForegroundColor Red
                }
                $totalViolations += $exitCode
            }
            
            $allResults += [PSCustomObject]@{
                Script = $script.Name
                Description = $script.Description
                Critical = $script.Critical
                ExitCode = $exitCode
                Violations = $exitCode
                Status = if ($exitCode -eq 0) { "PASSED" } else { "FAILED" }
            }
            
        }
        catch {
            Write-Host "💥 ERROR executing $($script.Name): $($_.Exception.Message)" -ForegroundColor Red
            $allResults += [PSCustomObject]@{
                Script = $script.Name
                Description = $script.Description
                Critical = $script.Critical
                ExitCode = -1
                Violations = 0
                Status = "ERROR"
                Error = $_.Exception.Message
            }
        }
    }
    else {
        Write-Host "⚠️  MISSING: $scriptFile not found" -ForegroundColor Yellow
        $allResults += [PSCustomObject]@{
            Script = $script.Name
            Description = $script.Description
            Critical = $script.Critical
            ExitCode = -2
            Violations = 0
            Status = "MISSING"
        }
    }
    
    Write-Host ""
}

# Additional check for fix scripts availability
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

$availableFixes = @()
foreach ($fixScript in $fixScripts) {
    $fixScriptPath = Join-Path $scriptPath $fixScript
    if (Test-Path $fixScriptPath) {
        $availableFixes += $fixScript
        Write-Host "  ✅ $fixScript - Available" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $fixScript - Missing" -ForegroundColor Red
    }
}

# Generate comprehensive report
$endTime = Get-Date
$duration = $endTime - $startTime

$passedScripts = ($allResults | Where-Object { $_.Status -eq "PASSED" }).Count
$failedScripts = ($allResults | Where-Object { $_.Status -eq "FAILED" }).Count
$errorScripts = ($allResults | Where-Object { $_.Status -eq "ERROR" }).Count
$missingScripts = ($allResults | Where-Object { $_.Status -eq "MISSING" }).Count

$criticalFailed = ($allResults | Where-Object { $_.Critical -and $_.Status -ne "PASSED" }).Count

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Magenta
Write-Host "COMPREHENSIVE VALIDATION SUMMARY" -ForegroundColor Magenta
Write-Host "=" * 80 -ForegroundColor Magenta

Write-Host ""
Write-Host "EXECUTION SUMMARY:" -ForegroundColor Cyan
Write-Host "  Total Scripts: $($allResults.Count)" -ForegroundColor White
Write-Host "  Passed: $passedScripts" -ForegroundColor Green
Write-Host "  Failed: $failedScripts" -ForegroundColor Red
Write-Host "  Errors: $errorScripts" -ForegroundColor Red
Write-Host "  Missing: $missingScripts" -ForegroundColor Yellow
Write-Host "  Total Violations: $totalViolations" -ForegroundColor $(if ($totalViolations -eq 0) { 'Green' } else { 'Red' })
Write-Host "  Duration: $($duration.TotalSeconds) seconds" -ForegroundColor White

Write-Host ""
Write-Host "CRITICAL ASSESSMENT:" -ForegroundColor Cyan
if ($criticalFailed -eq 0) {
    Write-Host "  ✅ All critical validations PASSED" -ForegroundColor Green
    Write-Host "  📦 Power App should build successfully" -ForegroundColor Green
} else {
    Write-Host "  ❌ $criticalFailed critical validation(s) FAILED" -ForegroundColor Red
    Write-Host "  ⚠️  Power App may have build/runtime issues" -ForegroundColor Red
}

Write-Host ""
Write-Host "FIX SCRIPTS AVAILABLE:" -ForegroundColor Cyan
Write-Host "  Total Fix Scripts: $($availableFixes.Count)/$($fixScripts.Count)" -ForegroundColor White
if ($totalViolations -gt 0 -and $availableFixes.Count -gt 0) {
    Write-Host "  💡 Run fix scripts to automatically resolve violations:" -ForegroundColor Yellow
    foreach ($fixScript in $availableFixes) {
        Write-Host "    .\$fixScript -SourcePath $SourcePath" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "DETAILED RESULTS:" -ForegroundColor Cyan
foreach ($result in $allResults) {
    $statusColor = switch ($result.Status) {
        "PASSED" { "Green" }
        "FAILED" { "Red" }
        "ERROR" { "Red" }
        "MISSING" { "Yellow" }
    }
    
    $criticalIndicator = if ($result.Critical) { "[CRITICAL]" } else { "[STANDARD]" }
    $violationInfo = if ($result.Violations -gt 0) { "($($result.Violations) violations)" } else { "" }
    
    $statusPadded = $result.Status.PadRight(7)
    $description = "$($result.Script) - $($result.Description)"
    
    Write-Host "  $statusPadded $criticalIndicator $description $violationInfo" -ForegroundColor $statusColor
    
    if ($result.Error) {
        Write-Host "    Error: $($result.Error)" -ForegroundColor Red
    }
}

# Generate markdown report if requested
if ($GenerateReport) {
    $reportContent = @"
# COMPREHENSIVE POWER APP VALIDATION REPORT

**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  
**Source Path:** $SourcePath  
**Execution Duration:** $($duration.TotalSeconds) seconds  

## SUMMARY

- **Total Scripts:** $($allResults.Count)
- **Passed:** $passedScripts
- **Failed:** $failedScripts  
- **Errors:** $errorScripts
- **Missing:** $missingScripts
- **Total Violations:** $totalViolations
- **Critical Failures:** $criticalFailed

## STATUS

"@

    if ($criticalFailed -eq 0) {
        $reportContent += "✅ **VALIDATION PASSED** - All critical rules are compliant`n`n"
    } else {
        $reportContent += "❌ **VALIDATION FAILED** - $criticalFailed critical rule(s) violated`n`n"
    }

    $reportContent += "## AVAILABLE FIX SCRIPTS`n`n"
    foreach ($fixScript in $availableFixes) {
        $reportContent += "- ✅ $fixScript`n"
    }
    foreach ($fixScript in ($fixScripts | Where-Object { $_ -notin $availableFixes })) {
        $reportContent += "- ❌ $fixScript (missing)`n"
    }

    $reportContent += "`n## DETAILED RESULTS`n`n"
    
    foreach ($result in $allResults) {
        $statusEmoji = switch ($result.Status) {
            "PASSED" { "✅" }
            "FAILED" { "❌" }
            "ERROR" { "💥" }
            "MISSING" { "⚠️" }
        }
        
        $criticalTag = if ($result.Critical) { "**[CRITICAL]**" } else { "[STANDARD]" }
        
        $reportContent += "### $statusEmoji $($result.Script)`n`n"
        $reportContent += "- **Status:** $($result.Status)`n"
        $reportContent += "- **Priority:** $criticalTag`n"
        $reportContent += "- **Description:** $($result.Description)`n"
        $reportContent += "- **Violations:** $($result.Violations)`n"
        
        if ($result.Error) {
            $reportContent += "- **Error:** $($result.Error)`n"
        }
        
        $reportContent += "`n"
    }

    $reportPath = Join-Path $SourcePath "COMPREHENSIVE_VALIDATION_REPORT.md"
    Set-Content -Path $reportPath -Value $reportContent -Encoding UTF8
    Write-Host ""
    Write-Host "📄 Detailed report saved to: $reportPath" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Magenta

# Set exit code based on critical failures
if ($criticalFailed -gt 0 -or $errorScripts -gt 0) {
    Write-Host "🚨 VALIDATION FRAMEWORK: CRITICAL ISSUES DETECTED" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ VALIDATION FRAMEWORK: ALL CRITICAL RULES PASSED" -ForegroundColor Green
    exit 0
} 