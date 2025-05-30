# ====================================================================
# TEST ALL FIX SCRIPTS
# Script: Test-AllFixScripts.ps1
# Purpose: Test all validation and fix scripts to verify they work correctly
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [switch]$RunFixes,
    [switch]$Verbose
)

Write-Host "🧪 TESTING ALL VALIDATION & FIX SCRIPTS" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host ""

$scriptPairs = @(
    @{
        Name = "Control Rules"
        CheckScript = "Check-ControlRules.ps1"
        FixScript = "Fix-ControlRules.ps1"
        Section = "Section 2"
    },
    @{
        Name = "Position & Size"
        CheckScript = "Check-PositionSize.ps1"
        FixScript = "Fix-PositionSize.ps1"
        Section = "Section 3"
    },
    @{
        Name = "Component Definitions"
        CheckScript = "Check-ComponentDefinitions.ps1"
        FixScript = "Fix-ComponentDefinitions.ps1"
        Section = "Section 1.2"
    },
    @{
        Name = "Icon Guidelines"
        CheckScript = "Check-IconGuidelines.ps1"
        FixScript = "Fix-IconGuidelines.ps1"
        Section = "Section 6"
    },
    @{
        Name = "Text Formatting"
        CheckScript = "Check-TextFormatting.ps1"
        FixScript = "Fix-TextFormatting.ps1"
        Section = "Section 5.6"
    }
)

$totalTests = 0
$passedTests = 0
$failedTests = 0
$results = @()

function Test-ScriptPair {
    param(
        [hashtable]$ScriptPair,
        [string]$SourcePath,
        [bool]$RunFixes,
        [bool]$Verbose
    )
    
    $result = @{
        Name = $ScriptPair.Name
        Section = $ScriptPair.Section
        CheckExists = $false
        FixExists = $false
        CheckRuns = $false
        FixRuns = $false
        CheckViolations = 0
        FixesApplied = 0
        CheckAfterFix = 0
        Success = $false
        Errors = @()
    }
    
    $checkPath = Join-Path "scripts" $ScriptPair.CheckScript
    $fixPath = Join-Path "scripts" $ScriptPair.FixScript
    
    # Check if scripts exist
    $result.CheckExists = Test-Path $checkPath
    $result.FixExists = Test-Path $fixPath
    
    if (-not $result.CheckExists) {
        $result.Errors += "Check script not found: $checkPath"
    }
    
    if (-not $result.FixExists) {
        $result.Errors += "Fix script not found: $fixPath"
    }
    
    if (-not $result.CheckExists -or -not $result.FixExists) {
        return $result
    }
    
    Write-Host "Testing: $($ScriptPair.Name) ($($ScriptPair.Section))" -ForegroundColor Yellow
    
    try {
        # Run initial check
        Write-Host "  Running initial validation..." -ForegroundColor Gray
        $checkOutput = & $checkPath -SourcePath $SourcePath 2>&1
        $result.CheckRuns = $LASTEXITCODE -ne $null
        
        # Parse violations from output
        if ($checkOutput -match "Total violations: (\d+)") {
            $result.CheckViolations = [int]$matches[1]
        }
        
        Write-Host "    Found $($result.CheckViolations) violations" -ForegroundColor $(if ($result.CheckViolations -eq 0) { 'Green' } else { 'Red' })
        
        if ($RunFixes -and $result.CheckViolations -gt 0) {
            # Run fix script
            Write-Host "  Running auto-fix..." -ForegroundColor Gray
            $fixOutput = & $fixPath -SourcePath $SourcePath 2>&1
            $result.FixRuns = $LASTEXITCODE -ne $null
            
            # Parse fixes from output
            if ($fixOutput -match "Total fixes: (\d+)") {
                $result.FixesApplied = [int]$matches[1]
            }
            
            Write-Host "    Applied $($result.FixesApplied) fixes" -ForegroundColor $(if ($result.FixesApplied -gt 0) { 'Green' } else { 'Yellow' })
            
            # Run check again to verify fixes
            Write-Host "  Running post-fix validation..." -ForegroundColor Gray
            $checkAfterOutput = & $checkPath -SourcePath $SourcePath 2>&1
            
            if ($checkAfterOutput -match "Total violations: (\d+)") {
                $result.CheckAfterFix = [int]$matches[1]
            }
            
            Write-Host "    Remaining violations: $($result.CheckAfterFix)" -ForegroundColor $(if ($result.CheckAfterFix -eq 0) { 'Green' } else { 'Red' })
        }
        
        # Determine success
        if ($RunFixes) {
            $result.Success = $result.CheckRuns -and $result.FixRuns -and ($result.CheckAfterFix -lt $result.CheckViolations)
        } else {
            $result.Success = $result.CheckRuns
        }
        
    }
    catch {
        $result.Errors += "Error running scripts: $($_.Exception.Message)"
    }
    
    return $result
}

