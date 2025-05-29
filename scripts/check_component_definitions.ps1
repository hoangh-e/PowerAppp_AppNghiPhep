# PowerShell Script to check Component Definition Structure violations
# Usage: .\check_component_definitions.ps1

param(
    [string]$SourcePath = "src",
    [string]$OutputFile = "src/COMPONENT_DEFINITION_VIOLATIONS.md"
)

Write-Host "KIEM TRA COMPONENT DEFINITION STRUCTURE" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

$totalFiles = 0
$totalViolations = 0
$results = @()

function Test-ComponentDefinitionStructure {
    param([string]$FilePath)
    
    $violations = @()
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    
    # 1. Check for old ComponentDefinition (singular) instead of ComponentDefinitions (plural)
    if ($content -match "ComponentDefinition:\s*\n" -and $content -notmatch "ComponentDefinitions:") {
        $violations += "CRITICAL: Su dung 'ComponentDefinition:' thay vi 'ComponentDefinitions:' (Section 1.2)"
    }
    
    # 2. Check for old Custom Properties structure
    if ($content -match "CustomProperties:\s*\n\s*-\s*\w+:" -and $content -notmatch "CustomProperties:\s*\n\s*\w+:") {
        $violations += "CRITICAL: Su dung cu phap Custom Properties cu voi dash thay vi direct property"
    }
    
    # 3. Check for old property names in custom properties
    if ($content -match "PropertyType:\s*(Data|Event)") {
        $violations += "CRITICAL: Su dung 'PropertyType:' thay vi 'PropertyKind:' (Section 8.3)"
    }
    
    if ($content -match "PropertyDataType:") {
        $violations += "CRITICAL: Su dung 'PropertyDataType:' thay vi 'DataType:' (Section 8.3)"
    }
    
    if ($content -match "DefaultValue:") {
        $violations += "CRITICAL: Su dung 'DefaultValue:' thay vi 'Default:' (Section 8.3)"
    }
    
    # 4. Check for missing required fields in CustomProperties
    if ($content -match "CustomProperties:" -and $content -notmatch "PropertyKind:") {
        $violations += "WARNING: Thieu 'PropertyKind:' trong CustomProperties"
    }
    
    if ($content -match "CustomProperties:" -and $content -notmatch "DisplayName:") {
        $violations += "WARNING: Thieu 'DisplayName:' trong CustomProperties"
    }
    
    if ($content -match "CustomProperties:" -and $content -notmatch "Description:") {
        $violations += "WARNING: Thieu 'Description:' trong CustomProperties"
    }
    
    # 5. Check for invalid DataType values
    $invalidDataTypes = @("String", "Integer", "Float", "DateTime", "Object", "Array")
    foreach ($dataType in $invalidDataTypes) {
        if ($content -match "DataType:\s*$dataType") {
            $violations += "MEDIUM: DataType '$dataType' khong hop le, su dung: Text, Number, Boolean, Date and time, Record, Table, etc."
        }
    }
    
    # 6. Check for missing DefinitionType
    if ($content -match "ComponentDefinitions?:" -and $content -notmatch "DefinitionType:\s*CanvasComponent") {
        $violations += "HIGH: Thieu 'DefinitionType: CanvasComponent' trong component definition"
    }
    
    # 7. Check for missing component-level Properties section
    if ($content -match "ComponentDefinitions?:" -and $content -notmatch "Properties:\s*\n\s*Height:") {
        $violations += "HIGH: Thieu Properties section voi Height va Width trong component"
    }
    
    return $violations
}

# Get all YAML files that might be components
$yamlFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.yaml" | Where-Object { 
    $content = Get-Content $_.FullName -Raw
    $content -match "ComponentDefinitions?:" -or $content -match "CanvasComponent"
}

Write-Host "Tim thay $($yamlFiles.Count) component YAML files" -ForegroundColor Yellow

foreach ($file in $yamlFiles) {
    $totalFiles++
    Write-Host "Kiem tra: $($file.Name)" -ForegroundColor Yellow
    
    $violations = Test-ComponentDefinitionStructure -FilePath $file.FullName
    
    if ($violations.Count -gt 0) {
        $totalViolations += $violations.Count
        $results += [PSCustomObject]@{
            File = $file.FullName.Replace((Get-Location).Path + "\", "")
            ViolationCount = $violations.Count
            Violations = $violations
        }
        
        Write-Host "  FAIL: $($violations.Count) vi pham phat hien" -ForegroundColor Red
        foreach ($violation in $violations) {
            Write-Host "    - $violation" -ForegroundColor Red
        }
    } else {
        Write-Host "  PASS: Khong co vi pham" -ForegroundColor Green
    }
}

# Create detailed report
$report = "# COMPONENT DEFINITION VIOLATIONS REPORT" + "`n`n"
$report += "**Thoi gian:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" + "`n"
$report += "**Tong component files kiem tra:** $totalFiles" + "`n"
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
    
    # Add fix examples
    $report += "## CAC VI DU SUA LOI" + "`n`n"
    
    $report += "### 1. ComponentDefinition → ComponentDefinitions" + "`n"
    $report += '```yaml' + "`n"
    $report += "# SAI" + "`n"
    $report += "ComponentDefinition:" + "`n"
    $report += "  DefinitionType: CanvasComponent" + "`n`n"
    $report += "# DUNG" + "`n"
    $report += "ComponentDefinitions:" + "`n"
    $report += "  ComponentName:" + "`n"
    $report += "    DefinitionType: CanvasComponent" + "`n"
    $report += '```' + "`n`n"
    
} else {
    $report += "## KET QUA" + "`n`n"
    $report += "**Tat ca component files tuan thu Component Definition structure!**" + "`n`n"
}

# Summary
$report += "## TONG KET" + "`n`n"
$report += "| Metric | Value |" + "`n"
$report += "| --- | --- |" + "`n"
$report += "| Files kiem tra | $totalFiles |" + "`n"
$report += "| Vi pham tim thay | $totalViolations |" + "`n"
$report += "| Files co vi pham | $($results.Count) |" + "`n"
$report += "| Ti le tuan thu | $([math]::Round((($totalFiles - $results.Count) / $totalFiles) * 100, 2))% |" + "`n`n"

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
    Write-Host "`nTat ca component files tuan thu Component Definition structure!" -ForegroundColor Green
    exit 0
} 