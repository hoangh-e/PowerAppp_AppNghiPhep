# ====================================================================
# FIX COMPONENT DEFINITIONS VIOLATIONS
# Script: Fix-ComponentDefinitions.ps1
# Purpose: Auto-fix component definitions violations detected by Check-ComponentDefinitions.ps1
# Rules Reference: Section 1.2 - Components (Thành phần)
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$TargetFile = "",
    [switch]$DryRun,
    [switch]$Verbose
)

Write-Host "🧩 COMPONENT DEFINITIONS AUTO-FIX" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host "Rules Reference: Section 1.2 - Components" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalFixes = 0
$results = @()

function Fix-ComponentDefinitionsViolations {
    param(
        [string]$FilePath
    )
    
    $fixes = @()
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $originalContent = $content
    
    # Rule 1.2: Fix ComponentDefinition -> ComponentDefinitions
    if ($content -match "ComponentDefinition`:\s*\n") {
        $content = $content -replace "ComponentDefinition`:", "ComponentDefinitions:"
        $fixes += @{
            Rule = "1.2"
            Type = "Component Structure Fix"
            Description = "Changed ComponentDefinition: to ComponentDefinitions:"
        }
    }
    
    # Rule 1.2: Fix old custom property structure (array -> object)
    # Convert from: CustomProperties:\n  - PropertyName: to CustomProperties:\n  PropertyName:
    $content = $content -replace "CustomProperties`:\s*\n\s*-\s*(\w+`:\s*\n(?:\s+\w+`:.*\n)*)", "CustomProperties:`n  `$1"
    if ($content -ne $originalContent) {
        $fixes += @{
            Rule = "1.2"
            Type = "Custom Properties Structure Fix"
            Description = "Changed array format to object format for CustomProperties"
        }
    }
    
    # Rule 1.2: Fix old property names
    $oldPropertyMappings = @{
        "PropertyType" = "PropertyKind"
        "PropertyDataType" = "DataType"
        "DefaultValue" = "Default"
    }
    
    foreach ($oldProp in $oldPropertyMappings.Keys) {
        $newProp = $oldPropertyMappings[$oldProp]
        if ($content -match "$oldProp`:") {
            $content = $content -replace "$oldProp`:", "$newProp`:"
            $fixes += @{
                Rule = "1.2"
                Type = "Property Name Fix"
                Description = "Changed $oldProp to $newProp"
            }
        }
    }
    
    # Rule 1.2: Add missing required custom property fields
    # This is more complex and would require parsing the YAML structure
    # For now, we'll provide basic fixes and let users add missing fields manually
    
    # Rule 1.2: Add missing component-level properties
    if ($content -match "ComponentDefinitions`:" -or $content -match "ComponentDefinition`:") {
        if ($content -notmatch "Properties`:\s*\n(?:[^\n]*\n)*?\s*Height`:") {
            # Add Height property if missing
            if ($content -match "(ComponentDefinitions`:\s*\n\s*\w+`:\s*\n(?:[^\n]*\n)*?)(Children`:)") {
                $content = $content -replace "(ComponentDefinitions`:\s*\n\s*\w+`:\s*\n(?:[^\n]*\n)*?)(Children`:)", "`$1    Properties:`n      Height: =App.Height`n      Width: =App.Width`n    `$2"
                $fixes += @{
                    Rule = "1.2"
                    Type = "Component Properties Fix"
                    Description = "Added missing Height and Width properties"
                }
            }
        }
    }
    
    # Apply fixes if content changed
    if ($content -ne $originalContent -and -not $DryRun) {
        Set-Content -Path $FilePath -Value $content -Encoding UTF8
    }
    
    return $fixes
}

# Process files
if ($TargetFile) {
    $files = @($TargetFile)
} else {
    $files = Get-ChildItem -Path $SourcePath -Recurse -Include "*.yaml", "*.yml" | ForEach-Object { $_.FullName }
}

foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        Write-Warning "File not found: $file"
        continue
    }
    
    $totalFiles++
    $fixes = Fix-ComponentDefinitionsViolations -FilePath $file
    
    if ($fixes.Count -gt 0) {
        $totalFixes += $fixes.Count
        $results += @{
            File = $file
            Fixes = $fixes
        }
        
        $status = if ($DryRun) { "DRY RUN" } else { "FIXED" }
        Write-Host "📄 $file [$status]" -ForegroundColor White
        
        foreach ($fix in $fixes) {
            $typeColor = switch ($fix.Type) {
                "Component Structure Fix" { "Red" }
                "Custom Properties Structure Fix" { "Yellow" }
                "Property Name Fix" { "Cyan" }
                "Component Properties Fix" { "Green" }
                default { "Gray" }
            }
            
            Write-Host "  ✅ $($fix.Type)" -ForegroundColor $typeColor
            Write-Host "     Rule: $($fix.Rule) | $($fix.Description)" -ForegroundColor Gray
        }
        Write-Host ""
    }
}

# Summary
Write-Host "=" * 60 -ForegroundColor Green
Write-Host "COMPONENT DEFINITIONS FIX SUMMARY" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Green
Write-Host ""

$mode = if ($DryRun) { "DRY RUN MODE" } else { "LIVE MODE" }
Write-Host "Mode: $mode" -ForegroundColor $(if ($DryRun) { 'Yellow' } else { 'Green' })
Write-Host "Files processed: $totalFiles" -ForegroundColor White
Write-Host "Total fixes: $totalFixes" -ForegroundColor $(if ($totalFixes -eq 0) { 'Yellow' } else { 'Green' })

if ($totalFixes -gt 0) {
    Write-Host ""
    Write-Host "FIX BREAKDOWN:" -ForegroundColor Yellow
    
    $fixTypes = $results | ForEach-Object { $_.Fixes } | Group-Object Type
    foreach ($type in $fixTypes) {
        Write-Host "  $($type.Name): $($type.Count)" -ForegroundColor White
    }
    
    if ($DryRun) {
        Write-Host ""
        Write-Host "💡 Run without -DryRun to apply these fixes" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "✅ All fixes have been applied!" -ForegroundColor Green
        Write-Host "💡 Run Check-ComponentDefinitions.ps1 to verify the fixes" -ForegroundColor Cyan
    }
} else {
    Write-Host ""
    Write-Host "✅ No component definition violations found to fix!" -ForegroundColor Green
}

exit 0 