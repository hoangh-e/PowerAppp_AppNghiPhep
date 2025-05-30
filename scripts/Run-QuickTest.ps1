param([string]$TestPath = "test_files")

Write-Host "Quick Test - Validation and Fix" -ForegroundColor Green
Write-Host "Test Path: $TestPath"
Write-Host ""

# Test Icon Guidelines
Write-Host "1. Testing Icon Guidelines..." -ForegroundColor Cyan
if (Test-Path "Check-IconGuidelines.ps1") {
    Write-Host "   Running icon validation..."
    .\Check-IconGuidelines.ps1 -SourcePath $TestPath
    Write-Host "   Running icon fix..."
    .\Fix-IconGuidelines.ps1 -SourcePath $TestPath
    Write-Host "   Running icon validation again..."
    .\Check-IconGuidelines.ps1 -SourcePath $TestPath
} else {
    Write-Host "   Icon validation script not found"
}

Write-Host ""

# Test Component Definitions  
Write-Host "2. Testing Component Definitions..." -ForegroundColor Cyan
if (Test-Path "Check-ComponentDefinitions.ps1") {
    Write-Host "   Running component validation..."
    .\Check-ComponentDefinitions.ps1 -SourcePath $TestPath
    Write-Host "   Running component fix..."
    .\Fix-ComponentDefinitions.ps1 -SourcePath $TestPath
    Write-Host "   Running component validation again..."
    .\Check-ComponentDefinitions.ps1 -SourcePath $TestPath
} else {
    Write-Host "   Component validation script not found"
}

Write-Host ""
Write-Host "Test completed!" -ForegroundColor Green 