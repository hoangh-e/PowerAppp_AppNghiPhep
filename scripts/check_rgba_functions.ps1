# ====================================================================
# POWER APP VALIDATION SCRIPT
# Script: check_rgba_functions.ps1
# Purpose: Validate RGBA function usage (Rules 8.18, 5.1)
# Author: AI Assistant
# Date: 2024-12-19
# Version: 1.0.0
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$OutputFile = "src/RGBA_FUNCTIONS_VIOLATIONS.md"
)

Write-Host "KIEM TRA RGBA FUNCTIONS VIOLATIONS" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

$totalFiles = 0
$totalViolations = 0
$results = @()

function Test-RGBAFunctions {
    param([string]$FilePath)
    
    $violations = @()
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    
    $lineNumber = 0
    foreach ($line in $lines) {
        $lineNumber++
        
        # Check for Text(RGBA(...)) violations
        if ($line -match "Text\s*\(\s*RGBA\s*\(") {
            $violations += "CRITICAL: Line $lineNumber - Text() with RGBA values: '$($line.Trim())'"
        }
        
        # Check for Concatenate with Text(RGBA(...))
        if ($line -match "Concatenate.*Text\s*\(\s*RGBA\s*\(") {
            $violations += "CRITICAL: Line $lineNumber - Concatenate with Text(RGBA): '$($line.Trim())'"
        }
        
        # Check for invalid RGBA parameter counts
        if ($line -match "RGBA\s*\([^)]*\)") {
            $rgbaMatch = $matches[0]
            $params = $rgbaMatch -replace "RGBA\s*\(\s*", "" -replace "\s*\)", ""
            $paramCount = ($params -split ",").Count
            
            if ($paramCount -ne 4) {
                $violations += "HIGH: Line $lineNumber - RGBA needs exactly 4 parameters (found $paramCount): '$($line.Trim())'"
            }
        }
    }
    
    return $violations
}

# Get all YAML files
$yamlFiles = Get-ChildItem -Path $SourcePath -Recurse -Include "*.yaml", "*.yml" | Where-Object { !$_.PSIsContainer }

if ($yamlFiles.Count -eq 0) {
    Write-Host "WARNING: No YAML files found in '$SourcePath'" -ForegroundColor Yellow
    exit 0
}

Write-Host "Tim thay $($yamlFiles.Count) YAML files" -ForegroundColor Yellow

foreach ($file in $yamlFiles) {
    $totalFiles++
    
    Write-Host "Checking: $($file.Name)" -ForegroundColor White
    
    $violations = Test-RGBAFunctions -FilePath $file.FullName
    
    if ($violations.Count -gt 0) {
        Write-Host "  FAIL: $($violations.Count) vi pham phat hien" -ForegroundColor Red
        foreach ($violation in $violations) {
            Write-Host "    - $violation" -ForegroundColor Red
        }
        
        $results += [PSCustomObject]@{
            File = $file.FullName
            ViolationCount = $violations.Count
            Violations = $violations
        }
        
        $totalViolations += $violations.Count
    } else {
        Write-Host "  PASS: Khong co vi pham" -ForegroundColor Green
    }
}

# Create detailed report
$report = "# RGBA FUNCTIONS VIOLATIONS REPORT" + "`n`n"
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
}

# Write report to file
$report | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "`nReport saved to: $OutputFile" -ForegroundColor Green
Write-Host "`nTONG KET:" -ForegroundColor Cyan
Write-Host "   Files kiem tra: $totalFiles" -ForegroundColor Yellow
Write-Host "   Vi pham phat hien: $totalViolations" -ForegroundColor $(if($totalViolations -gt 0) { "Red" } else { "Green" })
Write-Host "   Ti le tuan thu: $([math]::Round((($totalFiles - $results.Count) / $totalFiles) * 100, 2))%" -ForegroundColor $(if($totalViolations -gt 0) { "Red" } else { "Green" })

if ($totalViolations -gt 0) {
    Write-Host "`nCo $totalViolations vi pham can sua ngay lap tuc!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nTat ca files tuan thu RGBA function rules!" -ForegroundColor Green
    exit 0
} 