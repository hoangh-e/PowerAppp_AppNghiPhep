# PowerShell Script: Formula Compliance Checker
# Kiểm tra tuân thủ luật Power App về formula length và multi-line syntax

param(
    [string]$Path = "src",
    [switch]$Detailed = $false,
    [switch]$FixMode = $false
)

Write-Host "🔍 POWER APP FORMULA COMPLIANCE CHECKER" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Initialize counters
$totalFiles = 0
$violationFiles = 0
$totalViolations = 0
$violations = @()

# Get all YAML files
$yamlFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.yaml"
$totalFiles = $yamlFiles.Count

Write-Host "📁 Scanning $totalFiles YAML files in '$Path'..." -ForegroundColor Yellow
Write-Host ""

foreach ($file in $yamlFiles) {
    $fileViolations = @()
    $content = Get-Content $file.FullName
    $lineNumber = 0
    
    foreach ($line in $content) {
        $lineNumber++
        
        # Check for long single-line formulas without pipe operator
        if ($line -match "^\s*(Text|OnSelect|OnChange|OnVisible|Fill|Color|BorderColor|Width|Height|X|Y):\s*=.*" -and 
            $line.Length -gt 120 -and 
            $line -notmatch "^\s*\w+:\s*\|") {
            
            $violation = [PSCustomObject]@{
                File = $file.Name
                Line = $lineNumber
                Type = "Long Formula Without Pipe"
                Length = $line.Length
                Content = $line.Trim()
                Severity = "HIGH"
            }
            $fileViolations += $violation
        }
        
        # Check for multi-line formulas without pipe operator (Concatenate pattern)
        if ($line -match "^\s*(Text|OnSelect|OnChange|OnVisible):\s*=.*\(" -and 
            $line -notmatch "^\s*\w+:\s*\|") {
            
            # Look ahead to see if it's multi-line
            $nextLineIndex = $lineNumber
            $isMultiLine = $false
            
            while ($nextLineIndex -lt $content.Count -and $nextLineIndex -lt $lineNumber + 10) {
                $nextLine = $content[$nextLineIndex]
                if ($nextLine -match "^\s*`".*`"\s*[,)]" -or $nextLine -match "^\s*\)") {
                    $isMultiLine = $true
                    break
                }
                $nextLineIndex++
            }
            
            if ($isMultiLine) {
                $violation = [PSCustomObject]@{
                    File = $file.Name
                    Line = $lineNumber
                    Type = "Multi-line Formula Without Pipe"
                    Length = "Multi-line"
                    Content = $line.Trim()
                    Severity = "CRITICAL"
                }
                $fileViolations += $violation
            }
        }
        
        # Check for space after colon in Concatenate (minor violation)
        if ($line -match "Concatenate\(.*:\s[^`"`']" -and $Detailed) {
            $violation = [PSCustomObject]@{
                File = $file.Name
                Line = $lineNumber
                Type = "Space After Colon in Text"
                Length = $line.Length
                Content = $line.Trim()
                Severity = "LOW"
            }
            $fileViolations += $violation
        }
    }
    
    if ($fileViolations.Count -gt 0) {
        $violationFiles++
        $violations += $fileViolations
        $totalViolations += $fileViolations.Count
        
        Write-Host "❌ $($file.Name): $($fileViolations.Count) violations" -ForegroundColor Red
        
        if ($Detailed) {
            foreach ($v in $fileViolations) {
                Write-Host "   Line $($v.Line): $($v.Type) [$($v.Severity)]" -ForegroundColor Yellow
                if ($v.Content.Length -gt 80) {
                    Write-Host "   Content: $($v.Content.Substring(0, 80))..." -ForegroundColor Gray
                } else {
                    Write-Host "   Content: $($v.Content)" -ForegroundColor Gray
                }
            }
            Write-Host ""
        }
    } else {
        Write-Host "✅ $($file.Name): No violations" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "📊 COMPLIANCE SUMMARY" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host "Total Files Scanned: $totalFiles" -ForegroundColor White
Write-Host "Files with Violations: $violationFiles" -ForegroundColor $(if ($violationFiles -eq 0) { "Green" } else { "Red" })
Write-Host "Total Violations: $totalViolations" -ForegroundColor $(if ($totalViolations -eq 0) { "Green" } else { "Red" })
Write-Host "Compliance Rate: $([math]::Round((($totalFiles - $violationFiles) / $totalFiles) * 100, 2))%" -ForegroundColor $(if ($violationFiles -eq 0) { "Green" } else { "Red" })

if ($totalViolations -gt 0) {
    Write-Host ""
    Write-Host "🚨 VIOLATION BREAKDOWN" -ForegroundColor Red
    Write-Host "======================" -ForegroundColor Red
    
    $groupedViolations = $violations | Group-Object Type
    foreach ($group in $groupedViolations) {
        Write-Host "$($group.Name): $($group.Count) violations" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "🔧 RECOMMENDED ACTIONS:" -ForegroundColor Yellow
    Write-Host "1. Add pipe operator (|) to formulas longer than 120 characters"
    Write-Host "2. Add pipe operator (|) to all multi-line formulas"
    Write-Host "3. Remove spaces after colons in text content"
    Write-Host "4. Run this script with -Detailed for more information"
    
    if ($FixMode) {
        Write-Host ""
        Write-Host "🛠️  FIX MODE: Generating fix suggestions..." -ForegroundColor Cyan
        
        # Generate fix suggestions
        $fixSuggestions = @()
        foreach ($v in $violations) {
            if ($v.Type -eq "Long Formula Without Pipe" -or $v.Type -eq "Multi-line Formula Without Pipe") {
                $property = ($v.Content -split ":")[0].Trim()
                $formula = ($v.Content -split ":", 2)[1].Trim()
                
                $fixSuggestion = @"
File: $($v.File)
Line: $($v.Line)
Current: $($v.Content)
Fixed:   $property`: |
           $formula
"@
                $fixSuggestions += $fixSuggestion
            }
        }
        
        if ($fixSuggestions.Count -gt 0) {
            $fixSuggestions | Out-File "formula_fix_suggestions.txt" -Encoding UTF8
            Write-Host "Fix suggestions saved to: formula_fix_suggestions.txt" -ForegroundColor Green
        }
    }
    
    exit 1
} else {
    Write-Host ""
    Write-Host "🎉 ALL FILES ARE COMPLIANT! 🎉" -ForegroundColor Green
    exit 0
}

# Usage Examples:
# .\check_formula_compliance.ps1                    # Basic check
# .\check_formula_compliance.ps1 -Detailed          # Detailed output
# .\check_formula_compliance.ps1 -FixMode           # Generate fix suggestions
# .\check_formula_compliance.ps1 -Path "src/Components" -Detailed  # Check specific path 