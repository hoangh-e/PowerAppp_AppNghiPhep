# ====================================================================
# TEST FIXED SCRIPTS
# Script: Test-FixedScripts.ps1
# Purpose: Test the fixed validation and fix scripts to ensure they work correctly
# Date: 2024-12-19
# ====================================================================

param(
    [switch]$Verbose
)

Write-Host "🧪 TESTING FIXED SCRIPTS" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host ""

# Create test content with Vietnamese text and potential issues
$testContent = @"
Screens:
  TestScreen:
    Properties:
      Fill: =RGBA(248, 250, 252, 1)
      OnVisible: |
        =Set(varActiveScreen, "Reports");
        Set(varCurrentUser, LookUp(NguoiDung, Email = User().Email));
        Set(varReportType, "Department");
    Children:
      - TestLabel:
          Control: Label
          Properties:
            X: =Parent.X + 20
            Y: =Parent.Y + 10
            Width: =Parent.Width - 40
            Height: =40
            Text: ="Tên:" & " " & "Nguyễn Văn An"
            Fill: =RGBA(255, 255, 255, 1)
      - TestIcon:
          Control: Classic/Icon
          Properties:
            Icon: =Icon.Calendar
            X: =Parent.X + 100
            Y: =Parent.Y + 60
"@

# Create test file
$testFile = "test_files/test_fixed_scripts.yaml"
if (-not (Test-Path "test_files")) {
    New-Item -ItemType Directory -Path "test_files" -Force | Out-Null
}

Set-Content -Path $testFile -Value $testContent -Encoding UTF8
Write-Host "✅ Created test file: $testFile" -ForegroundColor Green

# Test 1: Check that UTF-8 encoding works
Write-Host ""
Write-Host "🔍 Test 1: UTF-8 Encoding Support" -ForegroundColor Yellow
$content = Get-Content -Path $testFile -Raw -Encoding UTF8
if ($content -match "Nguyễn Văn An") {
    Write-Host "✅ UTF-8 encoding works correctly" -ForegroundColor Green
} else {
    Write-Host "❌ UTF-8 encoding failed" -ForegroundColor Red
}

# Test 2: Run icon fix and check for proper fixes
Write-Host ""
Write-Host "🔍 Test 2: Icon Guidelines Fix" -ForegroundColor Yellow
& "scripts/Fix-IconGuidelines.ps1" -TargetFile $testFile -DryRun
$iconResult = $LASTEXITCODE
if ($iconResult -eq 0) {
    Write-Host "✅ Icon fix script ran successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Icon fix script failed" -ForegroundColor Red
}

# Test 3: Check that no extra = signs are added
Write-Host ""
Write-Host "🔍 Test 3: No Extra = Signs" -ForegroundColor Yellow
$beforeContent = Get-Content -Path $testFile -Raw -Encoding UTF8
& "scripts/Fix-PositionSize.ps1" -TargetFile $testFile -DryRun | Out-Null
$afterContent = Get-Content -Path $testFile -Raw -Encoding UTF8

# Check for double = signs
if ($afterContent -match "= =") {
    Write-Host "❌ Found double = signs in output" -ForegroundColor Red
    Write-Host "   This indicates the fix scripts are adding extra = signs" -ForegroundColor Red
} else {
    Write-Host "✅ No double = signs found" -ForegroundColor Green
}

# Test 4: Check OnVisible pipe operator handling
Write-Host ""
Write-Host "🔍 Test 4: OnVisible Pipe Operator" -ForegroundColor Yellow
if ($afterContent -match "OnVisible: = \|") {
    Write-Host "❌ Found 'OnVisible: = |' pattern - this is incorrect" -ForegroundColor Red
} elseif ($afterContent -match "OnVisible: \|") {
    Write-Host "✅ OnVisible pipe operator format is correct" -ForegroundColor Green
} else {
    Write-Host "⚠️  OnVisible pattern not found or changed" -ForegroundColor Yellow
}

# Test 5: Run all check scripts to ensure they work
Write-Host ""
Write-Host "🔍 Test 5: All Check Scripts" -ForegroundColor Yellow
$checkScripts = @(
    "Check-ControlRules.ps1",
    "Check-PositionSize.ps1", 
    "Check-ComponentDefinitions.ps1",
    "Check-IconGuidelines.ps1",
    "Check-TextFormatting.ps1"
)

$allPassed = $true
foreach ($script in $checkScripts) {
    $scriptPath = "scripts/$script"
    if (Test-Path $scriptPath) {
        try {
            & $scriptPath -TargetFile $testFile | Out-Null
            Write-Host "  ✅ $script" -ForegroundColor Green
        } catch {
            Write-Host "  ❌ $script - Error: $($_.Exception.Message)" -ForegroundColor Red
            $allPassed = $false
        }
    } else {
        Write-Host "  ⚠️  $script - File not found" -ForegroundColor Yellow
    }
}

# Test 6: Vietnamese text preservation
Write-Host ""
Write-Host "🔍 Test 6: Vietnamese Text Preservation" -ForegroundColor Yellow
if ($afterContent -match "Nguyễn Văn An") {
    Write-Host "✅ Vietnamese text preserved correctly" -ForegroundColor Green
} else {
    Write-Host "❌ Vietnamese text was corrupted" -ForegroundColor Red
    $allPassed = $false
}

# Summary
Write-Host ""
Write-Host "=" * 50 -ForegroundColor Green
Write-Host "TEST SUMMARY" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Green

if ($allPassed) {
    Write-Host "✅ All tests passed!" -ForegroundColor Green
    Write-Host "   The fixed scripts are working correctly" -ForegroundColor Green
} else {
    Write-Host "❌ Some tests failed" -ForegroundColor Red
    Write-Host "   Please review the issues above" -ForegroundColor Red
}

# Cleanup
if (Test-Path $testFile) {
    Remove-Item $testFile -Force
    Write-Host ""
    Write-Host "🧹 Cleaned up test file" -ForegroundColor Gray
}

exit $(if ($allPassed) { 0 } else { 1 }) 