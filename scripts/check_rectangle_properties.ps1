# ====================================================================
# POWER APP VALIDATION SCRIPT
# Script: check_rectangle_properties.ps1
# Purpose: Validate rectangle control properties (Rules 8.15, 2.4)
# Author: AI Assistant
# Date: 2024-12-19
# Version: 1.0.0
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$OutputFile = "src/RECTANGLE_PROPERTIES_VIOLATIONS.md"
)

Write-Host "KIEM TRA RECTANGLE PROPERTIES VIOLATIONS" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$totalFiles = 0
$totalViolations = 0
$results = @()

function Test-RectangleProperties {
    param([string]$FilePath)
    
    $violations = @()
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    
    $lineNumber = 0
    $inRectangleControl = $false
    
    foreach ($line in $lines) {
        $lineNumber++
        
        # Check if we're entering a Rectangle control
        if ($line -match "Control:\s*Rectangle") {
            $inRectangleControl = $true
            continue
        }
        
        # Check if we're leaving the control
        if ($inRectangleControl -and $line -match "^\s*-\s*" -and $line -notmatch "^\s*-\s*\w+:") {
            $inRectangleControl = $false
        }
        
        # Check for invalid radius properties
        if ($inRectangleControl) {
            if ($line -match "RadiusBottomLeft\s*:") {
                $violations += "HIGH: Line $lineNumber - RadiusBottomLeft not supported for Rectangle: '$($line.Trim())'"
            }
            if ($line -match "RadiusBottomRight\s*:") {
                $violations += "HIGH: Line $lineNumber - RadiusBottomRight not supported for Rectangle: '$($line.Trim())'"
            }
            if ($line -match "RadiusTopLeft\s*:") {
                $violations += "HIGH: Line $lineNumber - RadiusTopLeft not supported for Rectangle: '$($line.Trim())'"
            }
            if ($line -match "RadiusTopRight\s*:") {
                $violations += "HIGH: Line $lineNumber - RadiusTopRight not supported for Rectangle: '$($line.Trim())'"
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
    
    $violations = Test-RectangleProperties -FilePath $file.FullName
    
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
$report = "# RECTANGLE PROPERTIES VIOLATIONS REPORT" + "`n`n"
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
    Write-Host "`nTat ca files tuan thu Rectangle Properties rules!" -ForegroundColor Green
    exit 0
} 