# ====================================================================
# NAMING CONVENTIONS VALIDATION (RULES-COMPLIANT)
# Script: Check-NamingConventions.ps1
# Purpose: Validate naming conventions according to Section 7
# Rules Reference: Section 7 - Naming Conventions
# Author: AI Assistant (Rules-Based Implementation)
# Date: 2024-12-19
# Version: 2.0.0 (Clean Slate)
# ====================================================================

param(
    [string]$SourcePath = "src",
    [switch]$FixIssues,
    [switch]$Verbose
)

Write-Host "📝 NAMING CONVENTIONS VALIDATION (RULES-COMPLIANT)" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Rules Reference: Section 7 - Naming Conventions" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalViolations = 0
$filesWithViolations = 0
$results = @()

# Section 7.1: Special Character Handling
function Test-SpecialCharacterHandling {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $lines = Get-Content $FilePath
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Rule 7.1: Names with special characters must be wrapped in single quotes
        if ($line -match "^\s*-\s*([^']+[.\s\-]+[^']*):$") {
            $controlName = $matches[1]
            
            # Check if name contains special characters but not wrapped in quotes
            if ($controlName -match "[.\s\-]" -and $controlName -notmatch "^'.*'$") {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "MISSING_QUOTES_FOR_SPECIAL_CHARS"
                    Rule = "Section 7.1"
                    Message = "Control name '$controlName' contains special characters and must be wrapped in single quotes"
                    Property = "ControlName"
                    Content = $line.Trim()
                    Suggestion = "- '$controlName':"
                }
            }
        }
        
        # Check for control references without quotes
        if ($line -match "=([A-Za-z][A-Za-z0-9]*[.\s\-][A-Za-z0-9.\s\-]*)[.]") {
            $controlRef = $matches[1]
            
            if ($controlRef -notmatch "^'.*'$") {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "CONTROL_REFERENCE_NEEDS_QUOTES"
                    Rule = "Section 7.1 & 8.12"
                    Message = "Control reference '$controlRef' with dots must be wrapped in single quotes"
                    Property = "ControlReference"
                    Content = $line.Trim()
                    Suggestion = "Use: '$controlRef'.Property"
                }
            }
        }
        
        # Rule 7.1: Simple names should not have unnecessary quotes
        if ($line -match "^\s*-\s*'([A-Za-z][A-Za-z0-9]*)':\s*$") {
            $simpleName = $matches[1]
            
            # Check if name is simple (no special characters)
            if ($simpleName -notmatch "[.\s\-]") {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "UNNECESSARY_QUOTES"
                    Rule = "Section 7.1"
                    Message = "Simple name '$simpleName' does not need quotes"
                    Property = "ControlName"
                    Content = $line.Trim()
                    Suggestion = "- ${simpleName}:"
                }
            }
        }
    }
    
    return $violations
}

# Section 7.2: Naming Best Practices
function Test-NamingBestPractices {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $lines = Get-Content $FilePath
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Rule 7.2: Use descriptive, hierarchical names
        if ($line -match "^\s*-\s*'?([^':\s]+)'?:\s*$") {
            $controlName = $matches[1]
            
            # Check for generic/poor naming patterns
            $poorNames = @("Control1", "Control2", "Button1", "Button2", "Label1", "Label2", "TextInput1", "Container1")
            
            if ($controlName -in $poorNames) {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "POOR_NAMING_PATTERN"
                    Rule = "Section 7.2"
                    Message = "Use descriptive, hierarchical names instead of generic '$controlName'"
                    Property = "ControlName"
                    Content = $line.Trim()
                    Suggestion = "Use: Header.UserInfo.Avatar, LoginForm.UsernameInput, etc."
                }
            }
            
            # Check for good hierarchical naming patterns
            if ($controlName -match "^[A-Z][a-z]+\.[A-Z][a-z]+$" -or $controlName -match "^[A-Z][a-z]+\.[A-Z][a-z]+\.[A-Z][a-z]+$") {
                # Good hierarchical naming - no violation
            } else {
                # Check if it's a reasonable single-level name
                if ($controlName.Length -lt 5 -and $controlName -notmatch "^[A-Z][a-z]+[A-Z][a-z]+") {
                    $violations += [PSCustomObject]@{
                        Line = $lineNumber
                        Type = "NON_DESCRIPTIVE_NAME"
                        Rule = "Section 7.2"
                        Message = "Name '$controlName' is too short or not descriptive enough"
                        Property = "ControlName"
                        Content = $line.Trim()
                        Suggestion = "Use descriptive names like: LoginButton, UserProfileCard, NavigationMenu"
                    }
                }
            }
        }
    }
    
    return $violations
}

