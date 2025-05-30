# ====================================================================
# FIX POSITION & SIZE VIOLATIONS
# Script: Fix-PositionSize.ps1
# Purpose: Auto-fix position & size violations detected by Check-PositionSize.ps1
# Rules Reference: Section 3 - Position & Size Rules
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$TargetFile = "",
    [switch]$DryRun,
    [switch]$Verbose
)

Write-Host "📐 POSITION `& SIZE AUTO-FIX" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
Write-Host "Rules Reference: Section 3 - Position `& Size Rules" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalFixes = 0
$results = @()

function Fix-PositionSizeViolations {
    param(
        [string]$FilePath
    )
    
    $fixes = @()
    $lines = Get-Content $FilePath -Encoding UTF8
    $modified = $false
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Fix 1: Convert absolute Width/Height to relative
        if ($line -match "^\s*(Width|Height):\s*=?(\d+)$") {
            $property = $matches[1]
            $value = [int]$matches[2]
            
            # Convert to relative based on common patterns
            $relativeValue = switch ($property) {
                "Width" {
                    if ($value -lt 100) { "=Parent.Width / 4" }
                    elseif ($value -lt 300) { "=Parent.Width / 2" }
                    else { "=Parent.Width * 0.8" }
                }
                "Height" {
                    if ($value -lt 50) { "=40" }
                    elseif ($value -lt 200) { "=Parent.Height / 4" }
                    else { "=Parent.Height / 2" }
                }
            }
            
            $lines[$i] = $line -replace ":.*$", ": $relativeValue"
            $modified = $true
            $fixes += "Converted absolute $property ($value) to relative on line $lineNumber"
        }
        
        # Fix 2: Convert absolute X/Y to relative
        if ($line -match "^\s*(X|Y):\s*=?(\d+)$") {
            $property = $matches[1]
            $value = [int]$matches[2]
            
            # Convert to relative based on common patterns
            $relativeValue = switch ($property) {
                "X" {
                    if ($value -eq 0) { "=Parent.X" }
                    elseif ($value -lt 50) { "=Parent.X + 20" }
                    else { "=Parent.X + Parent.Width * 0.1" }
                }
                "Y" {
                    if ($value -eq 0) { "=Parent.Y" }
                    elseif ($value -lt 50) { "=Parent.Y + 10" }
                    else { "=Parent.Y + Parent.Height * 0.05" }
                }
            }
            
            $lines[$i] = $line -replace ":.*$", ": $relativeValue"
            $modified = $true
            $fixes += "Converted absolute $property ($value) to relative on line $lineNumber"
        }
        
        # Fix 3: Add missing = prefix for dynamic calculations (ONLY if = is missing)
        if ($line -match "^\s*(Width|Height|X|Y|Size):\s*(?!=)(Parent\.|Self\.)") {
            $property = $matches[1]
            $calculation = $matches[2]
            # Check if line already has = sign
            if ($line -notmatch "^\s*(Width|Height|X|Y|Size):\s*=") {
                $lines[$i] = $line -replace ":\s*", ": ="
                $modified = $true
                $fixes += "Added missing = prefix for $property calculation on line $lineNumber"
            }
        }
        
        # Fix 4: Improve basic Parent references
        if ($line -match "^\s*(Width|Height):\s*=Parent\.(Width|Height)\s*$") {
            $property = $matches[1]
            $parentProp = $matches[2]
            # Add percentage to make it more responsive
            $lines[$i] = $line -replace "=Parent\.$parentProp", "=Parent.$parentProp * 0.8"
            $modified = $true
            $fixes += "Improved $property to use 80% of parent on line $lineNumber"
        }
        
        # Fix 5: Add offset to direct Parent positioning
        if ($line -match "^\s*(X|Y):\s*=Parent\.(X|Y)\s*$") {
            $property = $matches[1]
            $parentProp = $matches[2]
            $offset = if ($property -eq "X") { "20" } else { "10" }
            $lines[$i] = $line -replace "=Parent\.$parentProp", "=Parent.$parentProp + $offset"
            $modified = $true
            $fixes += "Added offset to $property positioning on line $lineNumber"
        }
        
        # Fix 6: Remove Width/Height from screen properties
        if ($line -match "^\s*Control:\s*Screen" -or ($i -gt 0 -and $lines[$i-10..($i-1)] -match "Screens:")) {
            # Look ahead for Properties section
            for ($j = $i + 1; $j -lt $i + 10 -and $j -lt $lines.Count; $j++) {
                if ($lines[$j] -match "^\s*Properties:") {
                    # Look for Width/Height in next few lines
                    for ($k = $j + 1; $k -lt $j + 10 -and $k -lt $lines.Count; $k++) {
                        if ($lines[$k] -match "^\s*(Width|Height):\s*") {
                            # Remove this line
                            $lines = $lines[0..($k-1)] + $lines[($k+1)..($lines.Count-1)]
                            $modified = $true
                            $fixes += "Removed unnecessary $($matches[1]) property from screen on line $($k+1)"
                            $k-- # Adjust index since we removed a line
                        }
                        # Stop if we hit next section
                        if ($lines[$k] -match "^\s*Children:" -or $lines[$k] -match "^\s*-\s*\w+:") {
                            break
                        }
                    }
                    break
                }
            }
        }
        
        # Fix 7: Optimize large fixed numbers in calculations
        if ($line -match "^\s*(Width|Height|X|Y|Size):\s*=(.+[+\-\*/]\s*)(\d+)(.*)") {
            $property = $matches[1]
            $beforeNumber = $matches[2]
            $number = [int]$matches[3]
            $afterNumber = $matches[4]
            
            # Only fix if number is large (>20)
            if ($number -gt 20) {
                # Convert to percentage of parent
                $percentage = [math]::Round($number / 400, 2) # Assume 400px is 100%
                if ($percentage -gt 1) { $percentage = 0.1 } # Cap at 10%
                
                $newCalculation = "$beforeNumber" + "Parent.Width * $percentage" + "$afterNumber"
                $lines[$i] = $line -replace "=.+$", "=$newCalculation"
                $modified = $true
                $fixes += "Converted large fixed number ($number) to percentage in $property on line $lineNumber"
            }
        }
        
        # Fix 8: Ensure proper spacing in calculations
        if ($line -match "^\s*(Width|Height|X|Y|Size):\s*=(.+)") {
            $property = $matches[1]
            $calculation = $matches[2]
            
            # Fix spacing around operators
            $fixedCalculation = $calculation -replace '\s*([+\-*/])\s*', ' $1 '
            if ($fixedCalculation -ne $calculation) {
                $lines[$i] = $line -replace "=.+$", "=$fixedCalculation"
                $modified = $true
                $fixes += "Fixed spacing in $property calculation on line $lineNumber"
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
        $result = Fix-PositionSizeViolations -FilePath $file.FullName
        
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
        Write-Host "  $status - $($result.File) ($($result.Fixes) items)" -ForegroundColor $(if ($result.Applied) { 'Green' } else { 'Yellow' })
    }
}

if (-not $DryRun -and $totalFixes -gt 0) {
    Write-Host ""
    Write-Host "Applied $totalFixes items successfully!" -ForegroundColor Green
    Write-Host "Run Check-PositionSize.ps1 again to verify changes" -ForegroundColor Cyan
} 