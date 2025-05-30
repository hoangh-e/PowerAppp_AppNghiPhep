# ====================================================================
# POSITION & SIZE RULES VALIDATION (RULES-COMPLIANT)
# Script: Check-PositionSizeRules.ps1
# Purpose: Validate positioning and sizing according to Section 3
# Rules Reference: Section 3 - Position & Size Rules  
# Author: AI Assistant (Rules-Based Implementation)
# Date: 2024-12-19
# Version: 2.0.0 (Clean Slate)
# ====================================================================

param(
    [string]$SourcePath = "src",
    [switch]$FixIssues,
    [switch]$Verbose
)

Write-Host "📐 POSITION & SIZE RULES VALIDATION (RULES-COMPLIANT)" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "Rules Reference: Section 3 - Position & Size Rules" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalViolations = 0
$filesWithViolations = 0
$results = @()

# Section 3.1: Width and Height - MANDATORY RELATIVE POSITIONING
function Test-RelativeSizing {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $lines = Get-Content $FilePath
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Rule 3.1: Never use absolute values for Width and Height
        if ($line -match "^\s*(Width|Height):\s*=?\s*(\d+)$") {
            $property = $matches[1]
            $value = $matches[2]
            
            $violations += [PSCustomObject]@{
                Line = $lineNumber
                Type = "ABSOLUTE_SIZE_VALUE"
                Rule = "Section 3.1"
                Message = "$property uses absolute value ($value) - must be relative"
                Property = $property
                Content = $line.Trim()
                Suggestion = "$property = Parent.$property * 0.8"
            }
        }
        
        # Rule 3.1: Check for invalid absolute values with equals sign
        if ($line -match "^\s*(Width|Height):\s*=\s*(\d+)$") {
            $property = $matches[1]
            $value = $matches[2]
            
            $violations += [PSCustomObject]@{
                Line = $lineNumber
                Type = "ABSOLUTE_SIZE_WITH_FORMULA"
                Rule = "Section 3.1"
                Message = "$property has absolute value in formula ($value) - must reference parent or controls"
                Property = $property
                Content = $line.Trim()
                Suggestion = "$property = Parent.$property * 0.8"
            }
        }
    }
    
    return $violations
}

# Section 3.2: X and Y Positioning - MANDATORY RELATIVE POSITIONING  
function Test-RelativePositioning {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $lines = Get-Content $FilePath
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Rule 3.2: Never use absolute values for X and Y
        if ($line -match "^\s*(X|Y):\s*=?\s*(\d+)$") {
            $property = $matches[1]
            $value = $matches[2]
            
            $violations += [PSCustomObject]@{
                Line = $lineNumber
                Type = "ABSOLUTE_POSITION_VALUE"
                Rule = "Section 3.2"
                Message = "$property uses absolute value ($value) - must be relative"
                Property = $property
                Content = $line.Trim()
                Suggestion = "$property = Parent.$property + 20"
            }
        }
        
        # Rule 3.2: Check for absolute positions in formulas
        if ($line -match "^\s*(X|Y):\s*=\s*(\d+)$") {
            $property = $matches[1]
            $value = $matches[2]
            
            $violations += [PSCustomObject]@{
                Line = $lineNumber
                Type = "ABSOLUTE_POSITION_WITH_FORMULA"
                Rule = "Section 3.2"
                Message = "$property has absolute value in formula ($value) - must reference parent or controls"
                Property = $property
                Content = $line.Trim()
                Suggestion = "$property = Parent.$property + 20"
            }
        }
    }
    
    return $violations
}

# Section 3.3: Arithmetic Operations - AVOID FIXED NUMBERS
function Test-FixedNumbers {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $lines = Get-Content $FilePath
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Rule 3.3: Discourage large fixed numbers in calculations
        if ($line -match "^\s*(Width|Height|X|Y|Size):\s*=.*[+\-]\s*(\d{2,})") {
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
                    Suggestion = "Use percentage-based calculations: Parent.$property * 0.1"
                }
            }
        }
        
        # Rule 3.3: Check for pure fixed values (wrong pattern)
        if ($line -match "^\s*(Width|Height|X|Y):\s*=\s*(\d{3,})$") {
            $property = $matches[1]
            $value = $matches[2]
            
            $violations += [PSCustomObject]@{
                Line = $lineNumber
                Type = "PURE_FIXED_VALUE"
                Rule = "Section 3.3"
                Message = "$property has pure fixed value ($value) - wrong pattern"
                Property = $property
                Content = $line.Trim()
                Suggestion = "$property = Parent.$property * 0.8"
            }
        }
        
        # Rule 3.3: Encourage relative calculations over fixed numbers
        if ($line -match "^\s*(Width|Height|X|Y):\s*=.*[+\-]\s*(\d+)" -and $line -notmatch "Parent\.|Self\.|Control\.") {
            $property = $matches[1]
            $number = $matches[2]
            
            if ([int]$number -gt 10) {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "DISCOURAGED_FIXED_CALCULATION"
                    Rule = "Section 3.3"
                    Message = "$property calculation uses fixed number without relative reference - prefer relative"
                    Property = $property
                    Content = $line.Trim()
                    Suggestion = "Add relative reference: Parent.$property + ControlRef.Height"
                }
            }
        }
    }
    
    return $violations
}

