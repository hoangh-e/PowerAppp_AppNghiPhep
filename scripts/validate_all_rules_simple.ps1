# Simple Master PowerShell Script to validate Power App Rules
# Usage: .\validate_all_rules_simple.ps1

param(
    [string]$SourcePath = "src"
)

Write-Host "POWER APP RULES - VALIDATION STARTING" -ForegroundColor Green
Write-Host "Source Path: $SourcePath" -ForegroundColor Yellow
Write-Host ""

$totalErrors = 0
$executedScripts = 0
$failedScripts = 0

function Execute-ValidationScript {
    param(
        [string]$ScriptName,
        [string]$Description
    )
    
    $script:executedScripts++
    
    Write-Host "[$script:executedScripts] Checking: $Description" -ForegroundColor Cyan
    Write-Host "    Script: $ScriptName" -ForegroundColor Gray
    
    $scriptPath = Join-Path $PSScriptRoot $ScriptName
    
    if (-not (Test-Path $scriptPath)) {
        Write-Host "    ERROR: Script not found: $scriptPath" -ForegroundColor Red
        $script:failedScripts++
        return $false
    }
    
    try {
        $exitCode = & $scriptPath -SourcePath $SourcePath
        
        if ($exitCode -eq 0) {
            Write-Host "    PASSED" -ForegroundColor Green
        } else {
            Write-Host "    FAILED (Exit Code: $exitCode)" -ForegroundColor Red
            $script:failedScripts++
        }
        
        return $true
        
    } catch {
        Write-Host "    EXCEPTION: $($_.Exception.Message)" -ForegroundColor Red
        $script:failedScripts++
        return $false
    }
}

# Phase 1: CRITICAL Scripts
Write-Host "PHASE 1: CRITICAL VALIDATIONS" -ForegroundColor White -BackgroundColor Red

$phase1Scripts = @(
    @{ Name = "check_component_definitions.ps1"; Description = "Component Definition Structure" },
    @{ Name = "check_yaml_syntax.ps1"; Description = "YAML Syntax Validation" },
    @{ Name = "check_valid_icons.ps1"; Description = "Valid Icon References" },
    @{ Name = "check_textmode_violations.ps1"; Description = "TextMode Property Violations" }
)

foreach ($script in $phase1Scripts) {
    Execute-ValidationScript -ScriptName $script.Name -Description $script.Description
    Write-Host ""
}

# Phase 2: MORE CRITICAL Scripts
Write-Host "PHASE 2: MORE CRITICAL VALIDATIONS" -ForegroundColor White -BackgroundColor Red

$phase2Scripts = @(
    @{ Name = "check_text_formatting.ps1"; Description = "Text Concatenation Formatting" },
    @{ Name = "check_control_references.ps1"; Description = "Control Name References" },
    @{ Name = "check_component_controls.ps1"; Description = "Component Control Usage" },
    @{ Name = "check_missing_properties.ps1"; Description = "Required Properties Validation" }
)

foreach ($script in $phase2Scripts) {
    Execute-ValidationScript -ScriptName $script.Name -Description $script.Description
    Write-Host ""
}

# Phase 3: HIGH Priority Scripts
Write-Host "PHASE 3: HIGH PRIORITY VALIDATIONS" -ForegroundColor White -BackgroundColor DarkRed

$phase3Scripts = @(
    @{ Name = "check_button_properties.ps1"; Description = "Button Properties Validation" },
    @{ Name = "check_rectangle_properties.ps1"; Description = "Rectangle Properties Validation" },
    @{ Name = "check_rgba_functions.ps1"; Description = "RGBA Functions Validation" }
)

foreach ($script in $phase3Scripts) {
    Execute-ValidationScript -ScriptName $script.Name -Description $script.Description
    Write-Host ""
}

# Summary
Write-Host "VALIDATION SUMMARY" -ForegroundColor White -BackgroundColor Blue
Write-Host "Total Scripts Executed: $executedScripts" -ForegroundColor Yellow
Write-Host "Scripts Passed: $($executedScripts - $failedScripts)" -ForegroundColor Green
Write-Host "Scripts Failed: $failedScripts" -ForegroundColor Red

if ($failedScripts -eq 0) {
    Write-Host "ALL VALIDATIONS PASSED!" -ForegroundColor Green -BackgroundColor Black
    exit 0
} else {
    Write-Host "VALIDATIONS FAILED! $failedScripts out of $executedScripts scripts failed." -ForegroundColor Red -BackgroundColor Black
    exit 1
} 