# Run tests for each script pair
foreach ($pair in $scriptPairs) {
    $totalTests++
    $result = Test-ScriptPair -ScriptPair $pair -SourcePath $SourcePath -RunFixes $RunFixes -Verbose $Verbose
    $results += $result
    
    if ($result.Success) {
        $passedTests++
        Write-Host "  ✅ PASSED" -ForegroundColor Green
    } else {
        $failedTests++
        Write-Host "  ❌ FAILED" -ForegroundColor Red
        if ($result.Errors.Count -gt 0) {
            foreach ($error in $result.Errors) {
                Write-Host "    Error: $error" -ForegroundColor Red
            }
        }
    }
    Write-Host ""
}

# Generate summary report
Write-Host "=" * 60 -ForegroundColor Magenta
Write-Host "TEST SUMMARY REPORT" -ForegroundColor Magenta
Write-Host "=" * 60 -ForegroundColor Magenta
Write-Host ""

Write-Host "OVERALL RESULTS:" -ForegroundColor White
Write-Host "  Total tests: $totalTests" -ForegroundColor White
Write-Host "  Passed: $passedTests" -ForegroundColor Green
Write-Host "  Failed: $failedTests" -ForegroundColor Red
Write-Host "  Success rate: $([math]::Round(($passedTests / $totalTests) * 100, 1))%" -ForegroundColor $(if ($passedTests -eq $totalTests) { 'Green' } else { 'Yellow' })
Write-Host ""

Write-Host "DETAILED RESULTS:" -ForegroundColor White
foreach ($result in $results) {
    $status = if ($result.Success) { "✅ PASS" } else { "❌ FAIL" }
    $statusColor = if ($result.Success) { "Green" } else { "Red" }
    
    Write-Host "  $status - $($result.Name) ($($result.Section))" -ForegroundColor $statusColor
    Write-Host "    Check exists: $($result.CheckExists)" -ForegroundColor Gray
    Write-Host "    Fix exists: $($result.FixExists)" -ForegroundColor Gray
    Write-Host "    Check runs: $($result.CheckRuns)" -ForegroundColor Gray
    Write-Host "    Fix runs: $($result.FixRuns)" -ForegroundColor Gray
    
    if ($RunFixes) {
        Write-Host "    Initial violations: $($result.CheckViolations)" -ForegroundColor Gray
        Write-Host "    Fixes applied: $($result.FixesApplied)" -ForegroundColor Gray
        Write-Host "    Final violations: $($result.CheckAfterFix)" -ForegroundColor Gray
        
        if ($result.CheckViolations -gt 0) {
            $fixRate = [math]::Round((($result.CheckViolations - $result.CheckAfterFix) / $result.CheckViolations) * 100, 1)
            Write-Host "    Fix success rate: $fixRate%" -ForegroundColor $(if ($fixRate -ge 80) { 'Green' } elseif ($fixRate -ge 50) { 'Yellow' } else { 'Red' })
        }
    }
    Write-Host ""
}

# Generate visualization
Write-Host "VISUALIZATION:" -ForegroundColor White
Write-Host ""

$maxNameLength = ($results | ForEach-Object { $_.Name.Length } | Measure-Object -Maximum).Maximum
foreach ($result in $results) {
    $name = $result.Name.PadRight($maxNameLength)
    $bar = ""
    
    if ($RunFixes -and $result.CheckViolations -gt 0) {
        $fixRate = [math]::Round((($result.CheckViolations - $result.CheckAfterFix) / $result.CheckViolations) * 100, 1)
        $barLength = [math]::Round($fixRate / 5) # Scale to 20 chars max
        $bar = "█" * $barLength + "░" * (20 - $barLength)
        $color = if ($fixRate -ge 80) { 'Green' } elseif ($fixRate -ge 50) { 'Yellow' } else { 'Red' }
        Write-Host "  $name [$bar] $fixRate%" -ForegroundColor $color
    } else {
        $status = if ($result.Success) { "PASS" } else { "FAIL" }
        $color = if ($result.Success) { 'Green' } else { 'Red' }
        Write-Host "  $name [$status]" -ForegroundColor $color
    }
}

Write-Host ""
if ($passedTests -eq $totalTests) {
    Write-Host "🎉 All tests passed! Scripts are working correctly." -ForegroundColor Green
} else {
    Write-Host "⚠️  Some tests failed. Please check the errors above." -ForegroundColor Yellow
}

if (-not $RunFixes) {
    Write-Host ""
    Write-Host "💡 Run with -RunFixes to test the fix functionality" -ForegroundColor Cyan
}

exit $(if ($passedTests -eq $totalTests) { 0 } else { 1 }) 