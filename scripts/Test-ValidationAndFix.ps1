# ====================================================================
# TEST VALIDATION AND FIX SCRIPTS
# Script: Test-ValidationAndFix.ps1
# Purpose: Test validation and fix scripts with visual before/after results
# Date: 2024-12-19
# ====================================================================

param(
    [string]$TestPath = "test_files",
    [switch]$Verbose,
    [switch]$GenerateReport
)

Write-Host "🧪 POWER APP VALIDATION & FIX TESTING" -ForegroundColor Magenta
Write-Host "=======================================" -ForegroundColor Magenta
Write-Host ""

$startTime = Get-Date
$testResults = @()

# Create test directory if not exists
if (-not (Test-Path $TestPath)) {
    New-Item -ItemType Directory -Path $TestPath -Force | Out-Null
    Write-Host "📁 Created test directory: $TestPath" -ForegroundColor Green
}

# Define test scenarios
$testScenarios = @(
    @{
        Name = "Component Definition Violations"
        ValidationScript = "Check-ComponentDefinitions.ps1"
        FixScript = "Fix-ComponentDefinitions.ps1"
        TestFile = "$TestPath/TestComponent_WithViolations.yaml"
        ExpectedViolations = 4  # 2 events missing DataType + 2 properties missing fields
    },
    @{
        Name = "Icon Guidelines Violations" 
        ValidationScript = "Check-IconGuidelines.ps1"
        FixScript = "Fix-IconGuidelines.ps1"
        TestFile = "$TestPath/TestScreen_WithViolations.yaml"
        ExpectedViolations = 4  # Calendar + HamburgerMenu icons
    },
    @{
        Name = "Text Formatting Violations"
        ValidationScript = "Check-TextFormatting.ps1"
        FixScript = "Fix-TextFormatting.ps1" 
        TestFile = "$TestPath/TestScreen_WithViolations.yaml"
        ExpectedViolations = 3  # Text with spaces after colons
    }
)

Write-Host "🎯 Running $($testScenarios.Count) test scenarios..." -ForegroundColor Yellow
Write-Host ""

