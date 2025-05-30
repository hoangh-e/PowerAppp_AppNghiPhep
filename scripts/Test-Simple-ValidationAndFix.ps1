# Simple Test for Validation and Fix Scripts
param([string]$TestPath = "test_files")

Write-Host "🧪 SIMPLE VALIDATION TEST" -ForegroundColor Magenta
Write-Host "=========================" -ForegroundColor Magenta
Write-Host ""

# Test Icon Guidelines
Write-Host "📋 Testing Icon Guidelines..." -ForegroundColor Cyan

if (Test-Path "Check-IconGuidelines.ps1") {
    Write-Host "  🔍 Running validation..." -ForegroundColor Yellow
    $beforeResult = & ".\Check-IconGuidelines.ps1" -SourcePath $TestPath
    Write-Host "  Before validation completed" -ForegroundColor Gray
    
    Write-Host "  🔧 Running fix..." -ForegroundColor Yellow
    $fixResult = & ".\Fix-IconGuidelines.ps1" -SourcePath $TestPath
    Write-Host "  Fix completed" -ForegroundColor Gray
    
    Write-Host "  🔍 Running validation again..." -ForegroundColor Yellow
    $afterResult = & ".\Check-IconGuidelines.ps1" -SourcePath $TestPath
    Write-Host "  After validation completed" -ForegroundColor Gray
} else {
    Write-Host "  ❌ Check-IconGuidelines.ps1 not found" -ForegroundColor Red
}

Write-Host ""

# Test Component Definitions
Write-Host "📋 Testing Component Definitions..." -ForegroundColor Cyan

if (Test-Path "Check-ComponentDefinitions.ps1") {
    Write-Host "  🔍 Running validation..." -ForegroundColor Yellow
    $compBeforeResult = & ".\Check-ComponentDefinitions.ps1" -SourcePath $TestPath
    Write-Host "  Before validation completed" -ForegroundColor Gray
    
    Write-Host "  🔧 Running fix..." -ForegroundColor Yellow
    $compFixResult = & ".\Fix-ComponentDefinitions.ps1" -SourcePath $TestPath
    Write-Host "  Fix completed" -ForegroundColor Gray
    
    Write-Host "  🔍 Running validation again..." -ForegroundColor Yellow
    $compAfterResult = & ".\Check-ComponentDefinitions.ps1" -SourcePath $TestPath
    Write-Host "  After validation completed" -ForegroundColor Gray
} else {
    Write-Host "  ❌ Check-ComponentDefinitions.ps1 not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "✅ Test completed!" -ForegroundColor Green
Write-Host "💡 Check the output above for results" -ForegroundColor Yellow

exit 0 