function Fix-NamingConventions {
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
        
        switch ($violation.Type) {
            "MISSING_QUOTES_FOR_SPECIAL_CHARS" {
                if ($lineIndex -lt $content.Count) {
                    $content[$lineIndex] = $violation.Suggestion
                    $modified = $true
                    $fixCount++
                }
            }
            "UNNECESSARY_QUOTES" {
                if ($lineIndex -lt $content.Count) {
                    $content[$lineIndex] = $violation.Suggestion
                    $modified = $true
                    $fixCount++
                }
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
        $allViolations = @()
        
        # Run all naming convention validations
        $allViolations += Test-SpecialCharacterHandling -FilePath $file.FullName
        $allViolations += Test-NamingBestPractices -FilePath $file.FullName
        
        if ($allViolations.Count -gt 0) {
            $filesWithViolations++
            $totalViolations += $allViolations.Count
            
            Write-Host "  FAIL: $($allViolations.Count) violations found" -ForegroundColor Red
            
            if ($Verbose) {
                foreach ($violation in $allViolations) {
                    Write-Host "    Line $($violation.Line): $($violation.Type) - $($violation.Message)" -ForegroundColor Yellow
                }
            }
            
            if ($FixIssues) {
                $fixCount = Fix-NamingConventions -FilePath $file.FullName -Violations $allViolations
                if ($fixCount -gt 0) {
                    Write-Host "  FIXED: $fixCount violations" -ForegroundColor Green
                }
            }
            
            $results += [PSCustomObject]@{
                File = $file.Name
                Path = $file.FullName
                Violations = $allViolations.Count
                Issues = $allViolations
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
# NAMING CONVENTIONS VALIDATION REPORT

**Rules Reference:** Section 7 - Naming Conventions  
**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  
**Script Version:** 2.0.0 (Clean Slate)  

## SUMMARY

- **Files checked:** $totalFiles
- **Files with violations:** $filesWithViolations
- **Total violations:** $totalViolations
- **Compliance rate:** $([math]::Round((($totalFiles - $filesWithViolations) / $totalFiles) * 100, 2))%

## RULES IMPLEMENTED

1. **Section 7.1:** Special character handling (single quotes requirement)
2. **Section 7.2:** Naming best practices (descriptive, hierarchical names)

## VIOLATION TYPES

- **MISSING_QUOTES_FOR_SPECIAL_CHARS:** Names with special characters not wrapped in quotes
- **UNNECESSARY_QUOTES:** Simple names with unnecessary quotes
- **CONTROL_REFERENCE_NEEDS_QUOTES:** Control references with dots need quotes
- **POOR_NAMING_PATTERN:** Generic names like Control1, Button1
- **NON_DESCRIPTIVE_NAME:** Names too short or not descriptive enough

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

$reportPath = Join-Path $SourcePath "NAMING_CONVENTIONS_VIOLATIONS.md"
Set-Content -Path $reportPath -Value $reportContent -Encoding UTF8

Write-Host ""
Write-Host "Report saved to: $reportPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "  Files checked: $totalFiles" -ForegroundColor White
Write-Host "  Violations found: $totalViolations" -ForegroundColor $(if ($totalViolations -eq 0) { "Green" } else { "Red" })
Write-Host "  Compliance rate: $([math]::Round((($totalFiles - $filesWithViolations) / $totalFiles) * 100, 2))%" -ForegroundColor $(if ($totalViolations -eq 0) { "Green" } else { "Yellow" })

if ($totalViolations -eq 0) {
    Write-Host "`n✅ All files comply with naming conventions!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n❌ Found $totalViolations violations of naming conventions!" -ForegroundColor Red
    exit 1
} 