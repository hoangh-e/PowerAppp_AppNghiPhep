# PowerShell Script to check Absolute Positioning violations
# Usage: .\check_absolute_positioning.ps1

param(
    [string]$SourcePath = "src",
    [string]$OutputFile = "src/ABSOLUTE_POSITIONING_VIOLATIONS.md"
)

Write-Host "🔍 KIEM TRA ABSOLUTE POSITIONING VIOLATIONS" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

$totalFiles = 0
$totalViolations = 0
$results = @()

function Test-AbsolutePositioning {
    param([string]$FilePath)
    
    $violations = @()
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    
    $lineNumber = 0
    foreach ($line in $lines) {
        $lineNumber++
        
        # 1. Check for absolute X positioning (pure numbers)
        if ($line -match "^\s*X:\s*\d+\s*$") {
            $violations += "CRITICAL: Line $lineNumber - Absolute X positioning: '$($line.Trim())' (Section 3.2)"
        }
        
        # 2. Check for absolute Y positioning
        if ($line -match "^\s*Y:\s*\d+\s*$") {
            $violations += "CRITICAL: Line $lineNumber - Absolute Y positioning: '$($line.Trim())' (Section 3.2)"
        }
        
        # 3. Check for absolute Width
        if ($line -match "^\s*Width:\s*\d+\s*$") {
            $violations += "CRITICAL: Line $lineNumber - Absolute Width: '$($line.Trim())' (Section 3.1)"
        }
        
        # 4. Check for absolute Height
        if ($line -match "^\s*Height:\s*\d+\s*$") {
            $violations += "CRITICAL: Line $lineNumber - Absolute Height: '$($line.Trim())' (Section 3.1)"
        }
        
        # 5. Check for absolute values with equals sign (still wrong)
        if ($line -match "^\s*[XY]:\s*=\s*\d+\s*$") {
            $violations += "HIGH: Line $lineNumber - Absolute positioning with equals: '$($line.Trim())' (Section 3.2)"
        }
        
        if ($line -match "^\s*(Width|Height):\s*=\s*\d+\s*$") {
            $violations += "HIGH: Line $lineNumber - Absolute sizing with equals: '$($line.Trim())' (Section 3.1)"
        }
        
        # 6. Check for screen-level absolute positioning (might be OK for screens)
        if ($line -match "^\s*[XY]:\s*=?\s*\d+" -and $content -match "Screens:") {
            # This might be acceptable for screen-level controls, but warn anyway
            $violations += "WARNING: Line $lineNumber - Screen-level absolute positioning: '$($line.Trim())' (Consider relative positioning)"
        }
        
        # 7. Check for missing relative references
        if ($line -match "^\s*[XY]:\s*=\s*[^P]" -and $line -notmatch "Parent\." -and $line -notmatch "Self\." -and $line -notmatch "\w+\.(X|Y|Width|Height)") {
            $violations += "MEDIUM: Line $lineNumber - Positioning without Parent/Self/Control reference: '$($line.Trim())'"
        }
        
        if ($line -match "^\s*(Width|Height):\s*=\s*[^P]" -and $line -notmatch "Parent\." -and $line -notmatch "Self\." -and $line -notmatch "\w+\.(Width|Height)") {
            $violations += "MEDIUM: Line $lineNumber - Sizing without Parent/Self/Control reference: '$($line.Trim())'"
        }
    }
    
    return $violations
}

# Get all YAML files
$yamlFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.yaml"

Write-Host "📁 Tim thay $($yamlFiles.Count) YAML files" -ForegroundColor Yellow

