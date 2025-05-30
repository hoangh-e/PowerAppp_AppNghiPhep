# ====================================================================
# TEST FIX SCRIPTS
# Script: Test-FixScripts.ps1
# Purpose: Simple test of fix scripts
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [switch]$ApplyFixes,
    [switch]$Verbose
)

Write-Host "FIX SCRIPTS TEST" -ForegroundColor Green
Write-Host "=================" -ForegroundColor Green
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Step 1: Run validation before fixes
Write-Host "Step 1: Running validation before fixes..." -ForegroundColor Cyan
Write-Host ""

Write-Host "File Structure Validation:" -ForegroundColor Yellow
& "$scriptPath\Check-FileStructure.ps1" -SourcePath $SourcePath
$fileStructureBefore = $LASTEXITCODE

Write-Host ""
Write-Host "Properties Icons Validation:" -ForegroundColor Yellow  
& "$scriptPath\Check-PropertiesIcons.ps1" -SourcePath $SourcePath
$propertiesIconsBefore = $LASTEXITCODE

Write-Host ""
Write-Host "=" * 50 -ForegroundColor Gray

# Step 2: Run fix scripts
Write-Host "Step 2: Running fix scripts..." -ForegroundColor Cyan
Write-Host ""

if ($ApplyFixes) {
    Write-Host "Applying File Structure fixes:" -ForegroundColor Yellow
    & "$scriptPath\Fix-FileStructure.ps1" -SourcePath $SourcePath -Verbose:$Verbose
    
    Write-Host ""
    Write-Host "Applying Properties Icons fixes:" -ForegroundColor Yellow
    & "$scriptPath\Fix-PropertiesIcons.ps1" -SourcePath $SourcePath -Verbose:$Verbose
} else {
    Write-Host "DRY RUN - File Structure fixes:" -ForegroundColor Yellow
    & "$scriptPath\Fix-FileStructure.ps1" -SourcePath $SourcePath -DryRun -Verbose:$Verbose
    
    Write-Host ""
    Write-Host "DRY RUN - Properties Icons fixes:" -ForegroundColor Yellow
    & "$scriptPath\Fix-PropertiesIcons.ps1" -SourcePath $SourcePath -DryRun -Verbose:$Verbose
}

Write-Host ""
Write-Host "=" * 50 -ForegroundColor Gray

# Step 3: Run validation after fixes (only if fixes were applied)
if ($ApplyFixes) {
    Write-Host "Step 3: Running validation after fixes..." -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "File Structure Validation (after fix):" -ForegroundColor Yellow
    & "$scriptPath\Check-FileStructure.ps1" -SourcePath $SourcePath
    $fileStructureAfter = $LASTEXITCODE
    
    Write-Host ""
    Write-Host "Properties Icons Validation (after fix):" -ForegroundColor Yellow
    & "$scriptPath\Check-PropertiesIcons.ps1" -SourcePath $SourcePath
    $propertiesIconsAfter = $LASTEXITCODE
    
    Write-Host ""
    Write-Host "=" * 50 -ForegroundColor Green
    Write-Host "RESULTS SUMMARY:" -ForegroundColor Green
    Write-Host "=" * 50 -ForegroundColor Green
    
    Write-Host "File Structure:" -ForegroundColor Cyan
    Write-Host "  Before: $(if ($fileStructureBefore -eq 0) { 'PASS' } else { 'FAIL' })" -ForegroundColor $(if ($fileStructureBefore -eq 0) { 'Green' } else { 'Red' })
    Write-Host "  After:  $(if ($fileStructureAfter -eq 0) { 'PASS' } else { 'FAIL' })" -ForegroundColor $(if ($fileStructureAfter -eq 0) { 'Green' } else { 'Red' })
    Write-Host "  Status: $(if ($fileStructureAfter -lt $fileStructureBefore) { 'IMPROVED' } elseif ($fileStructureAfter -eq $fileStructureBefore) { 'NO CHANGE' } else { 'WORSE' })" -ForegroundColor $(if ($fileStructureAfter -lt $fileStructureBefore) { 'Green' } elseif ($fileStructureAfter -eq $fileStructureBefore) { 'Yellow' } else { 'Red' })
    
    Write-Host ""
    Write-Host "Properties Icons:" -ForegroundColor Cyan
    Write-Host "  Before: $(if ($propertiesIconsBefore -eq 0) { 'PASS' } else { 'FAIL' })" -ForegroundColor $(if ($propertiesIconsBefore -eq 0) { 'Green' } else { 'Red' })
    Write-Host "  After:  $(if ($propertiesIconsAfter -eq 0) { 'PASS' } else { 'FAIL' })" -ForegroundColor $(if ($propertiesIconsAfter -eq 0) { 'Green' } else { 'Red' })
    Write-Host "  Status: $(if ($propertiesIconsAfter -lt $propertiesIconsBefore) { 'IMPROVED' } elseif ($propertiesIconsAfter -eq $propertiesIconsBefore) { 'NO CHANGE' } else { 'WORSE' })" -ForegroundColor $(if ($propertiesIconsAfter -lt $propertiesIconsBefore) { 'Green' } elseif ($propertiesIconsAfter -eq $propertiesIconsBefore) { 'Yellow' } else { 'Red' })
    
} else {
    Write-Host ""
    Write-Host "NEXT STEPS:" -ForegroundColor Cyan
    Write-Host "- Review the dry-run results above" -ForegroundColor White
    Write-Host "- Run with -ApplyFixes to actually apply the changes" -ForegroundColor White
    Write-Host "- Example: .\Test-FixScripts.ps1 -ApplyFixes -Verbose" -ForegroundColor Yellow
}

Write-Host "" 