foreach ($scenario in $testScenarios) {
    Write-Host "📋 Testing: $($scenario.Name)" -ForegroundColor Cyan
    Write-Host "   File: $($scenario.TestFile)" -ForegroundColor Gray
    
    $scenarioResult = @{
        Name = $scenario.Name
        TestFile = $scenario.TestFile
        ValidationScript = $scenario.ValidationScript
        FixScript = $scenario.FixScript
        BeforeViolations = 0
        AfterViolations = 0
        FixesApplied = 0
        Status = "Unknown"
        Errors = @()
    }
    
    # Check if test file exists
    if (-not (Test-Path $scenario.TestFile)) {
        Write-Host "   ❌ Test file not found: $($scenario.TestFile)" -ForegroundColor Red
        $scenarioResult.Status = "File Not Found"
        $scenarioResult.Errors += "Test file not found"
        $testResults += $scenarioResult
        continue
    }
    
    # STEP 1: Run validation BEFORE fix
    Write-Host "   🔍 Step 1: Validation before fix..." -ForegroundColor Yellow
    
    if (Test-Path $scenario.ValidationScript) {
        try {
            $beforeOutput = & "./$($scenario.ValidationScript)" -SourcePath $TestPath 2>&1
            $beforeViolations = 0
            
            # Parse validation output for violation count
            $beforeOutput | ForEach-Object {
                if ($_ -match "Found (\d+) violations" -or $_ -match "(\d+) violations found") {
                    $beforeViolations += [int]$matches[1]
                }
            }
            
            $scenarioResult.BeforeViolations = $beforeViolations
            Write-Host "   📊 Violations found: $beforeViolations" -ForegroundColor $(if ($beforeViolations -gt 0) { "Red" } else { "Green" })
            
            if ($Verbose) {
                $beforeOutput | ForEach-Object { Write-Host "      $_" -ForegroundColor Gray }
            }
        }
        catch {
            Write-Host "   ❌ Validation script error: $_" -ForegroundColor Red
            $scenarioResult.Errors += "Validation error: $_"
        }
    }
    else {
        Write-Host "   ⚠️  Validation script not found: $($scenario.ValidationScript)" -ForegroundColor Yellow
        $scenarioResult.Errors += "Validation script not found"
    }
    
    # STEP 2: Run fix script
    Write-Host "   🔧 Step 2: Applying fixes..." -ForegroundColor Yellow
    
    if (Test-Path $scenario.FixScript) {
        try {
            $fixOutput = & "./$($scenario.FixScript)" -SourcePath $TestPath 2>&1
            $fixesApplied = 0
            
            # Parse fix output for fixes count
            $fixOutput | ForEach-Object {
                if ($_ -match "(\d+) fix(es)? applied" -or $_ -match "Total fixes: (\d+)") {
                    $fixesApplied += [int]$matches[1]
                }
            }
            
            $scenarioResult.FixesApplied = $fixesApplied
            Write-Host "   🛠️  Fixes applied: $fixesApplied" -ForegroundColor $(if ($fixesApplied -gt 0) { "Green" } else { "Yellow" })
            
            if ($Verbose) {
                $fixOutput | ForEach-Object { Write-Host "      $_" -ForegroundColor Gray }
            }
        }
        catch {
            Write-Host "   ❌ Fix script error: $_" -ForegroundColor Red
            $scenarioResult.Errors += "Fix error: $_"
        }
    }
    else {
        Write-Host "   ⚠️  Fix script not found: $($scenario.FixScript)" -ForegroundColor Yellow
        $scenarioResult.Errors += "Fix script not found"
    }
    
    # STEP 3: Run validation AFTER fix
    Write-Host "   🔍 Step 3: Validation after fix..." -ForegroundColor Yellow
    
    if (Test-Path $scenario.ValidationScript) {
        try {
            $afterOutput = & "./$($scenario.ValidationScript)" -SourcePath $TestPath 2>&1
            $afterViolations = 0
            
            # Parse validation output for violation count
            $afterOutput | ForEach-Object {
                if ($_ -match "Found (\d+) violations" -or $_ -match "(\d+) violations found") {
                    $afterViolations += [int]$matches[1]
                }
            }
            
            $scenarioResult.AfterViolations = $afterViolations
            Write-Host "   📊 Violations remaining: $afterViolations" -ForegroundColor $(if ($afterViolations -eq 0) { "Green" } else { "Red" })
            
            if ($Verbose) {
                $afterOutput | ForEach-Object { Write-Host "      $_" -ForegroundColor Gray }
            }
        }
        catch {
            Write-Host "   ❌ Post-validation error: $_" -ForegroundColor Red
            $scenarioResult.Errors += "Post-validation error: $_"
        }
    }
    
    # STEP 4: Determine test result
    $violationsFixed = $scenarioResult.BeforeViolations - $scenarioResult.AfterViolations
    
    if ($scenarioResult.AfterViolations -eq 0) {
        $scenarioResult.Status = "✅ SUCCESS"
        Write-Host "   ✅ SUCCESS: All violations fixed!" -ForegroundColor Green
    }
    elseif ($violationsFixed -gt 0) {
        $scenarioResult.Status = "⚠️ PARTIAL"
        Write-Host "   ⚠️  PARTIAL: $violationsFixed violations fixed, $($scenarioResult.AfterViolations) remaining" -ForegroundColor Yellow
    }
    else {
        $scenarioResult.Status = "❌ FAILED"
        Write-Host "   ❌ FAILED: No violations fixed" -ForegroundColor Red
    }
    
    $testResults += $scenarioResult
    Write-Host ""
}

# Generate summary report
Write-Host "📊 TEST SUMMARY REPORT" -ForegroundColor Magenta
Write-Host "======================" -ForegroundColor Magenta
Write-Host ""

$totalTests = $testResults.Count
$successfulTests = ($testResults | Where-Object { $_.Status -eq "✅ SUCCESS" }).Count
$partialTests = ($testResults | Where-Object { $_.Status -eq "⚠️ PARTIAL" }).Count
$failedTests = ($testResults | Where-Object { $_.Status -eq "❌ FAILED" }).Count

