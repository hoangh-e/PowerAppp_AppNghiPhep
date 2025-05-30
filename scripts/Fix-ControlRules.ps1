# ====================================================================
# FIX CONTROL RULES VIOLATIONS
# Script: Fix-ControlRules.ps1
# Purpose: Auto-fix control rules violations detected by Check-ControlRules.ps1
# Rules Reference: Section 2 - Control Rules
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$TargetFile = "",
    [switch]$DryRun,
    [switch]$Verbose
)

Write-Host "🎮 CONTROL RULES AUTO-FIX" -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Green
Write-Host "Rules Reference: Section 2 - Control Rules" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalFixes = 0
$results = @()

function Fix-ControlRulesViolations {
    param(
        [string]$FilePath
    )
    
    $fixes = @()
    $lines = Get-Content $FilePath -Encoding UTF8
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $modified = $false
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Fix 1: Remove version numbers from Control declarations
        if ($line -match "^\s*Control:\s*(\w+)@[\d\.]+") {
            $controlName = $matches[1]
            $lines[$i] = $line -replace "@[\d\.]+", ""
            $modified = $true
            $fixes += "Removed version number from Control declaration on line $lineNumber"
        }
        
        # Fix 2: Fix component control declarations
        if ($line -match "^\s*Control:\s*(\w+Component)$" -and $line -notmatch "CanvasComponent") {
            $componentName = $matches[1]
            $lines[$i] = $line -replace $componentName, "CanvasComponent"
            
            # Add ComponentName property after Control line
            $indent = if ($line -match "^(\s*)") { $matches[1] } else { "    " }
            $lines = $lines[0..$i] + "$indent" + "ComponentName: $componentName" + $lines[($i+1)..($lines.Count-1)]
            $modified = $true
            $fixes += "Fixed component control syntax on line $lineNumber"
        }
        
        # Fix 3: Remove forbidden properties
        if ($line -match "^\s*ZIndex:\s*") {
            # Remove the entire line
            $lines = $lines[0..($i-1)] + $lines[($i+1)..($lines.Count-1)]
            $i-- # Adjust index since we removed a line
            $modified = $true
            $fixes += "Removed forbidden ZIndex property on line $lineNumber"
        }
        
        # Fix 4: Fix button-specific violations
        if ($content -match "Control:\s*Classic/Button") {
            if ($line -match "^\s*BorderRadius:\s*") {
                # Remove BorderRadius for buttons
                $lines = $lines[0..($i-1)] + $lines[($i+1)..($lines.Count-1)]
                $i--
                $modified = $true
                $fixes += "Removed BorderRadius property for button on line $lineNumber"
            }
            
            if ($line -match "^\s*Disabled:\s*(.+)") {
                $value = $matches[1].Trim()
                # Convert to DisplayMode
                $newValue = if ($value -match "true|=true") {
                    "=DisplayMode.Disabled"
                } else {
                    "=DisplayMode.Edit"
                }
                $lines[$i] = $line -replace "Disabled:\s*.+", "DisplayMode: $newValue"
                $modified = $true
                $fixes += "Converted Disabled to DisplayMode on line $lineNumber"
            }
            
            if ($line -match "^\s*Align:\s*") {
                # Remove Align property for buttons
                $lines = $lines[0..($i-1)] + $lines[($i+1)..($lines.Count-1)]
                $i--
                $modified = $true
                $fixes += "Removed Align property for button on line $lineNumber"
            }
        }
        
        # Fix 5: Fix rectangle-specific violations
        if ($content -match "Control:\s*Rectangle") {
            if ($line -match "^\s*Radius(BottomLeft|BottomRight|TopLeft|TopRight):\s*(.+)") {
                $value = $matches[2]
                # Replace with BorderRadius
                $lines[$i] = $line -replace "Radius(BottomLeft|BottomRight|TopLeft|TopRight):", "BorderRadius:"
                $modified = $true
                $fixes += "Converted individual corner radius to BorderRadius on line $lineNumber"
            }
        }
        
        # Fix 6: Fix TextInput-specific violations
        if ($content -match "Control:\s*Classic/TextInput") {
            if ($line -match "Self\.Focused") {
                $lines[$i] = $line -replace "Self\.Focused", "Self.Focus"
                $modified = $true
                $fixes += "Fixed Self.Focused to Self.Focus on line $lineNumber"
            }
            
            if ($line -match "Self\.IsHovered") {
                # This requires more complex fix, for now just comment it out
                $lines[$i] = "# " + $line + " # FIXME: Use hover events instead"
                $modified = $true
                $fixes += "Commented out Self.IsHovered (needs manual fix) on line $lineNumber"
            }
            
            if ($line -match "^\s*TextMode:\s*") {
                $lines[$i] = $line -replace "TextMode:", "Mode:"
                $modified = $true
                $fixes += "Fixed TextMode to Mode property on line $lineNumber"
            }
        }
        
        # Fix 7: Add missing required properties for positioned controls
        if ($line -match "^\s*Control:\s*(Label|Classic/Button|Classic/TextInput|Image|Rectangle|GroupContainer)$") {
            $controlType = $matches[1]
            $controlSection = ""
            $hasX = $false
            $hasY = $false
            $hasWidth = $false
            $hasHeight = $false
            $propertiesLineIndex = -1
            
            # Look ahead in Properties section
            for ($j = $i + 1; $j -lt $i + 20 -and $j -lt $lines.Count; $j++) {
                if ($lines[$j] -match "^\s*Properties:") {
                    $controlSection = "Properties"
                    $propertiesLineIndex = $j
                }
                if ($controlSection -eq "Properties") {
                    if ($lines[$j] -match "^\s*X:\s*") { $hasX = $true }
                    if ($lines[$j] -match "^\s*Y:\s*") { $hasY = $true }
                    if ($lines[$j] -match "^\s*Width:\s*") { $hasWidth = $true }
                    if ($lines[$j] -match "^\s*Height:\s*") { $hasHeight = $true }
                }
                # Stop if we hit next control or section
                if ($lines[$j] -match "^\s*-\s*\w+:" -or $lines[$j] -match "^\s*Children:") {
                    break
                }
            }
            
            if ($controlSection -eq "Properties" -and $propertiesLineIndex -gt -1) {
                $indent = "      "
                $insertIndex = $propertiesLineIndex + 1
                $propsToAdd = @()
                
                if (-not $hasX) {
                    $propsToAdd += "$indent" + "X: =Parent.X + 20"
                }
                if (-not $hasY) {
                    $propsToAdd += "$indent" + "Y: =Parent.Y + 10"
                }
                if (-not $hasWidth) {
                    $defaultWidth = switch ($controlType) {
                        "Classic/Button" { "=Parent.Width / 4" }
                        "Classic/TextInput" { "=Parent.Width - 40" }
                        default { "=Parent.Width / 2" }
                    }
                    $propsToAdd += "$indent" + "Width: $defaultWidth"
                }
                if (-not $hasHeight) {
                    $defaultHeight = switch ($controlType) {
                        "Classic/Button" { "=40" }
                        "Classic/TextInput" { "=32" }
                        default { "=Parent.Height / 4" }
                    }
                    $propsToAdd += "$indent" + "Height: $defaultHeight"
                }
                
                if ($propsToAdd.Count -gt 0) {
                    $lines = $lines[0..$insertIndex] + $propsToAdd + $lines[($insertIndex+1)..($lines.Count-1)]
                    $modified = $true
                    $fixes += "Added missing position/size properties for $controlType on line $lineNumber"
                }
            }
        }
    }
    
    return @{
        Modified = $modified
        Lines = $lines
        Fixes = $fixes
    }
}

