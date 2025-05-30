# ====================================================================
# FIX FILE STRUCTURE VIOLATIONS
# Script: Fix-FileStructure.ps1
# Purpose: Auto-fix file structure violations detected by Check-FileStructure.ps1
# Rules Reference: Section 1 - File Structure
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$TargetFile = "",
    [switch]$DryRun,
    [switch]$Verbose
)

Write-Host "🔧 FILE STRUCTURE AUTO-FIX" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host "Rules Reference: Section 1 - File Structure" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalFixes = 0
$results = @()

# Function to fix component file structure
function Fix-ComponentStructure {
    param(
        [string]$FilePath
    )
    
    $fixes = @()
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    $modified = $false
    
    # Fix 1: Component files must start with ComponentDefinitions (not ComponentDefinition)
    if ($content -match "DefinitionType:\s*CanvasComponent" -and $content -notmatch "^ComponentDefinitions:") {
        Write-Host "  Fix 1: Adding ComponentDefinitions root" -ForegroundColor Cyan
        
        if ($lines[0] -match "^ComponentDefinition:") {
            $lines[0] = $lines[0] -replace "ComponentDefinition:", "ComponentDefinitions:"
            $modified = $true
            $fixes += "Changed ComponentDefinition: to ComponentDefinitions:"
        } elseif ($lines[0] -notmatch "^ComponentDefinitions:") {
            # Add ComponentDefinitions as root
            $newContent = "ComponentDefinitions:`n" + ($lines -join "`n")
            $lines = $newContent.Split("`n")
            $modified = $true
            $fixes += "Added ComponentDefinitions: as root element"
        }
    }
    
    # Fix 2: Replace old custom property syntax
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        if ($line -match "\s*(PropertyType|PropertyDataType|DefaultValue):") {
            $oldProperty = $matches[1]
            $newProperty = switch ($oldProperty) {
                "PropertyType" { "PropertyKind" }
                "PropertyDataType" { "DataType" }
                "DefaultValue" { "Default" }
            }
            
            $lines[$i] = $line -replace $oldProperty, $newProperty
            $modified = $true
            $fixes += "Changed $oldProperty to $newProperty on line $($i+1)"
        }
    }
    
    # Fix 3: Add missing component-level properties
    if ($content -match "DefinitionType:\s*CanvasComponent") {
        $hasProperties = $false
        $hasHeight = $false
        $hasWidth = $false
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "^\s+Properties:") {
                $hasProperties = $true
                
                # Check for Height and Width in next 10 lines
                for ($j = $i + 1; $j -lt $i + 10 -and $j -lt $lines.Count; $j++) {
                    if ($lines[$j] -match "^\s+Height:") { $hasHeight = $true }
                    if ($lines[$j] -match "^\s+Width:") { $hasWidth = $true }
                }
                break
            }
        }
        
        if ($hasProperties -and (-not $hasHeight -or -not $hasWidth)) {
            # Find Properties section and add missing properties
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match "^\s+Properties:") {
                    $indent = "      "
                    $insertIndex = $i + 1
                    
                    if (-not $hasHeight) {
                        $lines = $lines[0..$i] + "$indent" + "Height: =App.Height" + $lines[($i+1)..($lines.Count-1)]
                        $modified = $true
                        $fixes += "Added Height property"
                    }
                    
                    if (-not $hasWidth) {
                        $insertIndex = if (-not $hasHeight) { $i + 2 } else { $i + 1 }
                        $lines = $lines[0..$insertIndex] + "$indent" + "Width: =App.Width" + $lines[($insertIndex+1)..($lines.Count-1)]
                        $modified = $true
                        $fixes += "Added Width property"
                    }
                    break
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

# Function to fix screen file structure  
function Fix-ScreenStructure {
    param(
        [string]$FilePath
    )
    
    $fixes = @()
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    $modified = $false
    
    # Fix 1: Screen files must start with Screens:
    if ($content -match "Properties:" -and $content -match "Children:" -and $content -notmatch "^Screens:") {
        Write-Host "  Fix 1: Adding Screens root" -ForegroundColor Cyan
        
        # Add Screens as root element
        $newContent = "Screens:`n" + ($lines -join "`n")
        $lines = $newContent.Split("`n")
        $modified = $true
        $fixes += "Added Screens: as root element"
    }
    
    # Fix 2: Add missing Fill properties to screen Properties sections
    $inScreen = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Track if we're in a screen definition
        if ($line -match "^Screens:" -or $line -match "^\s+\w+:$") {
            $inScreen = $true
        }
        
        # Check for Properties section in screens
        if ($inScreen -and $line -match "^\s+Properties:") {
            $hasFill = $false
            
            # Look ahead for Fill property
            for ($j = $i + 1; $j -lt $i + 10 -and $j -lt $lines.Count; $j++) {
                if ($lines[$j] -match "^\s+Fill:\s*=RGBA\(") {
                    $hasFill = $true
                    break
                }
                # Stop if we hit next section
                if ($lines[$j] -match "^\s+\w+:" -and $lines[$j] -notmatch "^\s+(Fill|OnVisible|LoadingSpinner)") {
                    break
                }
            }
            
            if (-not $hasFill) {
                # Add Fill property
                $indent = "      "
                $fillProperty = "$indent" + "Fill: =RGBA(248, 250, 252, 1)"
                $lines = $lines[0..$i] + $fillProperty + $lines[($i+1)..($lines.Count-1)]
                $modified = $true
                $fixes += "Added Fill property to screen Properties on line $($i+1)"
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
        $content = Get-Content $file.FullName -Raw
        $fileFixes = 0
        
        # Determine file type and apply appropriate fixes
        if ($content -match "DefinitionType:\s*CanvasComponent") {
            # Component file
            $result = Fix-ComponentStructure -FilePath $file.FullName
            
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
            } else {
                Write-Host "  SKIP: No fixes needed" -ForegroundColor Gray
            }
        }
        elseif ($content -match "Properties:" -and $content -match "Children:") {
            # Screen file
            $result = Fix-ScreenStructure -FilePath $file.FullName
            
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
            } else {
                Write-Host "  SKIP: No fixes needed" -ForegroundColor Gray
            }
        }
        else {
            Write-Host "  SKIP: Unknown file type" -ForegroundColor Gray
        }
        
        $totalFixes += $fileFixes
        
        if ($fileFixes -gt 0) {
            $results += [PSCustomObject]@{
                File = $file.Name
                Path = $file.FullName
                Fixes = $fileFixes
                Applied = -not $DryRun
            }
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
    Write-Host "💡 Run Check-FileStructure.ps1 again to verify fixes" -ForegroundColor Cyan
} 