Write-Host "📈 Overall Results:" -ForegroundColor White
Write-Host "   Total Tests: $totalTests" -ForegroundColor Gray
Write-Host "   Successful: $successfulTests" -ForegroundColor Green
Write-Host "   Partial: $partialTests" -ForegroundColor Yellow  
Write-Host "   Failed: $failedTests" -ForegroundColor Red
Write-Host ""

# Detailed results table
Write-Host "📋 Detailed Results:" -ForegroundColor White
Write-Host "┌─────────────────────────────────┬────────┬────────┬───────┬──────────┐" -ForegroundColor Gray
Write-Host "│ Test Scenario                   │ Before │ After  │ Fixed │ Status   │" -ForegroundColor Gray  
Write-Host "├─────────────────────────────────┼────────┼────────┼───────┼──────────┤" -ForegroundColor Gray

foreach ($result in $testResults) {
    $scenarioName = $result.Name.PadRight(31)
    $before = $result.BeforeViolations.ToString().PadLeft(6)
    $after = $result.AfterViolations.ToString().PadLeft(6)
    $fixed = ($result.BeforeViolations - $result.AfterViolations).ToString().PadLeft(5)
    $status = $result.Status.PadRight(8)
    
    $color = switch ($result.Status) {
        "✅ SUCCESS" { "Green" }
        "⚠️ PARTIAL" { "Yellow" }
        "❌ FAILED" { "Red" }
        default { "Gray" }
    }
    
    Write-Host "│ $scenarioName │ $before │ $after │ $fixed │ $status │" -ForegroundColor $color
}

Write-Host "└─────────────────────────────────┴────────┴────────┴───────┴──────────┘" -ForegroundColor Gray
Write-Host ""

# Performance metrics
$endTime = Get-Date
$duration = $endTime - $startTime
Write-Host "⏱️  Total execution time: $($duration.TotalSeconds.ToString('F2')) seconds" -ForegroundColor Gray

# Generate detailed report if requested
if ($GenerateReport) {
    $reportFile = "TEST_VALIDATION_REPORT_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
    
    $reportHeader = "# Power App Validation & Fix Test Report`n`n"
    $reportHeader += "**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
    $reportHeader += "**Test Path:** $TestPath`n" 
    $reportHeader += "**Duration:** $($duration.TotalSeconds.ToString('F2')) seconds`n`n"
    $reportHeader += "## Summary`n`n"
    $reportHeader += "- **Total Tests:** $totalTests`n"
    $reportHeader += "- **Successful:** $successfulTests`n"
    $reportHeader += "- **Partial:** $partialTests`n"
    $reportHeader += "- **Failed:** $failedTests`n"
    $reportHeader += "- **Success Rate:** $(($successfulTests / $totalTests * 100).ToString('F1'))%`n`n"
    $reportHeader += "## Test Results`n`n"
    
    $reportContent = $reportHeader
    
    foreach ($result in $testResults) {
        $reportContent += "### $($result.Name)`n`n"
        $reportContent += "- **Test File:** ``$($result.TestFile)```n"
        $reportContent += "- **Validation Script:** ``$($result.ValidationScript)```n"
        $reportContent += "- **Fix Script:** ``$($result.FixScript)```n"
        $reportContent += "- **Before Violations:** $($result.BeforeViolations)`n"
        $reportContent += "- **After Violations:** $($result.AfterViolations)`n"
        $reportContent += "- **Fixes Applied:** $($result.FixesApplied)`n"
        $reportContent += "- **Status:** $($result.Status)`n`n"
        
        if ($result.Errors.Count -gt 0) {
            $reportContent += "**Errors:**`n"
            foreach ($error in $result.Errors) {
                $reportContent += "- $error`n"
            }
            $reportContent += "`n"
        }
    }
    
    Set-Content -Path $reportFile -Value $reportContent -Encoding UTF8
    Write-Host "📄 Detailed report generated: $reportFile" -ForegroundColor Green
}

# Exit with appropriate code
if ($failedTests -gt 0) {
    exit 1
} else {
    exit 0
} 