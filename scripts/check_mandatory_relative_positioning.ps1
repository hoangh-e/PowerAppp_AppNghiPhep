# ====================================================================
# MANDATORY RELATIVE POSITIONING VALIDATION (Rules-Compliant)
# Script: check_mandatory_relative_positioning.ps1
# Purpose: Validate positioning rules according to Section 3 - Position & Size Rules
# Author: AI Assistant (Rules-Based Implementation)
# Date: 2024-12-19
# Version: 1.0.0 (Rules-Aligned)
# ====================================================================

param(
    [string]$SourcePath = "src",
    [switch]$FixIssues,
    [switch]$Verbose
)

Write-Host "🎯 MANDATORY RELATIVE POSITIONING VALIDATION (RULES-COMPLIANT)" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "Rules Reference: Section 3 - Position & Size Rules" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalViolations = 0
$filesWithViolations = 0
$results = @()

function Test-RelativePositioning {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $lines = Get-Content $FilePath
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Skip comments and non-property lines
        if ($line -match "^\s*#" -or $line -notmatch "^\s*\w+.*:") {
            continue
        }
        
        # RULE 3.1: Width and Height - MANDATORY RELATIVE POSITIONING
        if ($line -match "^\s*(Width|Height):\s*=\s*(\d+)$") {
            $property = $matches[1]
            $value = $matches[2]
            
            $violations += [PSCustomObject]@{
                Line = $lineNumber
                Type = "ABSOLUTE_SIZE_VALUE"
                Rule = "Section 3.1"
                Message = "$property uses absolute value ($value) - must be relative"
                Property = $property
                Content = $line.Trim()
                Suggestion = "$property: =Parent.$property * 0.8"
            }
        }
        
        # RULE 3.2: X and Y Positioning - MANDATORY RELATIVE POSITIONING  
        if ($line -match "^\s*(X|Y):\s*=\s*(\d+)$") {
            $property = $matches[1]
            $value = $matches[2]
            
            $violations += [PSCustomObject]@{
                Line = $lineNumber
                Type = "ABSOLUTE_POSITION_VALUE"
                Rule = "Section 3.2"
                Message = "$property uses absolute value ($value) - must be relative"
                Property = $property
                Content = $line.Trim()
                Suggestion = "$property: =Parent.$property + 20"
            }
        }
        
        # RULE 3.3: Fixed Numbers in Calculations - DISCOURAGED
        if ($line -match "^\s*(Width|Height|X|Y):\s*=.*[+\-]\s*(\d{2,})") {
            $property = $matches[1]
            $number = $matches[2]
            
            if ([int]$number -gt 20) {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "LARGE_FIXED_NUMBER"
                    Rule = "Section 3.3"
                    Message = "$property uses large fixed number ($number > 20) - prefer relative calculations"
                    Property = $property
                    Content = $line.Trim()
                    Suggestion = "Use percentage-based calculations instead"
                }
            }
        }
        
        # RULE 3.4: Screen-Level Properties (should not have Width/Height)
        if ($line -match "^\s*Screens:" -and $i + 1 -lt $lines.Count) {
            # Check if screen has Width/Height (not allowed)
            for ($j = $i + 1; $j -lt $lines.Count; $j++) {
                $screenLine = $lines[$j]
                if ($screenLine -match "^\s*(Width|Height):\s*=") {
                    $property = $matches[1]
                    
                    $violations += [PSCustomObject]@{
                        Line = $j + 1
                        Type = "SCREEN_SIZE_PROPERTY"
                        Rule = "Section 3.4"
                        Message = "Screen should not have $property property - automatically handled by Power Apps"
                        Property = $property
                        Content = $screenLine.Trim()
                        Suggestion = "Remove $property property from screen"
                    }
                }
                
                # Stop at next screen or section
                if ($screenLine -match "^\s*\w+:" -and $screenLine -notmatch "^\s+(Properties|Children):") {
                    break
                }
            }
        }
    }
    
    return $violations
}

