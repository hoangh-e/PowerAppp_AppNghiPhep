# PowerShell Script to validate Power App Rules
# Usage: .\validate_power_app_rules.ps1

param(
    [string]$SourcePath = "src",
    [string]$OutputFile = "src/RULE_VALIDATION_RESULTS.md"
)

Write-Host "KIEM TRA POWER APP RULES" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

$totalFiles = 0
$totalErrors = 0
$results = @()

# Function to test Power App file
function Test-PowerAppFile {
    param([string]$FilePath)
    
    $errors = @()
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    
    # 1. Check Component Definition Structure
    if ($content -match "ComponentDefinition:\s*\n" -and $content -notmatch "ComponentDefinitions:") {
        $errors += "CRITICAL: Su dung 'ComponentDefinition' thay vi 'ComponentDefinitions'"
    }
    
    # 2. Check old Custom Properties
    if ($content -match "PropertyType:\s*Data" -or $content -match "PropertyDataType:" -or $content -match "DefaultValue:") {
        $errors += "CRITICAL: Su dung cu phap Custom Properties cu (PropertyType, PropertyDataType, DefaultValue)"
    }
    
    # 3. Check Multi-line formulas
    if ($content -match "OnVisible:\s*\|" -or $content -match "OnSelect:\s*\|") {
        $errors += "CRITICAL: Su dung multi-line formulas trong YAML"
    }
    
    # 4. Check BorderRadius for Classic controls
    if ($content -match "Control:\s*Classic/" -and $content -match "BorderRadius:") {
        $errors += "HIGH: BorderRadius khong ho tro cho Classic controls"
    }
    
    # 5. Check Align property
    if ($content -match "Align:\s*=Align\.") {
        $errors += "MEDIUM: Align property co the khong ho tro cho mot so controls"
    }
    
    # 6. Check DropShadow
    if ($content -match "DropShadow:") {
        $errors += "MEDIUM: DropShadow co the khong ho tro cho mot so controls"
    }
    
    # 7. Check invalid Self properties
    if ($content -match "Self\.Focused" -or $content -match "Self\.IsHovered") {
        $errors += "HIGH: Su dung Self properties khong hop le (Self.Focused, Self.IsHovered)"
    }
    
    # 8. Check ZIndex
    if ($content -match "ZIndex:") {
        $errors += "HIGH: ZIndex property khong duoc ho tro"
    }
    
    return $errors
}

# Get all YAML files
$yamlFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.yaml"

foreach ($file in $yamlFiles) {
    $totalFiles++
    Write-Host "Kiem tra: $($file.FullName)" -ForegroundColor Yellow
    
    $errors = Test-PowerAppFile -FilePath $file.FullName
    
    if ($errors.Count -gt 0) {
        $totalErrors += $errors.Count
        $results += [PSCustomObject]@{
            File = $file.FullName.Replace((Get-Location).Path + "\", "")
            ErrorCount = $errors.Count
            Errors = $errors
        }
        
        Write-Host "  $($errors.Count) loi phat hien" -ForegroundColor Red
    } else {
        Write-Host "  Khong co loi" -ForegroundColor Green
    }
}

# Create report
$report = "# KET QUA KIEM TRA POWER APP RULES`n`n"
$report += "**Thoi gian:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
$report += "**Tong files kiem tra:** $totalFiles`n"
$report += "**Tong loi phat hien:** $totalErrors`n`n"
$report += "---`n`n"
$report += "## CHI TIET LOI`n`n"

if ($results.Count -eq 0) {
    $report += "KHONG CO LOI PHAT HIEN`n`n"
    $report += "Tat ca files deu tuan thu Power App rules.`n"
} else {
    foreach ($result in $results) {
        $report += "### $($result.File)`n"
        $report += "**So loi:** $($result.ErrorCount)`n`n"
        foreach ($errorMsg in $result.Errors) {
            $report += "- $errorMsg`n"
        }
        $report += "`n"
    }
    
    $report += "---`n`n"
    $report += "## HANH DONG CAN THUC HIEN`n`n"
    $report += "### PRIORITY 1 - CRITICAL`n"
    $report += "- Sua Component Definition Structure`n"
    $report += "- Sua Custom Properties Structure`n"
    $report += "- Chuyen multi-line formulas thanh single-line`n`n"
    $report += "### PRIORITY 2 - HIGH`n"
    $report += "- Loai bo BorderRadius khoi Classic controls`n"
    $report += "- Sua Self properties khong hop le`n"
    $report += "- Loai bo ZIndex properties`n`n"
    $report += "### PRIORITY 3 - MEDIUM`n"
    $report += "- Kiem tra Align properties`n"
    $report += "- Kiem tra DropShadow properties`n"
}

# Write report
$report | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "`nTONG KET:" -ForegroundColor Cyan
Write-Host "Files kiem tra: $totalFiles" -ForegroundColor White
Write-Host "Loi phat hien: $totalErrors" -ForegroundColor $(if($totalErrors -gt 0) {"Red"} else {"Green"})
Write-Host "Bao cao: $OutputFile" -ForegroundColor White

if ($totalErrors -gt 0) {
    Write-Host "`nCO LOI CAN SUA!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nTAT CA FILES DAT CHUAN!" -ForegroundColor Green
    exit 0
} 