# Main processing
if ($TargetFile) {
    $yamlFiles = @(Get-Item $TargetFile)
} else {
    $yamlFiles = Get-ChildItem -Path $SourcePath -Recurse -Include "*.yaml", "*.yml" | Where-Object { !$_.PSIsContainer }
}

Write-Host "Found $($yamlFiles.Count) YAML files to process" -ForegroundColor Yellow
Write-Host ""

foreach ($file in $yamlFiles) {
    $totalFiles++
    Write-Host "Processing: $($file.Name)" -ForegroundColor White
    
    try {
        $result = Fix-ControlRulesViolations -FilePath $file.FullName
        
        if ($result.Modified) {
            $fileFixes = $result.Fixes.Count
            
            if ($DryRun) {
                Write-Host "  DRY RUN: Would apply $fileFixes fixes:" -ForegroundColor Yellow
                foreach ($fix in $result.Fixes) {
                    Write-Host "    - $fix" -ForegroundColor Yellow
                }
            } else {
                Set-Content -Path $file.FullName -Value $result.Lines -Encoding UTF8
                Write-Host "  APPLIED: $fileFixes fixes" -ForegroundColor Green
                if ($Verbose) {
                    foreach ($fix in $result.Fixes) {
                        Write-Host "    - $fix" -ForegroundColor Green
                    }
                }
            }
            
            $totalFixes += $fileFixes
            $results += [PSCustomObject]@{
                File = $file.Name
                Path = $file.FullName
                Fixes = $fileFixes
                Applied = -not $DryRun
            }
        } else {
            Write-Host "  SKIP: No fixes needed" -ForegroundColor Gray
        }
        
    }
    catch {
        Write-Host "  ERROR: Failed to process file - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Summary
Write-Host ""
Write-Host "=" * 50 -ForegroundColor Green
Write-Host "FIX SUMMARY:" -ForegroundColor Green
Write-Host "  Files processed: $totalFiles" -ForegroundColor White
Write-Host "  Files with fixes: $($results.Count)" -ForegroundColor White
Write-Host "  Total fixes: $totalFixes" -ForegroundColor White
Write-Host "  Mode: $(if ($DryRun) { 'DRY RUN' } else { 'APPLIED' })" -ForegroundColor $(if ($DryRun) { 'Yellow' } else { 'Green' })

if ($results.Count -gt 0) {
    Write-Host ""
    Write-Host "FILES WITH FIXES:" -ForegroundColor Green
    foreach ($result in $results) {
        $status = if ($result.Applied) { "FIXED" } else { "PLANNED" }
        Write-Host "  $status - $($result.File) ($($result.Fixes) fixes)" -ForegroundColor $(if ($result.Applied) { 'Green' } else { 'Yellow' })
    }
}

if (-not $DryRun -and $totalFixes -gt 0) {
    Write-Host ""
    Write-Host "✅ Applied $totalFixes fixes successfully!" -ForegroundColor Green
    Write-Host "💡 Run Check-ControlRules.ps1 again to verify fixes" -ForegroundColor Cyan
} 