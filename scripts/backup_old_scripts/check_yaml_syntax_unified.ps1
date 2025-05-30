# ====================================================================
# UNIFIED YAML SYNTAX VALIDATION SCRIPT (Rules-Compliant)
# Script: check_yaml_syntax_unified.ps1
# Purpose: Validate YAML syntax according to Section 8.11 unified rules
# Author: AI Assistant (Rules-Based Implementation)
# Date: 2024-12-19
# Version: 2.0.0 (Rules-Aligned)
# ====================================================================

param(
    [string]$SourcePath = "src",
    [switch]$FixIssues,
    [switch]$Verbose
)

Write-Host "🔍 UNIFIED YAML SYNTAX VALIDATION (RULES-COMPLIANT)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Rules Reference: Section 8.11 - YAML Syntax for Multi-line Formulas" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalViolations = 0
$filesWithViolations = 0
$results = @()

function Test-FormulaSyntax {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Skip comments and non-property lines
        if ($line -match "^\s*#" -or $line -notmatch "^\s*\w+.*:") {
            continue
        }
        
        # RULE 8.11: Check formula length and pipe operator usage
        if ($line -match "^\s*(\w+):\s*=(.*)$") {
            $propertyName = $matches[1]
            $formula = $matches[2].Trim()
            
            # Case 1: Short formula with pipe operator (VIOLATION)
            if ($line -match ":\s*\|\s*$" -and $i + 1 -lt $lines.Count) {
                $nextLine = $lines[$i + 1]
                $formulaLength = $nextLine.Trim().Length
                
                if ($formulaLength -le 120) {
                    $violations += [PSCustomObject]@{
                        Line = $lineNumber
                        Type = "PIPE_FOR_SHORT_FORMULA"
                        Rule = "Section 8.11"
                        Message = "Pipe operator used for short formula ($formulaLength chars <= 120)"
                        Property = $propertyName
                        Content = $line.Trim()
                    }
                }
            }
            
            # Case 2: Long formula without pipe operator (VIOLATION)
            elseif ($formula.Length -gt 120 -and $line -notmatch ":\s*\|\s*`$") {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "LONG_FORMULA_NO_PIPE"
                    Rule = "Section 8.11"
                    Message = "Long formula ($($formula.Length) chars > 120) should use pipe operator"
                    Property = $propertyName
                    Content = $line.Trim()
                }
            }
        }
        
        # RULE 8.11: Check pipe operator placement
        if ($line -match ":\s*\|") {
            if ($line -notmatch ":\s*\|\s*$") {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "WRONG_PIPE_PLACEMENT"
                    Rule = "Section 8.11"
                    Message = "Pipe operator must be immediately after colon with no content on same line"
                    Property = "Unknown"
                    Content = $line.Trim()
                }
            }
        }
        
        # RULE 8.11: Check multi-line without pipe operator (YAML parsing error)
        if ($line -match "=.*;\s*$" -and $i + 1 -lt $lines.Count) {
            $nextLine = $lines[$i + 1]
            if ($nextLine -match "^\s+\w+" -and $nextLine -notmatch "^\s*-\s*") {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "MULTILINE_NO_PIPE"
                    Rule = "Section 8.11" 
                    Message = "Multi-line formula without pipe operator causes YAML parsing error"
                    Property = "Unknown"
                    Content = $line.Trim()
                }
            }
        }
    }
    
    return $violations
}

function Fix-FormulaSyntax {
    param(
        [string]$FilePath,
        [array]$Violations
    )
    
    if ($Violations.Count -eq 0) {
        return 0
    }
    
    $content = Get-Content $FilePath
    $modified = $false
    $fixCount = 0
    
    # Sort violations by line number descending to avoid index shifting
    $sortedViolations = $Violations | Sort-Object Line -Descending
    
    foreach ($violation in $sortedViolations) {
        $lineIndex = $violation.Line - 1
        
        if ($violation.Type -eq "PIPE_FOR_SHORT_FORMULA") {
            # Remove pipe operator and merge lines
            if ($lineIndex + 1 -lt $content.Count) {
                $currentLine = $content[$lineIndex]
                $nextLine = $content[$lineIndex + 1]
                
                $merged = $currentLine -replace ":\s*\|\s*$", ": " + $nextLine.Trim()
                $content[$lineIndex] = $merged
                $content = $content[0..$lineIndex] + $content[($lineIndex + 2)..($content.Count - 1)]
                $modified = $true
                $fixCount++
            }
        }
        elseif ($violation.Type -eq "LONG_FORMULA_NO_PIPE") {
            # Add pipe operator for long formulas
            $line = $content[$lineIndex]
            if ($line -match "^(\s*\w+):\s*=(.*)$") {
                $indent = $matches[1]
                $formula = $matches[2].Trim()
                
                $newContent = @(
                    "$indent: |",
                    "  =$formula"
                )
                
                $content = $content[0..($lineIndex - 1)] + $newContent + $content[($lineIndex + 1)..($content.Count - 1)]
                $modified = $true
                $fixCount++
            }
        }
    }
    
    if ($modified) {
        Set-Content -Path $FilePath -Value $content -Encoding UTF8
    }
    
    return $fixCount
}

