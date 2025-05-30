# ====================================================================
# VALIDATE ALL POWER APP RULES (MASTER SCRIPT)
# Script: Validate-AllRules.ps1
# Purpose: Execute all Power App rules validation scripts
# Rules Reference: Complete .cursorrules implementation
# Author: AI Assistant (Rules-Based Framework)
# Date: 2024-12-19
# Version: 2.0.0 (Clean Slate)
# ====================================================================

param(
    [string]$SourcePath = "src",
    [switch]$FixIssues,
    [switch]$Verbose,
    [switch]$GenerateReport
)

Write-Host "🎯 POWER APP RULES VALIDATION FRAMEWORK" -ForegroundColor Magenta
Write-Host "=======================================" -ForegroundColor Magenta
Write-Host "Version: 2.0.0 (Clean Slate)" -ForegroundColor Yellow
Write-Host "Rules Reference: Complete .cursorrules implementation" -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$totalViolations = 0
$allResults = @()

# Define validation scripts and their descriptions
$validationScripts = @(
    @{
        Name = "Check-FileStructure.ps1"
        Description = "Section 1 - File Structure Rules"
        Critical = $true
    },
    @{
        Name = "Check-ControlRules.ps1" 
        Description = "Section 2 - Control Rules"
        Critical = $true
    },
    @{
        Name = "Check-PositionSizeRules.ps1"
        Description = "Section 3 - Position & Size Rules"
        Critical = $true
    },
    @{
        Name = "Check-PropertiesIcons.ps1"
        Description = "Section 5-6 - Properties & Icons Rules"
        Critical = $false
    },
    @{
        Name = "Check-NamingConventions.ps1"
        Description = "Section 7 - Naming Conventions"
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
            $arguments = @{
                SourcePath = $SourcePath
                Verbose = $Verbose
            }
            
            if ($FixIssues) {
                $arguments.FixIssues = $true
            }
            
            # Execute the script and capture results
            $result = & $scriptFile @arguments
            $exitCode = $LASTEXITCODE
            
            if ($exitCode -eq 0) {
                Write-Host "✅ PASSED: $($script.Name)" -ForegroundColor Green
            } else {
                Write-Host "❌ FAILED: $($script.Name) (Exit Code: $exitCode)" -ForegroundColor Red
                if ($script.Critical) {
                    Write-Host "   ⚠️  CRITICAL FAILURE - This may prevent app from functioning" -ForegroundColor Red
                }
            }
            
            $allResults += [PSCustomObject]@{
                Script = $script.Name
                Description = $script.Description
                Critical = $script.Critical
                ExitCode = $exitCode
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
            Status = "MISSING"
        }
    }
    
    Write-Host ""
}

# Generate comprehensive report
$endTime = Get-Date
$duration = $endTime - $startTime

$passedScripts = ($allResults | Where-Object { $_.Status -eq "PASSED" }).Count
$failedScripts = ($allResults | Where-Object { $_.Status -eq "FAILED" }).Count
$errorScripts = ($allResults | Where-Object { $_.Status -eq "ERROR" }).Count
$missingScripts = ($allResults | Where-Object { $_.Status -eq "MISSING" }).Count

$criticalFailed = ($allResults | Where-Object { $_.Critical -and $_.Status -ne "PASSED" }).Count

Write-Host "=" * 80 -ForegroundColor Magenta
Write-Host "POWER APP VALIDATION SUMMARY" -ForegroundColor Magenta
Write-Host "=" * 80 -ForegroundColor Magenta

Write-Host ""
Write-Host "EXECUTION SUMMARY:" -ForegroundColor Cyan
Write-Host "  Total Scripts: $($allResults.Count)" -ForegroundColor White
Write-Host "  Passed: $passedScripts" -ForegroundColor Green
Write-Host "  Failed: $failedScripts" -ForegroundColor Red
Write-Host "  Errors: $errorScripts" -ForegroundColor Red
Write-Host "  Missing: $missingScripts" -ForegroundColor Yellow
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
Write-Host "DETAILED RESULTS:" -ForegroundColor Cyan
foreach ($result in $allResults) {
    $statusColor = switch ($result.Status) {
        "PASSED" { "Green" }
        "FAILED" { "Red" }
        "ERROR" { "Red" }
        "MISSING" { "Yellow" }
    }
    
    $criticalIndicator = if ($result.Critical) { "[CRITICAL]" } else { "[STANDARD]"
    
    Write-Host "  $($result.Status.PadRight(7)) $criticalIndicator $($result.Script) - $($result.Description)" -ForegroundColor $statusColor
    
    if ($result.Error) {
        Write-Host "    Error: $($result.Error)" -ForegroundColor Red
    }
}}

# Generate markdown report if requested
if ($GenerateReport) {
    $reportContent = @"
# POWER APP RULES VALIDATION REPORT

**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  
**Framework Version:** 2.0.0 (Clean Slate)  
**Rules Reference:** Complete .cursorrules implementation  
**Execution Duration:** $($duration.TotalSeconds) seconds  

## SUMMARY

- **Total Scripts:** $($allResults.Count)
- **Passed:** $passedScripts
- **Failed:** $failedScripts  
- **Errors:** $errorScripts
- **Missing:** $missingScripts
- **Critical Failures:** $criticalFailed

## STATUS

"@

    if ($criticalFailed -eq 0) {
        $reportContent += "✅ **VALIDATION PASSED** - All critical rules are compliant`n`n"
    } else {
        $reportContent += "❌ **VALIDATION FAILED** - $criticalFailed critical rule(s) violated`n`n"
    }

    $reportContent += "## DETAILED RESULTS`n`n"
    
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
        
        if ($result.Error) {
            $reportContent += "- **Error:** $($result.Error)`n"
        }
        
        $reportContent += "`n"
    }

    $reportPath = Join-Path $SourcePath "POWER_APP_VALIDATION_REPORT.md"
    Set-Content -Path $reportPath -Value $reportContent -Encoding UTF8
    Write-Host ""
    Write-Host "📄 Detailed report saved to: $reportPath" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Magenta

# Set exit code based on critical failures
if ($criticalFailed -gt 0 -or $errorScripts -gt 0) {
    Write-Host "❌ VALIDATION FRAMEWORK: CRITICAL ISSUES DETECTED" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ VALIDATION FRAMEWORK: ALL CRITICAL RULES PASSED" -ForegroundColor Green
    exit 0
} 