function Fix-RelativePositioning {
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
    
    foreach ($violation in $Violations) {
        $lineIndex = $violation.Line - 1
        
        if ($violation.Type -eq "ABSOLUTE_SIZE_VALUE") {
            # Convert absolute to relative size
            $line = $content[$lineIndex]
            if ($line -match "^(\s*)(Width|Height):\s*=\s*(\d+)$") {
                $indent = $matches[1]
                $property = $matches[2]
                $value = $matches[3]
                
                # Simple conversion: assume 80% of parent
                $content[$lineIndex] = "$indent$property: =Parent.$property * 0.8"
                $modified = $true
                $fixCount++
            }
        }
        elseif ($violation.Type -eq "ABSOLUTE_POSITION_VALUE") {
            # Convert absolute to relative position
            $line = $content[$lineIndex]
            if ($line -match "^(\s*)(X|Y):\s*=\s*(\d+)$") {
                $indent = $matches[1]
                $property = $matches[2]
                $value = $matches[3]
                
                # Simple conversion: add to parent position
                $content[$lineIndex] = "$indent$property: =Parent.$property + 20"
                $modified = $true
                $fixCount++
            }
        }
        elseif ($violation.Type -eq "SCREEN_SIZE_PROPERTY") {
            # Remove Width/Height from screens
            $content = $content | Where-Object { $_ -ne $content[$lineIndex] }
            $modified = $true
            $fixCount++
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
        $violations = Test-RelativePositioning -FilePath $file.FullName
        
        if ($violations.Count -gt 0) {
            $filesWithViolations++
            $totalViolations += $violations.Count
            
            Write-Host "  FAIL: $($violations.Count) violations found" -ForegroundColor Red
            
            if ($Verbose) {
                foreach ($violation in $violations) {
                    Write-Host "    Line $($violation.Line): $($violation.Type) - $($violation.Message)" -ForegroundColor Yellow
                    if ($violation.Suggestion) {
                        Write-Host "      Suggestion: $($violation.Suggestion)" -ForegroundColor Cyan
                    }
                }
            }
            
            if ($FixIssues) {
                $fixCount = Fix-RelativePositioning -FilePath $file.FullName -Violations $violations
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
# MANDATORY RELATIVE POSITIONING VALIDATION REPORT

**Rules Reference:** Section 3 - Position & Size Rules  
**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  
**Script Version:** 1.0.0 (Rules-Aligned)  

## SUMMARY

- **Files checked:** $totalFiles
- **Files with violations:** $filesWithViolations
- **Total violations:** $totalViolations
- **Compliance rate:** $([math]::Round((($totalFiles - $filesWithViolations) / $totalFiles) * 100, 2))%

## RULES IMPLEMENTED

1. **Section 3.1:** Width and Height - MANDATORY RELATIVE POSITIONING
2. **Section 3.2:** X and Y Positioning - MANDATORY RELATIVE POSITIONING  
3. **Section 3.3:** Arithmetic Operations - AVOID FIXED NUMBERS
4. **Section 3.4:** Screen-Level Properties validation

## VIOLATION TYPES

- **ABSOLUTE_SIZE_VALUE:** Width/Height with absolute values (Rule 3.1)
- **ABSOLUTE_POSITION_VALUE:** X/Y with absolute values (Rule 3.2)
- **LARGE_FIXED_NUMBER:** Fixed numbers > 20 in calculations (Rule 3.3)
- **SCREEN_SIZE_PROPERTY:** Screens with Width/Height properties (Rule 3.4)

"@

if ($results.Count -gt 0) {
    $reportContent += "`n`n## VIOLATIONS BY FILE`n`n"
    
    foreach ($result in $results) {
        $reportContent += "### $($result.File)`n`n"
        foreach ($issue in $result.Issues) {
            $reportContent += "- **Line $($issue.Line):** $($issue.Type) ($($issue.Rule)) - $($issue.Message)`n"
            if ($issue.Suggestion) {
                $reportContent += "  - **Suggestion:** $($issue.Suggestion)`n"
            }
        }
        $reportContent += "`n"
    }
}

$reportPath = Join-Path $SourcePath "RELATIVE_POSITIONING_VIOLATIONS.md"
Set-Content -Path $reportPath -Value $reportContent -Encoding UTF8

Write-Host ""
Write-Host "Report saved to: $reportPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "  Files checked: $totalFiles" -ForegroundColor White
Write-Host "  Violations found: $totalViolations" -ForegroundColor $(if ($totalViolations -eq 0) { "Green" } else { "Red" })
Write-Host "  Compliance rate: $([math]::Round((($totalFiles - $filesWithViolations) / $totalFiles) * 100, 2))%" -ForegroundColor $(if ($totalViolations -eq 0) { "Green" } else { "Yellow" })

if ($totalViolations -eq 0) {
    Write-Host "`n✅ All files comply with mandatory relative positioning rules!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n❌ Found $totalViolations violations of relative positioning rules!" -ForegroundColor Red
    exit 1
} 