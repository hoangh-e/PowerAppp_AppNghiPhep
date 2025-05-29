# PowerShell Script to check YAML Syntax violations
# Usage: .\check_yaml_syntax.ps1

param(
    [string]$SourcePath = "src",
    [string]$OutputFile = "src/YAML_SYNTAX_VIOLATIONS.md"
)

Write-Host "KIEM TRA YAML SYNTAX VIOLATIONS" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

$totalFiles = 0
$totalViolations = 0
$results = @()

function Test-YamlSyntax {
    param([string]$FilePath)
    
    $violations = @()
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    
    $lineNumber = 0
    foreach ($line in $lines) {
        $lineNumber++
        
        # 1. Check for pipe operator in YAML
        if ($line -match "^\s*\w+:\s*\|") {
            $violations += "CRITICAL: Line $lineNumber - Pipe operator detected: '$($line.Trim())'"
        }
        
        # 2. Check for invalid control names with special characters not wrapped in quotes
        if ($line -match "^\s*-\s*[^'`"][^:]*[.\s\-][^'`"][^:]*:") {
            $violations += "HIGH: Line $lineNumber - Control name with special characters not quoted: '$($line.Trim())'"
        }
        
        # 3. Check for invalid YAML indentation (tabs)
        if ($line -match "^\t") {
            $violations += "MEDIUM: Line $lineNumber - Tab character detected, use spaces: '$($line.Trim())'"
        }
        
        # 4. Check for formula without equals sign
        if ($line -match ":\s*[A-Za-z][A-Za-z0-9]*\(" -and $line -notmatch ":\s*=") {
            $violations += "HIGH: Line $lineNumber - Formula without equals sign: '$($line.Trim())'"
        }
        
        # 5. Check for version numbers in Control declarations
        if ($line -match "Control:\s*\w+@[\d\.]+") {
            $violations += "CRITICAL: Line $lineNumber - Version number in Control declaration: '$($line.Trim())'"
        }
        
        # 6. Check for invalid boolean values
        if ($line -match ":\s*(True|False|TRUE|FALSE)") {
            $violations += "MEDIUM: Line $lineNumber - Boolean should be lowercase: '$($line.Trim())'"
        }
        
        # 7. Check for empty property values
        if ($line -match "^\s*\w+:\s*$") {
            $violations += "WARNING: Line $lineNumber - Empty property value: '$($line.Trim())'"
        }
    }
    
    # 8. Overall structure checks
    if ($content -match "ComponentDefinitions:" -and $content -notmatch "DefinitionType:\s*CanvasComponent") {
        $violations += "CRITICAL: Missing 'DefinitionType: CanvasComponent' in component definition"
    }
    
    return $violations
}

# Get all YAML files
$yamlFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.yaml"

Write-Host "Tim thay $($yamlFiles.Count) YAML files" -ForegroundColor Yellow

foreach ($file in $yamlFiles) {
    $totalFiles++
    Write-Host "Kiem tra: $($file.Name)" -ForegroundColor Yellow
    
    $violations = Test-YamlSyntax -FilePath $file.FullName
    
    if ($violations.Count -gt 0) {
        $totalViolations += $violations.Count
        $results += [PSCustomObject]@{
            File = $file.FullName.Replace((Get-Location).Path + "\", "")
            ViolationCount = $violations.Count
            Violations = $violations
        }
        
        Write-Host "  FAIL: $($violations.Count) vi pham phat hien" -ForegroundColor Red
    } else {
        Write-Host "  PASS: Khong co vi pham" -ForegroundColor Green
    }
}

# Create detailed report
$report = "# YAML SYNTAX VIOLATIONS REPORT" + "`n`n"
$report += "**Thoi gian:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" + "`n"
$report += "**Tong files kiem tra:** $totalFiles" + "`n"
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
    
    $report += "### 1. Pipe Operator Issues" + "`n"
    $report += '```yaml' + "`n"
    $report += "# SAI - Pipe operator causes YAML parsing issues" + "`n"
    $report += "Text: |" + "`n"
    $report += "  =Concatenate(" + "`n"
    $report += '    "Line 1",' + "`n"
    $report += '    "Line 2"' + "`n"
    $report += "  )" + "`n`n"
    $report += "# DUNG - Single line formula" + "`n"
    $report += 'Text: =Concatenate("Line 1", "Line 2")' + "`n"
    $report += '```' + "`n`n"
    
} else {
    $report += "## KET QUA" + "`n`n"
    $report += "**Tat ca files co YAML syntax dung cach!**" + "`n`n"
}

# Summary
$report += "## TONG KET" + "`n`n"
$report += "| Metric | Value |" + "`n"
$report += "|--------|-------|" + "`n"
$report += "| Files kiem tra | $totalFiles |" + "`n"
$report += "| Vi pham tim thay | $totalViolations |" + "`n"
$report += "| Files co vi pham | $($results.Count) |" + "`n"

if ($totalFiles -gt 0) {
    $report += "| Ti le tuan thu | $([math]::Round((($totalFiles - $results.Count) / $totalFiles) * 100, 2))% |" + "`n"
}

# Write report to file
$report | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "`nReport saved to: $OutputFile" -ForegroundColor Green
Write-Host "`nTONG KET:" -ForegroundColor Cyan
Write-Host "   Files kiem tra: $totalFiles" -ForegroundColor Yellow
Write-Host "   Vi pham phat hien: $totalViolations" -ForegroundColor $(if($totalViolations -gt 0) { "Red" } else { "Green" })

if ($totalFiles -gt 0) {
    Write-Host "   Ti le tuan thu: $([math]::Round((($totalFiles - $results.Count) / $totalFiles) * 100, 2))%" -ForegroundColor $(if($totalViolations -gt 0) { "Red" } else { "Green" })
}

if ($totalViolations -gt 0) {
    Write-Host "`nCo $totalViolations vi pham YAML syntax can sua!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nTat ca files co YAML syntax dung cach!" -ForegroundColor Green
    exit 0
} 