foreach ($file in $yamlFiles) {
    $totalFiles++
    Write-Host "Kiem tra: $($file.Name)" -ForegroundColor Yellow
    
    $violations = Test-AbsolutePositioning -FilePath $file.FullName
    
    if ($violations.Count -gt 0) {
        $totalViolations += $violations.Count
        $results += [PSCustomObject]@{
            File = $file.FullName.Replace((Get-Location).Path + "\", "")
            ViolationCount = $violations.Count
            Violations = $violations
        }
        
        Write-Host "  ❌ $($violations.Count) vi pham phat hien" -ForegroundColor Red
    } else {
        Write-Host "  ✅ Khong co vi pham" -ForegroundColor Green
    }
}

# Create detailed report
$report = "# ABSOLUTE POSITIONING VIOLATIONS REPORT`n`n"
$report += "**Thoi gian:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
$report += "**Tong files kiem tra:** $totalFiles`n"
$report += "**Tong vi pham phat hien:** $totalViolations`n`n"

if ($results.Count -gt 0) {
    $report += "## 🚨 CHI TIET VI PHAM`n`n"
    
    # Group violations by severity
    $criticalFiles = $results | Where-Object { $_.Violations -match "CRITICAL:" }
    $highFiles = $results | Where-Object { $_.Violations -match "HIGH:" }
    $mediumFiles = $results | Where-Object { $_.Violations -match "MEDIUM:" }
    $warningFiles = $results | Where-Object { $_.Violations -match "WARNING:" }
    
    if ($criticalFiles.Count -gt 0) {
        $report += "### 🔴 CRITICAL VIOLATIONS`n`n"
        foreach ($result in $criticalFiles) {
            $report += "#### $($result.File)`n"
            $criticalViolations = $result.Violations | Where-Object { $_ -match "CRITICAL:" }
            foreach ($violation in $criticalViolations) {
                $report += "- $violation`n"
            }
            $report += "`n"
        }
    }
    
    if ($highFiles.Count -gt 0) {
        $report += "### 🟠 HIGH VIOLATIONS`n`n"
        foreach ($result in $highFiles) {
            $report += "#### $($result.File)`n"
            $highViolations = $result.Violations | Where-Object { $_ -match "HIGH:" }
            foreach ($violation in $highViolations) {
                $report += "- $violation`n"
            }
            $report += "`n"
        }
    }
    
    # Add fix examples
    $report += "## ✅ CAC VI DU SUA LOI`n`n"
    
    $report += "### 1. Absolute X/Y Positioning`n"
    $report += "```yaml`n"
    $report += "# ❌ SAI - Absolute positioning`n"
    $report += "X: 100`n"
    $report += "Y: 50`n"
    $report += "X: =100`n"
    $report += "Y: =50`n`n"
    $report += "# ✅ DUNG - Relative positioning`n"
    $report += "X: =Parent.X + 20`n"
    $report += "Y: =HeaderControl.Y + HeaderControl.Height + 10`n"
    $report += "X: =(Parent.Width - Self.Width) / 2  # Center horizontally`n"
    $report += "Y: =Parent.Height - Self.Height      # Bottom alignment`n"
    $report += "```n`n"
    
    $report += "### 2. Absolute Width/Height`n"
    $report += "```yaml`n"
    $report += "# ❌ SAI - Absolute sizing`n"
    $report += "Width: 300`n"
    $report += "Height: 200`n"
    $report += "Width: =300`n"
    $report += "Height: =200`n`n"
    $report += "# ✅ DUNG - Relative sizing`n"
    $report += "Width: =Parent.Width * 0.8`n"
    $report += "Height: =Parent.Height / 3`n"
    $report += "Width: =Parent.Width - 40   # With margins`n"
    $report += "Height: =Self.Width         # Square aspect ratio`n"
    $report += "```n`n"
    
    $report += "### 3. Control References`n"
    $report += "```yaml`n"
    $report += "# ✅ DUNG - Reference other controls`n"
    $report += "X: =PreviousControl.X + PreviousControl.Width + 10`n"
    $report += "Y: =HeaderControl.Y + HeaderControl.Height`n"
    $report += "Width: =SiblingControl.Width`n"
    $report += "Height: =ButtonControl.Height`n"
    $report += "```n`n"
    
} else {
    $report += "## ✅ KET QUA`n`n"
    $report += "**Tat ca files su dung relative positioning dung cach!**`n`n"
}

# Summary
$report += "## 📊 TONG KET`n`n"
$report += "| Metric | Value |`n"
$report += "|--------|-------|`n"
$report += "| Files kiem tra | $totalFiles |`n"
$report += "| Vi pham tim thay | $totalViolations |`n"
$report += "| Files co vi pham | $($results.Count) |`n"

if ($totalFiles -gt 0) {
    $report += "| Ti le tuan thu | $([math]::Round((($totalFiles - $results.Count) / $totalFiles) * 100, 2))% |`n"
}

$report += "`n### Vi pham theo muc do:`n"
$criticalCount = ($results | ForEach-Object { $_.Violations | Where-Object { $_ -match "CRITICAL:" } }).Count
$highCount = ($results | ForEach-Object { $_.Violations | Where-Object { $_ -match "HIGH:" } }).Count
$mediumCount = ($results | ForEach-Object { $_.Violations | Where-Object { $_ -match "MEDIUM:" } }).Count
$warningCount = ($results | ForEach-Object { $_.Violations | Where-Object { $_ -match "WARNING:" } }).Count

$report += "- 🔴 CRITICAL: $criticalCount`n"
$report += "- 🟠 HIGH: $highCount`n"
$report += "- 🟡 MEDIUM: $mediumCount`n"
$report += "- 🟢 WARNING: $warningCount`n`n"

# Write report to file
$report | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "`n📄 Report saved to: $OutputFile" -ForegroundColor Green
Write-Host "`n📊 TONG KET:" -ForegroundColor Cyan
Write-Host "   Files kiem tra: $totalFiles" -ForegroundColor Yellow
Write-Host "   Vi pham phat hien: $totalViolations" -ForegroundColor $(if($totalViolations -gt 0) { "Red" } else { "Green" })

if ($totalFiles -gt 0) {
    Write-Host "   Ti le tuan thu: $([math]::Round((($totalFiles - $results.Count) / $totalFiles) * 100, 2))%" -ForegroundColor $(if($totalViolations -gt 0) { "Red" } else { "Green" })
}

Write-Host "   🔴 CRITICAL: $criticalCount | 🟠 HIGH: $highCount | 🟡 MEDIUM: $mediumCount | 🟢 WARNING: $warningCount" -ForegroundColor White

if ($totalViolations -gt 0) {
    Write-Host "`n⚠️  Co $totalViolations vi pham can sua de tuan thu relative positioning!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`n✅ Tat ca files su dung relative positioning dung cach!" -ForegroundColor Green
    exit 0
} 