# PowerShell Script to check Component Definition Structure violations
# Usage: .\check_component_definitions_fixed.ps1

param(
    [string]$SourcePath = "src",
    [string]$OutputFile = "src/COMPONENT_DEFINITION_VIOLATIONS.md"
)

Write-Host "KIEM TRA COMPONENT DEFINITION STRUCTURE (FIXED)" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

$totalFiles = 0
$totalViolations = 0
$results = @()

function Test-ComponentDefinitionStructure {
    param([string]$FilePath)
    
    $violations = @()
    $content = Get-Content $FilePath -Raw
    
    # 1. Check for old ComponentDefinition (singular) instead of ComponentDefinitions (plural)
    if ($content -match "ComponentDefinition:\s*\r?\n" -and $content -notmatch "ComponentDefinitions:") {
        $violations += "CRITICAL: Su dung 'ComponentDefinition:' thay vi 'ComponentDefinitions:' (Section 1.2)"
    }
    
    # 2. Check for old Custom Properties structure
    if ($content -match "CustomProperties:\s*\r?\n\s*-\s*\w+:" -and $content -notmatch "CustomProperties:\s*\r?\n\s*\w+:") {
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
    
    # 4. Check for missing required fields in CustomProperties - ONLY if has CustomProperties
    if ($content -match "CustomProperties:") {
        if ($content -notmatch "PropertyKind:") {
            $violations += "WARNING: Thieu 'PropertyKind:' trong CustomProperties"
        }
        
        if ($content -notmatch "DisplayName:") {
            $violations += "WARNING: Thieu 'DisplayName:' trong CustomProperties"
        }
        
        if ($content -notmatch "Description:") {
            $violations += "WARNING: Thieu 'Description:' trong CustomProperties"
        }
    }
    
    # 5. Check for invalid DataType values
    $invalidDataTypes = @("String", "Integer", "Float", "DateTime", "Object", "Array")
    foreach ($dataType in $invalidDataTypes) {
        if ($content -match "DataType:\s*$dataType") {
            $violations += "MEDIUM: DataType '$dataType' khong hop le, su dung: Text, Number, Boolean, Date and time, Record, Table, etc."
        }
    }
    
    # 6. Check for missing DefinitionType - ONLY if has ComponentDefinitions
    if ($content -match "ComponentDefinitions:") {
        if ($content -notmatch "DefinitionType:\s*CanvasComponent") {
            $violations += "HIGH: Thieu 'DefinitionType: CanvasComponent' trong component definition"
        }
    }
    
    # 7. Check for missing component-level Properties section - ONLY if has ComponentDefinitions
    if ($content -match "ComponentDefinitions:") {
        if ($content -notmatch "Properties:\s*\r?\n\s*Height:") {
            $violations += "HIGH: Thieu Properties section voi Height va Width trong component"
        }
    }
    
    return $violations
}

# Get ALL YAML files in Components folders
$allFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.yaml" 
$componentFiles = @()

foreach ($file in $allFiles) {
    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction Stop
        
        # Check if it's a component file
        if ($content -match "ComponentDefinitions:" -or $content -match "CanvasComponent") {
            $componentFiles += $file
            Write-Host "Found component: $($file.Name)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error reading $($file.FullName): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nTim thay $($componentFiles.Count) component YAML files" -ForegroundColor Green

if ($componentFiles.Count -eq 0) {
    Write-Host "KHONG TIM THAY COMPONENT FILES NAO!" -ForegroundColor Red
    Write-Host "Kiem tra lai thu muc: $SourcePath" -ForegroundColor Red
    exit 1
}

foreach ($file in $componentFiles) {
    $totalFiles++
    Write-Host "`nKiem tra: $($file.Name)" -ForegroundColor Yellow
    
    try {
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
    } catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Create detailed report
$report = "# COMPONENT DEFINITION VIOLATIONS REPORT (FIXED)" + "`n`n"
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
} else {
    $report += "## KET QUA" + "`n`n"
    $report += "**Tat ca component files tuan thu Component Definition structure!**" + "`n`n"
}

# Write report to file
$report | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "`nReport saved to: $OutputFile" -ForegroundColor Green
Write-Host "`nTONG KET:" -ForegroundColor Cyan
Write-Host "   Files kiem tra: $totalFiles" -ForegroundColor Yellow
Write-Host "   Vi pham phat hien: $totalViolations" -ForegroundColor $(if($totalViolations -gt 0) { "Red" } else { "Green" })

if ($totalViolations -gt 0) {
    Write-Host "`nCo $totalViolations vi pham can sua ngay lap tuc!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nTat ca component files tuan thu Component Definition structure!" -ForegroundColor Green
    exit 0
} 