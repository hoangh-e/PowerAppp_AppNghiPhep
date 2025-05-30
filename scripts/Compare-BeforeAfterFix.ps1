# ====================================================================
# COMPARE BEFORE/AFTER FIX RESULTS
# Script: Compare-BeforeAfterFix.ps1
# Purpose: Compare validation results before and after fixes
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$TestFile = "",
    [switch]$RunFixes,
    [switch]$Verbose
)

Write-Host "📊 BEFORE/AFTER FIX COMPARISON" -ForegroundColor Magenta
Write-Host "================================" -ForegroundColor Magenta
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Function to run validation and get results
function Get-ValidationResults {
    param(
        [string]$ScriptName,
        [string]$SourcePath
    )
    
    $scriptFile = Join-Path $scriptPath $ScriptName
    if (-not (Test-Path $scriptFile)) {
        Write-Host "⚠️ Script not found: $ScriptName" -ForegroundColor Yellow
        return $null
    }
    
    try {
        # Capture output
        $output = & $scriptFile -SourcePath $SourcePath 2>&1
        $exitCode = $LASTEXITCODE
        
        # Parse results from output
        $violations = 0
        $files = 0
        $compliance = 0
        
        foreach ($line in $output) {
            if ($line -match "Files checked:\s*(\d+)") {
                $files = [int]$matches[1]
            }
            if ($line -match "Total violations:\s*(\d+)") {
                $violations = [int]$matches[1]
            }
            if ($line -match "Compliance rate:\s*([0-9.]+)%") {
                $compliance = [double]$matches[1]
            }
        }
        
        return @{
            Script = $ScriptName
            Files = $files
            Violations = $violations
            Compliance = $compliance
            ExitCode = $exitCode
            Success = ($exitCode -eq 0)
        }
    }
    catch {
        Write-Host "❌ Error running $ScriptName : $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Function to run a fix script
function Run-FixScript {
    param(
        [string]$FixScriptName,
        [string]$SourcePath,
        [string]$TargetFile = ""
    )
    
    $fixScript = Join-Path $scriptPath $FixScriptName
    if (-not (Test-Path $fixScript)) {
        Write-Host "⚠️ Fix script not found: $FixScriptName" -ForegroundColor Yellow
        return @{ Success = $false; Fixes = 0 }
    }
    
    try {
        $params = @{
            SourcePath = $SourcePath
        }
        
        if ($TargetFile) {
            $params.TargetFile = $TargetFile
        }
        
        $output = & $fixScript @params 2>&1
        $exitCode = $LASTEXITCODE
        
        # Parse fixes from output
        $totalFixes = 0
        foreach ($line in $output) {
            if ($line -match "Total fixes:\s*(\d+)") {
                $totalFixes = [int]$matches[1]
            }
        }
        
        return @{
            Success = ($exitCode -eq 0)
            Fixes = $totalFixes
            Output = $output
        }
    }
    catch {
        Write-Host "❌ Error running fix: $($_.Exception.Message)" -ForegroundColor Red
        return @{ Success = $false; Fixes = 0 }
    }
}

# Test scenarios
$testScenarios = @(
    @{
        Name = "File Structure"
        ValidateScript = "Check-FileStructure.ps1"
        FixScript = "Fix-FileStructure.ps1"
    },
    @{
        Name = "Properties and Icons"
        ValidateScript = "Check-PropertiesIcons.ps1"
        FixScript = "Fix-PropertiesIcons.ps1"
    }
)

$results = @()

foreach ($scenario in $testScenarios) {
    Write-Host "🧪 Testing: $($scenario.Name)" -ForegroundColor Cyan
    Write-Host "─" * 40
    
    # Step 1: Get baseline results
    Write-Host "📋 Step 1: Getting baseline violations..." -ForegroundColor White
    $beforeResults = Get-ValidationResults -ScriptName $scenario.ValidateScript -SourcePath $SourcePath
    
    if ($beforeResults) {
        Write-Host "  Files: $($beforeResults.Files)" -ForegroundColor Gray
        Write-Host "  Violations: $($beforeResults.Violations)" -ForegroundColor Red
        Write-Host "  Compliance: $($beforeResults.Compliance)%" -ForegroundColor Yellow
    } else {
        Write-Host "  ❌ Failed to get baseline results" -ForegroundColor Red
        continue
    }
    
    # Step 2: Run fixes if requested
    $fixResults = $null
    if ($RunFixes) {
        Write-Host "🔧 Step 2: Applying fixes..." -ForegroundColor White
        $fixResults = Run-FixScript -FixScriptName $scenario.FixScript -SourcePath $SourcePath -TargetFile $TestFile
        
        if ($fixResults.Success) {
            Write-Host "  ✅ Applied $($fixResults.Fixes) fixes" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Fix failed" -ForegroundColor Red
            continue
        }
    } else {
        Write-Host "🔧 Step 2: Running dry-run fixes..." -ForegroundColor White
        $fixResults = Run-FixScript -FixScriptName $scenario.FixScript -SourcePath $SourcePath -TargetFile $TestFile
        Write-Host "  �� Would apply $($fixResults.Fixes) fixes" -ForegroundColor Yellow
    }
    
    # Step 3: Get after results (only if fixes were actually applied)
    $afterResults = $null
    if ($RunFixes -and $fixResults.Success) {
        Write-Host "📋 Step 3: Getting post-fix violations..." -ForegroundColor White
        $afterResults = Get-ValidationResults -ScriptName $scenario.ValidateScript -SourcePath $SourcePath
        
        if ($afterResults) {
            Write-Host "  Files: $($afterResults.Files)" -ForegroundColor Gray
            Write-Host "  Violations: $($afterResults.Violations)" -ForegroundColor $(if ($afterResults.Violations -lt $beforeResults.Violations) { 'Green' } else { 'Red' })
            Write-Host "  Compliance: $($afterResults.Compliance)%" -ForegroundColor $(if ($afterResults.Compliance -gt $beforeResults.Compliance) { 'Green' } else { 'Yellow' })
        }
    }
    
    # Calculate improvements
    $violationReduction = 0
    $complianceImprovement = 0
    
    if ($afterResults) {
        $violationReduction = $beforeResults.Violations - $afterResults.Violations
        $complianceImprovement = $afterResults.Compliance - $beforeResults.Compliance
    }
    
    $results += [PSCustomObject]@{
        Scenario = $scenario.Name
        BeforeViolations = $beforeResults.Violations
        AfterViolations = if ($afterResults) { $afterResults.Violations } else { "N/A" }
        ViolationReduction = $violationReduction
        BeforeCompliance = $beforeResults.Compliance
        AfterCompliance = if ($afterResults) { $afterResults.Compliance } else { "N/A" }
        ComplianceImprovement = $complianceImprovement
        FixesApplied = if ($fixResults) { $fixResults.Fixes } else { 0 }
        FixSuccess = if ($fixResults) { $fixResults.Success } else { $false }
    }
    
    Write-Host ""
}

# Summary Report
Write-Host "=" * 60 -ForegroundColor Magenta
Write-Host "📈 SUMMARY REPORT" -ForegroundColor Magenta
Write-Host "=" * 60 -ForegroundColor Magenta
Write-Host ""

$totalViolationsBefore = ($results | Measure-Object -Property BeforeViolations -Sum).Sum
$totalViolationsAfter = ($results | Where-Object { $_.AfterViolations -ne "N/A" } | Measure-Object -Property AfterViolations -Sum).Sum
$totalFixesApplied = ($results | Measure-Object -Property FixesApplied -Sum).Sum

Write-Host "🎯 OVERALL IMPACT:" -ForegroundColor Cyan
Write-Host "  Total violations before: $totalViolationsBefore" -ForegroundColor White
if ($RunFixes) {
    Write-Host "  Total violations after:  $totalViolationsAfter" -ForegroundColor Green
    Write-Host "  Total violations fixed:  $($totalViolationsBefore - $totalViolationsAfter)" -ForegroundColor Green
    Write-Host "  Fix effectiveness:       $([math]::Round((($totalViolationsBefore - $totalViolationsAfter) / $totalViolationsBefore) * 100, 1))%" -ForegroundColor Green
} else {
    Write-Host "  Potential fixes:         $totalFixesApplied" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "📊 DETAILED RESULTS:" -ForegroundColor Cyan
$results | Format-Table -AutoSize -Property @(
    @{Name="Scenario"; Expression={$_.Scenario}; Width=20},
    @{Name="Before"; Expression={$_.BeforeViolations}; Width=8},
    @{Name="After"; Expression={$_.AfterViolations}; Width=8},
    @{Name="Reduced"; Expression={$_.ViolationReduction}; Width=8},
    @{Name="Compliance%"; Expression={if ($_.AfterCompliance -ne "N/A") { "$($_.BeforeCompliance)% → $($_.AfterCompliance)%" } else { "$($_.BeforeCompliance)%" }}; Width=15},
    @{Name="Fixes"; Expression={$_.FixesApplied}; Width=6}
)

Write-Host ""
Write-Host "🔍 ANALYSIS:" -ForegroundColor Cyan

foreach ($result in $results) {
    $status = if ($result.FixSuccess) { 
        if ($RunFixes) { "✅ FIXED" } else { "📝 READY" }
    } else { 
        "❌ FAILED" 
    }
    
    Write-Host "  $status $($result.Scenario):" -ForegroundColor $(if ($result.FixSuccess) { if ($RunFixes) { 'Green' } else { 'Yellow' } } else { 'Red' })
    
    if ($result.ViolationReduction -gt 0) {
        Write-Host "    - Reduced violations by $($result.ViolationReduction) ($([math]::Round(($result.ViolationReduction / $result.BeforeViolations) * 100, 1))%)" -ForegroundColor Green
    }
    
    if ($result.ComplianceImprovement -gt 0) {
        Write-Host "    - Improved compliance by $([math]::Round($result.ComplianceImprovement, 1))%" -ForegroundColor Green
    }
    
    if ($result.FixesApplied -gt 0 -and -not $RunFixes) {
        Write-Host "    - Ready to apply $($result.FixesApplied) fixes" -ForegroundColor Yellow
    }
}

Write-Host ""
if (-not $RunFixes) {
    Write-Host "💡 To apply fixes, run with -RunFixes parameter" -ForegroundColor Cyan
} else {
    Write-Host "✅ Fix analysis complete!" -ForegroundColor Green
} 