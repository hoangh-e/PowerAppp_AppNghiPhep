# Simple test for fixed scripts
param([switch]$Verbose)

# Set console encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "Testing Fixed Scripts..." -ForegroundColor Green

# Create test content
$testContent = @"
Screens:
  TestScreen:
    Properties:
      Fill: =RGBA(248, 250, 252, 1)
      OnVisible: |
        =Set(varActiveScreen, "Reports");
    Children:
      - TestLabel:
          Control: Label
          Properties:
            X: =Parent.X + 20
            Y: =Parent.Y + 10
            Width: =Parent.Width - 40
            Height: =40
            Text: ="Ten:" & " " & "Nguyen Van An"
      - TestIcon:
          Control: Classic/Icon
          Properties:
            Icon: =Icon.Calendar
"@

# Create test file
$testFile = "test_files/simple_test.yaml"
if (-not (Test-Path "test_files")) {
    New-Item -ItemType Directory -Path "test_files" -Force | Out-Null
}

Set-Content -Path $testFile -Value $testContent -Encoding UTF8

# Test 1: Check Icon fix
Write-Host "Test 1: Icon Fix" -ForegroundColor Yellow
$beforeIcon = Get-Content -Path $testFile -Raw -Encoding UTF8
& "scripts/Fix-IconGuidelines.ps1" -TargetFile $testFile -DryRun | Out-Null
$afterIcon = Get-Content -Path $testFile -Raw -Encoding UTF8

if ($beforeIcon -eq $afterIcon) {
    Write-Host "  PASS: No unwanted changes" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Unexpected changes" -ForegroundColor Red
}

# Test 2: Check Position fix doesn't add extra =
Write-Host "Test 2: Position Fix" -ForegroundColor Yellow
$beforePos = Get-Content -Path $testFile -Raw -Encoding UTF8
& "scripts/Fix-PositionSize.ps1" -TargetFile $testFile -DryRun | Out-Null
$afterPos = Get-Content -Path $testFile -Raw -Encoding UTF8

if ($afterPos -match "= =") {
    Write-Host "  FAIL: Found double = signs" -ForegroundColor Red
} else {
    Write-Host "  PASS: No double = signs" -ForegroundColor Green
}

# Test 3: Check OnVisible format
Write-Host "Test 3: OnVisible Format" -ForegroundColor Yellow
if ($afterPos -match "OnVisible: = \|") {
    Write-Host "  FAIL: Incorrect OnVisible format" -ForegroundColor Red
} elseif ($afterPos -match "OnVisible: \|") {
    Write-Host "  PASS: Correct OnVisible format" -ForegroundColor Green
} else {
    Write-Host "  UNKNOWN: OnVisible pattern changed" -ForegroundColor Yellow
}

# Cleanup
Remove-Item $testFile -Force -ErrorAction SilentlyContinue

Write-Host "Test completed." -ForegroundColor Green 