# Get all YAML files
$yamlFiles = Get-ChildItem -Path $SourcePath -Recurse -Include "*.yaml", "*.yml" | Where-Object { !$_.PSIsContainer }

Write-Host "Found $($yamlFiles.Count) YAML files" -ForegroundColor Yellow
Write-Host ""

foreach ($file in $yamlFiles) {
    $totalFiles++
    Write-Host "Checking: $($file.Name)" -ForegroundColor White
    
    try {
        $violations = Test-FormulaSyntax -FilePath $file.FullName
        
        if ($violations.Count -gt 0) {
            $filesWithViolations++
            $totalViolations += $violations.Count
            
            Write-Host "  FAIL: $($violations.Count) violations found" -ForegroundColor Red
            
            if ($Verbose) {
                foreach ($violation in $violations) {
                    Write-Host "    Line $($violation.Line): $($violation.Type) - $($violation.Message)" -ForegroundColor Yellow
                }
            }
            
            if ($FixIssues) {
                $fixCount = Fix-FormulaSyntax -FilePath $file.FullName -Violations $violations
                if ($fixCount -gt 0) {
                    Write-Host "  FIXED: $fixCount violations" -ForegroundColor Green
                }
            }
            
            $results += [PSCustomObject]@{
                File = $file.Name
                Path = $file.FullName
                Violations = $violations.Count
                Issues = $violations
            }
        }
        else {
            Write-Host "  PASS: No violations found" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  ERROR: Failed to process file - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Generate report
$reportContent = @"
# UNIFIED YAML SYNTAX VALIDATION REPORT

**Rules Reference:** Section 8.11 - YAML Syntax for Multi-line Formulas  
**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  
**Script Version:** 2.0.0 (Rules-Aligned)  

## SUMMARY

- **Files checked:** $totalFiles
- **Files with violations:** $filesWithViolations
- **Total violations:** $totalViolations
- **Compliance rate:** $([math]::Round((($totalFiles - $filesWithViolations) / $totalFiles) * 100, 2))%

## RULES IMPLEMENTED

1. **Short Formulas (≤120 chars):** Must use single line format
2. **Long Formulas (>120 chars):** Must use pipe operator (|)
3. **Pipe Placement:** Must be immediately after colon
4. **Multi-line Format:** Must use pipe operator to avoid YAML parsing errors

"@

if ($results.Count -gt 0) {
    $reportContent += "`n`n## VIOLATIONS BY FILE`n`n"
    
    foreach ($result in $results) {
        $reportContent += "### $($result.File)`n`n"
        foreach ($issue in $result.Issues) {
            $reportContent += "- **Line $($issue.Line):** $($issue.Type) - $($issue.Message)`n"
        }
        $reportContent += "`n"
    }
}

$reportPath = Join-Path $SourcePath "UNIFIED_YAML_SYNTAX_VIOLATIONS.md"
Set-Content -Path $reportPath -Value $reportContent -Encoding UTF8

Write-Host ""
Write-Host "Report saved to: $reportPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "  Files checked: $totalFiles" -ForegroundColor White
Write-Host "  Violations found: $totalViolations" -ForegroundColor $(if ($totalViolations -eq 0) { "Green" } else { "Red" })
Write-Host "  Compliance rate: $([math]::Round((($totalFiles - $filesWithViolations) / $totalFiles) * 100, 2))%" -ForegroundColor $(if ($totalViolations -eq 0) { "Green" } else { "Yellow" })

if ($totalViolations -eq 0) {
    Write-Host "`n✅ All files comply with unified YAML syntax rules!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n❌ Found $totalViolations violations of unified YAML syntax rules!" -ForegroundColor Red
    exit 1
} 