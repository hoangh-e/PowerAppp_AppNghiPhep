# PowerShell Script to fix multi-line formulas in Power App YAML files
# Usage: .\fix_multiline_formulas.ps1

param(
    [string]$SourcePath = "src/Screens"
)

Write-Host "SUA MULTI-LINE FORMULAS TRONG POWER APP" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

$totalFiles = 0
$totalFixed = 0

# Function to fix multi-line formulas in a file
function Fix-MultilineFormulas {
    param([string]$FilePath)
    
    $content = Get-Content $FilePath -Raw
    $originalContent = $content
    $fixed = 0
    
    # Pattern 1: OnVisible with multi-line
    if ($content -match "OnVisible:\s*\|\s*\n\s*=([^`n]+);\s*\n\s*([^`n]+);\s*\n\s*([^`n]+)") {
        $line1 = $matches[1].Trim()
        $line2 = $matches[2].Trim()
        $line3 = $matches[3].Trim()
        $replacement = "OnVisible: =$line1; $line2; $line3"
        $content = $content -replace "OnVisible:\s*\|\s*\n\s*=([^`n]+);\s*\n\s*([^`n]+);\s*\n\s*([^`n]+)", $replacement
        $fixed++
        Write-Host "  Fixed OnVisible multi-line formula" -ForegroundColor Green
    }
    
    # Pattern 2: OnSelect with complex multi-line (simplified approach)
    if ($content -match "OnSelect:\s*\|") {
        # For complex OnSelect, we'll use a simpler approach
        $content = $content -replace "OnSelect:\s*\|\s*\n\s*=([^`n]+);\s*\n\s*([^`n]+);", "OnSelect: =`$1; `$2;"
        $content = $content -replace "\n\s*//[^`n]*\n", " "  # Remove comment lines
        $content = $content -replace "\n\s*\n", " "  # Remove empty lines in formulas
        $content = $content -replace "\s+", " "  # Normalize spaces
        $fixed++
        Write-Host "  Fixed OnSelect multi-line formula" -ForegroundColor Green
    }
    
    # Save if changes were made
    if ($content -ne $originalContent) {
        $content | Out-File -FilePath $FilePath -Encoding UTF8
        Write-Host "  Saved changes to $FilePath" -ForegroundColor Yellow
    }
    
    return $fixed
}

# Get all YAML files in Screens directory
$yamlFiles = Get-ChildItem -Path $SourcePath -Filter "*.yaml"

foreach ($file in $yamlFiles) {
    $totalFiles++
    Write-Host "Processing: $($file.Name)" -ForegroundColor Yellow
    
    $fixed = Fix-MultilineFormulas -FilePath $file.FullName
    $totalFixed += $fixed
    
    if ($fixed -eq 0) {
        Write-Host "  No multi-line formulas found" -ForegroundColor Gray
    }
}

Write-Host "`nTONG KET:" -ForegroundColor Cyan
Write-Host "Files processed: $totalFiles" -ForegroundColor White
Write-Host "Formulas fixed: $totalFixed" -ForegroundColor Green

if ($totalFixed -gt 0) {
    Write-Host "`nDA SUA XONG MULTI-LINE FORMULAS!" -ForegroundColor Green
} else {
    Write-Host "`nKHONG CO MULTI-LINE FORMULAS CAN SUA!" -ForegroundColor Yellow
} 