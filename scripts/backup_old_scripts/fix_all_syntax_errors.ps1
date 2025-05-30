# Script to fix syntax errors in all validation scripts
# Usage: .\fix_all_syntax_errors.ps1

$scriptsToFix = @(
    "check_control_references.ps1",
    "check_component_controls.ps1", 
    "check_missing_properties.ps1",
    "check_button_properties.ps1",
    "check_rectangle_properties.ps1",
    "check_rgba_functions.ps1",
    "check_fixed_numbers.ps1",
    "check_absolute_positioning.ps1"
)

Write-Host "FIXING SYNTAX ERRORS IN VALIDATION SCRIPTS" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

foreach ($scriptName in $scriptsToFix) {
    $scriptPath = Join-Path $PSScriptRoot $scriptName
    
    if (Test-Path $scriptPath) {
        Write-Host "Fixing: $scriptName" -ForegroundColor Yellow
        
        $content = Get-Content $scriptPath -Raw
        
        # Remove all emoji characters
        $content = $content -replace "🔍", ""
        $content = $content -replace "📁", ""
        $content = $content -replace "❌", ""
        $content = $content -replace "✅", ""
        $content = $content -replace "⚠️", ""
        $content = $content -replace "📄", ""
        $content = $content -replace "📊", ""
        $content = $content -replace "💡", ""
        $content = $content -replace "🚨", ""
        $content = $content -replace "🔴", ""
        $content = $content -replace "🟠", ""
        $content = $content -replace "🟡", ""
        $content = $content -replace "🟢", ""
        $content = $content -replace "🎉", ""
        
        # Fix backtick issues in reports
        $content = $content -replace '`n`n', '" + "`n`n"'
        $content = $content -replace '`n', '" + "`n"'
        $content = $content -replace '\$report \+= "([^"]*)"', '$report += "$1" + "`n"'
        
        # Save fixed content
        Set-Content -Path $scriptPath -Value $content -Encoding UTF8
        
        Write-Host "  Fixed!" -ForegroundColor Green
    } else {
        Write-Host "  Script not found: $scriptPath" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "All syntax fixes completed!" -ForegroundColor Green 