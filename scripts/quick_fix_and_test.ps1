# Quick test script to identify which validation scripts are working
Write-Host "TESTING ALL VALIDATION SCRIPTS" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

$workingScripts = @()
$brokenScripts = @()

$allScripts = @(
    "validate_power_app_rules.ps1",
    "check_valid_icons.ps1", 
    "check_textmode_violations.ps1",
    "fix_multiline_formulas.ps1",
    "fix_self_properties.ps1",
    "remove_invalid_properties.ps1",
    "check_component_definitions.ps1",
    "check_yaml_syntax.ps1",
    "check_text_formatting.ps1",
    "check_button_properties.ps1",
    "check_control_references.ps1",
    "check_component_controls.ps1",
    "check_missing_properties.ps1",
    "check_rectangle_properties.ps1",
    "check_rgba_functions.ps1",
    "check_fixed_numbers.ps1",
    "check_absolute_positioning.ps1"
)

foreach ($script in $allScripts) {
    Write-Host "`nTesting: $script" -ForegroundColor Yellow
    
    try {
        $result = powershell -ExecutionPolicy Bypass -File "scripts/$script" -SourcePath "src" -ErrorAction Stop
        if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 1) {
            Write-Host "  WORKING" -ForegroundColor Green
            $workingScripts += $script
        } else {
            Write-Host "  SYNTAX ERROR" -ForegroundColor Red
            $brokenScripts += $script
        }
    }
    catch {
        Write-Host "  BROKEN: $($_.Exception.Message)" -ForegroundColor Red
        $brokenScripts += $script
    }
}

Write-Host "`n=== RESULTS ===" -ForegroundColor Cyan
Write-Host "Working Scripts ($($workingScripts.Count)):" -ForegroundColor Green
foreach ($script in $workingScripts) {
    Write-Host "  + $script" -ForegroundColor Green
}

Write-Host "`nBroken Scripts ($($brokenScripts.Count)):" -ForegroundColor Red
foreach ($script in $brokenScripts) {
    Write-Host "  - $script" -ForegroundColor Red
} 