# Section 3.4: Screen-Level Properties
function Test-ScreenProperties {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    
    # Rule 3.4: Screens should not have Width/Height properties
    if ($content -match "^Screens:") {
        $inScreen = $false
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            $lineNumber = $i + 1
            
            # Track if we're in a screen definition
            if ($line -match "^\s+\w+:$" -and $line -notmatch "^\s+(Properties|Children):") {
                $inScreen = $true
            } elseif ($line -match "^Screens:" -or $line -match "^\w+:") {
                $inScreen = $false
            }
            
            # Check for forbidden screen properties
            if ($inScreen -and $line -match "^\s+(Width|Height):\s*=") {
                $property = $matches[1]
                
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "SCREEN_SIZE_PROPERTY"
                    Rule = "Section 3.4"
                    Message = "Screen should not have $property property - automatically handled by Power Apps"
                    Property = $property
                    Content = $line.Trim()
                    Suggestion = "Remove $property property from screen"
                }
            }
            
            # Rule 3.4: Screens should use Fill property
            if ($inScreen -and $line -match "^\s+Properties:") {
                $hasFill = $false
                
                # Look ahead for Fill property
                for ($j = $i + 1; $j -lt $i + 10 -and $j -lt $lines.Count; $j++) {
                    if ($lines[$j] -match "^\s+Fill:\s*=RGBA\(") {
                        $hasFill = $true
                        break
                    }
                }
                
                if (-not $hasFill) {
                    $violations += [PSCustomObject]@{
                        Line = $lineNumber
                        Type = "MISSING_SCREEN_FILL"
                        Rule = "Section 3.4"
                        Message = "Screen Properties should include Fill with RGBA format"
                        Property = "Fill"
                        Content = $line.Trim()
                        Suggestion = "Add: Fill = RGBA(248, 250, 252, 1)"
                    }
                }
            }
        }
    }
    
    return $violations
}

function Fix-PositionSizeRules {
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
            "ABSOLUTE_SIZE_VALUE" {
                if ($lineIndex -lt $content.Count) {
                    $line = $content[$lineIndex]
                    if ($line -match "^(\s*)(Width|Height):\s*=?\s*\d+$") {
                        $indent = $matches[1]
                        $property = $matches[2]
                        $content[$lineIndex] = "$indent$property = Parent.$property * 0.8"
                        $modified = $true
                        $fixCount++
                    }
                }
            }
            "ABSOLUTE_POSITION_VALUE" {
                if ($lineIndex -lt $content.Count) {
                    $line = $content[$lineIndex]
                    if ($line -match "^(\s*)(X|Y):\s*=?\s*\d+$") {
                        $indent = $matches[1]
                        $property = $matches[2]
                        $content[$lineIndex] = "$indent$property = Parent.$property + 20"
                        $modified = $true
                        $fixCount++
                    }
                }
            }
            "SCREEN_SIZE_PROPERTY" {
                # Remove Width/Height from screens
                $content = $content | Where-Object { $_ -ne $content[$lineIndex] }
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
        $allViolations = @()
        
        # Run all position/size validations
        $allViolations += Test-RelativeSizing -FilePath $file.FullName
        $allViolations += Test-RelativePositioning -FilePath $file.FullName
        $allViolations += Test-FixedNumbers -FilePath $file.FullName
        $allViolations += Test-ScreenProperties -FilePath $file.FullName
        
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
                $fixCount = Fix-PositionSizeRules -FilePath $file.FullName -Violations $allViolations
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
# POSITION & SIZE RULES VALIDATION REPORT

**Rules Reference:** Section 3 - Position & Size Rules  
**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  
**Script Version:** 2.0.0 (Clean Slate)  

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

- **ABSOLUTE_SIZE_VALUE:** Width/Height with absolute values
- **ABSOLUTE_POSITION_VALUE:** X/Y with absolute values  
- **LARGE_FIXED_NUMBER:** Fixed numbers > 20 in calculations
- **SCREEN_SIZE_PROPERTY:** Screens with Width/Height properties

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

$reportPath = Join-Path $SourcePath "POSITION_SIZE_VIOLATIONS.md"
Set-Content -Path $reportPath -Value $reportContent -Encoding UTF8

Write-Host ""
Write-Host "Report saved to: $reportPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "  Files checked: $totalFiles" -ForegroundColor White
Write-Host "  Violations found: $totalViolations" -ForegroundColor $(if ($totalViolations -eq 0) { "Green" } else { "Red" })
Write-Host "  Compliance rate: $([math]::Round((($totalFiles - $filesWithViolations) / $totalFiles) * 100, 2))%" -ForegroundColor $(if ($totalViolations -eq 0) { "Green" } else { "Yellow" })

if ($totalViolations -eq 0) {
    Write-Host "`n✅ All files comply with position & size rules!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n❌ Found $totalViolations violations of position & size rules!" -ForegroundColor Red
    exit 1
} 