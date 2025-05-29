# Simple PowerShell Script to test basic validations
# Usage: .\test_simple_validation.ps1

param(
    [string]$SourcePath = "src"
)

Write-Host "🔍 TEST SIMPLE VALIDATIONS" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan

$totalFiles = 0
$totalViolations = 0

# Get all YAML files
$yamlFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.yaml"

Write-Host "📁 Found $($yamlFiles.Count) YAML files" -ForegroundColor Yellow

foreach ($file in $yamlFiles) {
    $totalFiles++
    Write-Host "Checking: $($file.Name)" -ForegroundColor Yellow
    
    $content = Get-Content $file.FullName -Raw
    $lines = Get-Content $file.FullName
    $violations = @()
    
    # Check 1: Absolute positioning
    foreach ($line in $lines) {
        if ($line -match "^\s*[XY]:\s*\d+\s*$") {
            $violations += "Absolute positioning: $($line.Trim())"
        }
        if ($line -match "^\s*(Width|Height):\s*\d+\s*$") {
            $violations += "Absolute sizing: $($line.Trim())"
        }
    }
    
    # Check 2: Component definition structure
    if ($content -match "ComponentDefinition:\s*\n" -and $content -notmatch "ComponentDefinitions:") {
        $violations += "Old ComponentDefinition syntax"
    }
    
    # Check 3: TextMode violations
    if ($content -match "TextMode:\s*=") {
        $violations += "TextMode property should be Mode for Classic/TextInput"
    }
    
    if ($violations.Count -gt 0) {
        $totalViolations += $violations.Count
        Write-Host "  ❌ $($violations.Count) violations found" -ForegroundColor Red
        foreach ($violation in $violations) {
            Write-Host "    - $violation" -ForegroundColor Red
        }
    } else {
        Write-Host "  ✅ No violations" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "📊 SUMMARY:" -ForegroundColor Cyan
Write-Host "   Files checked: $totalFiles" -ForegroundColor Yellow
Write-Host "   Violations found: $totalViolations" -ForegroundColor $(if($totalViolations -gt 0) { "Red" } else { "Green" })

if ($totalViolations -gt 0) {
    Write-Host "⚠️  Found $totalViolations violations that need fixing!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ All files passed validation!" -ForegroundColor Green
    exit 0
} 