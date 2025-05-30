# ====================================================================
# VISUALIZE BEFORE/AFTER CHANGES
# Script: Visualize-BeforeAfter.ps1
# Purpose: Show side-by-side comparison of files before and after fixes
# Date: 2024-12-19
# ====================================================================

param(
    [string]$FilePath,
    [string]$BackupSuffix = ".backup",
    [switch]$ShowLineNumbers,
    [switch]$HighlightChanges
)

if (-not $FilePath) {
    Write-Host "Usage: .\Visualize-BeforeAfter.ps1 -FilePath <path> [-ShowLineNumbers] [-HighlightChanges]"
    exit 1
}

Write-Host "🔍 BEFORE/AFTER FILE COMPARISON" -ForegroundColor Magenta
Write-Host "================================" -ForegroundColor Magenta
Write-Host ""

$originalFile = $FilePath
$backupFile = $FilePath + $BackupSuffix

# Check if files exist
if (-not (Test-Path $originalFile)) {
    Write-Host "❌ Original file not found: $originalFile" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $backupFile)) {
    Write-Host "❌ Backup file not found: $backupFile" -ForegroundColor Red
    Write-Host "💡 Tip: Run a fix script first to create backup files" -ForegroundColor Yellow
    exit 1
}

# Read file contents
$beforeContent = Get-Content $backupFile
$afterContent = Get-Content $originalFile

Write-Host "📄 File: $originalFile" -ForegroundColor Cyan
Write-Host "📁 Backup: $backupFile" -ForegroundColor Gray
Write-Host ""

# Calculate differences
$maxLines = [Math]::Max($beforeContent.Count, $afterContent.Count)
$changes = 0

Write-Host "┌─────┬────────────────────────────────────────┬─────┬────────────────────────────────────────┐" -ForegroundColor Gray
Write-Host "│ LN  │ BEFORE (Original)                      │ LN  │ AFTER (Fixed)                          │" -ForegroundColor Gray
Write-Host "├─────┼────────────────────────────────────────┼─────┼────────────────────────────────────────┤" -ForegroundColor Gray

for ($i = 0; $i -lt $maxLines; $i++) {
    $beforeLine = if ($i -lt $beforeContent.Count) { $beforeContent[$i] } else { "" }
    $afterLine = if ($i -lt $afterContent.Count) { $afterContent[$i] } else { "" }
    
    $lineNumber = ($i + 1).ToString().PadLeft(3)
    $beforeDisplay = $beforeLine.PadRight(38).Substring(0, [Math]::Min(38, $beforeLine.Length))
    $afterDisplay = $afterLine.PadRight(38).Substring(0, [Math]::Min(38, $afterLine.Length))
    
    # Detect changes
    $isChanged = $beforeLine -ne $afterLine
    if ($isChanged) { $changes++ }
    
    # Choose color based on change status
    $color = if ($isChanged -and $HighlightChanges) {
        if ($beforeLine -eq "") { "Green" }      # Added line
        elseif ($afterLine -eq "") { "Red" }     # Removed line  
        else { "Yellow" }                        # Modified line
    } else { "White" }
    
    # Add change indicator
    $indicator = if ($isChanged) {
        if ($beforeLine -eq "") { "+" }
        elseif ($afterLine -eq "") { "-" }
        else { "~" }
    } else { " " }
    
    if ($ShowLineNumbers) {
        Write-Host "│$indicator$lineNumber │ $beforeDisplay │$indicator$lineNumber │ $afterDisplay │" -ForegroundColor $color
    } else {
        Write-Host "│$indicator    │ $beforeDisplay │$indicator    │ $afterDisplay │" -ForegroundColor $color
    }
}

Write-Host "└─────┴────────────────────────────────────────┴─────┴────────────────────────────────────────┘" -ForegroundColor Gray
Write-Host ""

# Summary
if ($changes -gt 0) {
    Write-Host "📊 Summary: $changes line(s) changed" -ForegroundColor Yellow
    Write-Host ""
    
    if ($HighlightChanges) {
        Write-Host "Legend:" -ForegroundColor White
        Write-Host "  🟢 + Added line" -ForegroundColor Green
        Write-Host "  🔴 - Removed line" -ForegroundColor Red
        Write-Host "  🟡 ~ Modified line" -ForegroundColor Yellow
    }
} else {
    Write-Host "✅ No changes detected - files are identical" -ForegroundColor Green
}

Write-Host ""

# Show specific violations fixed (if detectable)
Write-Host "🔧 Changes Analysis:" -ForegroundColor Cyan

$iconFixes = 0
$textFixes = 0
$componentFixes = 0

for ($i = 0; $i -lt $maxLines; $i++) {
    $beforeLine = if ($i -lt $beforeContent.Count) { $beforeContent[$i] } else { "" }
    $afterLine = if ($i -lt $afterContent.Count) { $afterContent[$i] } else { "" }
    
    if ($beforeLine -ne $afterLine) {
        # Detect icon fixes
        if ($beforeLine -match "Icon\.Calendar(?!Blank)" -and $afterLine -match "Icon\.CalendarBlank") {
            $iconFixes++
            Write-Host "  📦 Line $($i+1): Fixed calendar icon (Calendar → CalendarBlank)" -ForegroundColor Green
        }
        
        if ($beforeLine -match "Icon\.HamburgerMenu" -and $afterLine -match "Icon\.Hamburger") {
            $iconFixes++
            Write-Host "  📦 Line $($i+1): Fixed hamburger icon (HamburgerMenu → Hamburger)" -ForegroundColor Green
        }
        
        # Detect text formatting fixes
        if ($beforeLine -match ':\s"' -and $afterLine -match ':" & " "') {
            $textFixes++
            Write-Host "  📝 Line $($i+1): Fixed text formatting (colon spacing)" -ForegroundColor Green
        }
        
        # Detect component property fixes
        if ($beforeLine -match "PropertyKind:\s*Event" -and $afterLine -match "DataType:") {
            $componentFixes++
            Write-Host "  🔧 Line $($i+1): Added missing DataType to Event property" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "📈 Fix Summary:" -ForegroundColor White
Write-Host "  Icon fixes: $iconFixes" -ForegroundColor $(if ($iconFixes -gt 0) { "Green" } else { "Gray" })
Write-Host "  Text fixes: $textFixes" -ForegroundColor $(if ($textFixes -gt 0) { "Green" } else { "Gray" })
Write-Host "  Component fixes: $componentFixes" -ForegroundColor $(if ($componentFixes -gt 0) { "Green" } else { "Gray" })
Write-Host "  Total fixes: $($iconFixes + $textFixes + $componentFixes)" -ForegroundColor $(if (($iconFixes + $textFixes + $componentFixes) -gt 0) { "Green" } else { "Gray" })

exit 0 