# ====================================================================
# POWER APP VALIDATION SCRIPT
# Script: check_button_properties.ps1
# Purpose: Validate button control properties (Rules 8.14, 2.4)
# Author: AI Assistant
# Date: 2024-12-19
# Version: 1.0.0
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$OutputFile = "src/BUTTON_PROPERTIES_VIOLATIONS.md"
)

Write-Host "KIEM TRA BUTTON PROPERTIES VIOLATIONS" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$totalFiles = 0
$totalViolations = 0
$results = @()

function Test-ButtonProperties {
    param([string]$FilePath)
    
    $violations = @()
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    
    $lineNumber = 0
    foreach ($line in $lines) {
        $lineNumber++
        
        # Check if this is a Classic/Button control
        if ($line -match "Control:\s*Classic/Button") {
            # Look for invalid properties in following lines
            $nextLines = $lines[$lineNumber..($lines.Count-1)]
            $inButtonProperties = $false
            
            foreach ($nextLine in $nextLines) {
                if ($nextLine -match "^\s*Properties:") {
                    $inButtonProperties = $true
                    continue
                }
                
                if ($inButtonProperties) {
                    # Stop if we encounter another control
                    if ($nextLine -match "^\s*-\s*\w+:" -or $nextLine -match "^[A-Za-z]") {
                        break
                    }
                    
                    # Check for invalid properties
                    if ($nextLine -match "^\s*BorderRadius:") {
                        $violations += "CRITICAL: Line $($lineNumber + $nextLines.IndexOf($nextLine) + 1) - BorderRadius not supported for Classic/Button"
                    }
                    
                    if ($nextLine -match "^\s*Disabled:") {
                        $violations += "CRITICAL: Line $($lineNumber + $nextLines.IndexOf($nextLine) + 1) - Use DisplayMode instead of Disabled for Classic/Button"
                    }
                    
                    if ($nextLine -match "^\s*Align:") {
                        $violations += "CRITICAL: Line $($lineNumber + $nextLines.IndexOf($nextLine) + 1) - Align not supported for Classic/Button"
                    }
                }
            }
        }
    }
    
    return $violations
}

# Get all YAML files
$yamlFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.yaml"

Write-Host "Tim thay $($yamlFiles.Count) YAML files" -ForegroundColor Yellow

foreach ($file in $yamlFiles) {
    $totalFiles++
    Write-Host "Kiem tra: $($file.Name)" -ForegroundColor Yellow
    
    $violations = Test-ButtonProperties -FilePath $file.FullName
    
    if ($violations.Count -gt 0) {
        $totalViolations += $violations.Count
        $results += [PSCustomObject]@{
            File = $file.FullName.Replace((Get-Location).Path + "\", "")
            ViolationCount = $violations.Count
            Violations = $violations
        }
        
        Write-Host "  FAIL: $($violations.Count) vi pham phat hien" -ForegroundColor Red
    } else {
        Write-Host "  PASS: Khong co vi pham" -ForegroundColor Green
    }
}

# Create detailed report
$report = "# BUTTON PROPERTIES VIOLATIONS REPORT" + "`n`n"
$report += "**Thoi gian:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" + "`n"
$report += "**Tong files kiem tra:** $totalFiles" + "`n"
$report += "**Tong vi pham phat hien:** $totalViolations" + "`n`n"

if ($results.Count -gt 0) {
    $report += "## CHI TIET VI PHAM" + "`n`n"
    
    foreach ($result in $results) {
        $report += "### $($result.File)" + "`n"
        $report += "**So vi pham:** $($result.ViolationCount)" + "`n`n"
        
        foreach ($violation in $result.Violations) {
            $report += "- $violation" + "`n"
        }
        $report += "`n"
    }
} else {
    $report += "## KET QUA" + "`n`n"
    $report += "**Tat ca files tuan thu Button Properties rules!**" + "`n`n"
}

# Write report to file
$report | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "`nReport saved to: $OutputFile" -ForegroundColor Green
Write-Host "`nTONG KET:" -ForegroundColor Cyan
Write-Host "   Files kiem tra: $totalFiles" -ForegroundColor Yellow
Write-Host "   Vi pham phat hien: $totalViolations" -ForegroundColor $(if($totalViolations -gt 0) { "Red" } else { "Green" })

if ($totalViolations -gt 0) {
    Write-Host "`nCo $totalViolations vi pham Button Properties can sua!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nTat ca files tuan thu Button Properties rules!" -ForegroundColor Green
    exit 0
}