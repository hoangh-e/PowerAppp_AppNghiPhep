# PowerShell Script to check TextMode violations in Classic/TextInput
# Usage: .\check_textmode_violations.ps1

param(
    [string]$SourcePath = "src",
    [string]$OutputFile = "src/TEXTMODE_VIOLATIONS_RESULTS.md"
)

Write-Host "KIEM TRA TEXTMODE VIOLATIONS" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

$totalFiles = 0
$totalViolations = 0
$violations = @()

# Function to check TextMode violations
function Test-TextModeViolations {
    param([string]$FilePath)
    
    $content = Get-Content $FilePath -Raw
    $violations = @()
    
    # Check if file has Classic/TextInput controls
    if ($content -match "Control:\s*Classic/TextInput") {
        # Check if it also has TextMode property (which is wrong)
        $textModeMatches = [regex]::Matches($content, "TextMode:\s*=")
        
        foreach ($match in $textModeMatches) {
            $lineNumber = ($content.Substring(0, $match.Index) -split "`n").Count
            $violations += [PSCustomObject]@{
                File = $FilePath
                Line = $lineNumber
                Issue = "TextMode property used for Classic/TextInput (should be Mode)"
                Pattern = $match.Value
            }
        }
    }
    
    return $violations
}

# Get all YAML files
$yamlFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.yaml"

foreach ($file in $yamlFiles) {
    $totalFiles++
    Write-Host "Kiem tra: $($file.Name)" -ForegroundColor Yellow
    
    $fileViolations = Test-TextModeViolations -FilePath $file.FullName
    
    if ($fileViolations.Count -gt 0) {
        $totalViolations += $fileViolations.Count
        $violations += $fileViolations
        
        Write-Host "  $($fileViolations.Count) vi pham TextMode" -ForegroundColor Red
        foreach ($violation in $fileViolations) {
            Write-Host "    Line $($violation.Line): $($violation.Pattern)" -ForegroundColor Red
        }
    } else {
        Write-Host "  Khong co vi pham TextMode" -ForegroundColor Green
    }
}

# Create report
$report = "# KET QUA KIEM TRA TEXTMODE VIOLATIONS`n`n"
$report += "**Thoi gian:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
$report += "**Tong files kiem tra:** $totalFiles`n"
$report += "**Tong vi pham:** $totalViolations`n`n"

if ($totalViolations -eq 0) {
    $report += "## ✅ KHONG CO VI PHAM TEXTMODE`n`n"
    $report += "Tat ca Classic/TextInput controls deu su dung property 'Mode:' dung cach.`n`n"
} else {
    $report += "## ❌ VI PHAM TEXTMODE PROPERTY`n`n"
    $report += "**QUY TAC BI VI PHAM:**`n"
    $report += "- Classic/TextInput controls phai su dung property 'Mode:' thay vi 'TextMode:'`n"
    $report += "- Gia tri hop le: TextMode.Password, TextMode.MultiLine, TextMode.SingleLine`n`n"
    
    $report += "### DANH SACH VI PHAM:`n`n"
    
    $groupedViolations = $violations | Group-Object File
    foreach ($group in $groupedViolations) {
        $relativePath = $group.Name.Replace((Get-Location).Path + "\", "")
        $report += "#### $relativePath`n"
        
        foreach ($violation in $group.Group) {
            $report += "- **Line $($violation.Line):** ``$($violation.Pattern)`` ❌`n"
        }
        $report += "`n"
    }
    
    $report += "---`n`n"
    $report += "## HUONG DAN SUA LOI`n`n"
    $report += "### Vi Pham:`n"
    $report += "```yaml`n"
    $report += "# WRONG - TextMode property cho Classic/TextInput`n"
    $report += "Properties:`n"
    $report += "  TextMode: =TextMode.Password`n"
    $report += "  TextMode: =TextMode.MultiLine`n"
    $report += "```n"
    $report += "`n"
    $report += "### Fix:`n"
    $report += "```yaml`n"
    $report += "# CORRECT - Mode property cho Classic/TextInput`n"
    $report += "Properties:`n"
    $report += "  Mode: =TextMode.Password`n"
    $report += "  Mode: =TextMode.MultiLine`n"
    $report += "```n"
    $report += "`n"
    $report += "### Gia tri hop le:`n"
    $report += "- TextMode.Password - Password input`n"
    $report += "- TextMode.MultiLine - Multi-line text area`n"
    $report += "- TextMode.SingleLine - Single line input (default)`n"
}

# Write report
$report | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "`nTONG KET:" -ForegroundColor Cyan
Write-Host "Files kiem tra: $totalFiles" -ForegroundColor White
Write-Host "Vi pham TextMode: $totalViolations" -ForegroundColor $(if($totalViolations -gt 0) {"Red"} else {"Green"})
Write-Host "Bao cao: $OutputFile" -ForegroundColor White

if ($totalViolations -gt 0) {
    Write-Host "`nCO VI PHAM TEXTMODE!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nKHONG CO VI PHAM TEXTMODE!" -ForegroundColor Green
    exit 0
} 