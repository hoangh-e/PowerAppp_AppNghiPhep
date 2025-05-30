# ====================================================================
# FILE STRUCTURE VALIDATION (RULES-COMPLIANT)
# Script: Check-FileStructure.ps1
# Purpose: Validate Power App file structure according to Section 1
# Rules Reference: Section 1 - File Structure
# Author: AI Assistant (Rules-Based Implementation)
# Date: 2024-12-19
# Version: 2.0.0 (Clean Slate)
# ====================================================================

param(
    [string]$SourcePath = "src",
    [switch]$FixIssues,
    [switch]$Verbose
)

Write-Host "🏗️ FILE STRUCTURE VALIDATION (RULES-COMPLIANT)" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "Rules Reference: Section 1 - File Structure" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalViolations = 0
$filesWithViolations = 0
$results = @()

# Section 1.1: Screens Structure Validation
function Test-ScreenStructure {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    
    # Rule 1.1: All screen files MUST start with "Screens:"
    if ($content -match "Properties:" -and $content -match "Children:" -and $content -notmatch "^Screens:") {
        $violations += [PSCustomObject]@{
            Line = 1
            Type = "MISSING_SCREENS_ROOT"
            Rule = "Section 1.1"
            Message = "Screen file must start with 'Screens:' root element"
            Property = "File Structure"
            Content = $lines[0]
            Suggestion = "Add 'Screens:' as the first line"
        }
    }
    
    # Rule 1.1: Screen properties validation
    if ($content -match "^Screens:") {
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            $lineNumber = $i + 1
            
            # Check for required screen properties
            if ($line -match "^\s+Properties:" -and $i + 5 -lt $lines.Count) {
                $hasValidFill = $false
                
                # Look ahead for Fill property
                for ($j = $i + 1; $j -lt $i + 10 -and $j -lt $lines.Count; $j++) {
                    if ($lines[$j] -match "^\s+Fill:\s*=RGBA\(") {
                        $hasValidFill = $true
                        break
                    }
                }
                
                if (-not $hasValidFill) {
                    $violations += [PSCustomObject]@{
                        Line = $lineNumber
                        Type = "MISSING_SCREEN_FILL"
                        Rule = "Section 1.1"
                        Message = "Screen Properties must include Fill with RGBA format"
                        Property = "Fill"
                        Content = $line.Trim()
                        Suggestion = "Fill: =RGBA(248, 250, 252, 1)"
                    }
                }
            }
        }
    }
    
    return $violations
}

# Section 1.2: Component Structure Validation
function Test-ComponentStructure {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    
    # Rule 1.2: Components must use correct structure
    if ($content -match "DefinitionType:\s*CanvasComponent") {
        
        # Check for correct root structure
        if ($content -notmatch "^ComponentDefinitions:") {
            $violations += [PSCustomObject]@{
                Line = 1
                Type = "WRONG_COMPONENT_ROOT"
                Rule = "Section 1.2"
                Message = "Component file must start with 'ComponentDefinitions:' (plural)"
                Property = "File Structure"
                Content = $lines[0]
                Suggestion = "Use 'ComponentDefinitions:' instead of 'ComponentDefinition:'"
            }
        }
        
        # Check for old/invalid custom property structure
        if ($content -match "PropertyType:|PropertyDataType:|DefaultValue:") {
            for ($i = 0; $i -lt $lines.Count; $i++) {
                $line = $lines[$i]
                $lineNumber = $i + 1
                
                if ($line -match "\s*(PropertyType|PropertyDataType|DefaultValue):") {
                    $oldProperty = $matches[1]
                    $newProperty = switch ($oldProperty) {
                        "PropertyType" { "PropertyKind" }
                        "PropertyDataType" { "DataType" }
                        "DefaultValue" { "Default" }
                    }
                    
                    $violations += [PSCustomObject]@{
                        Line = $lineNumber
                        Type = "OLD_CUSTOM_PROPERTY_SYNTAX"
                        Rule = "Section 1.2"
                        Message = "Use new syntax: '$newProperty' instead of '$oldProperty'"
                        Property = $oldProperty
                        Content = $line.Trim()
                        Suggestion = $line -replace $oldProperty, $newProperty
                    }
                }
            }
        }
    }
    
    return $violations
}

# Section 1.3-1.5: Custom Properties Validation
function Test-CustomProperties {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    
    # Valid data types from Section 1.3
    $validDataTypes = @(
        "Text", "Number", "Boolean", "Date and time", "Screen", 
        "Record", "Table", "Image", "Video or audio", "Color", "Currency"
    )
    
    # Valid property kinds from Section 1.4
    $validPropertyKinds = @("Input", "Output", "Event")
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Check DataType values
        if ($line -match "DataType:\s*(.+)") {
            $dataType = $matches[1].Trim()
            if ($dataType -notin $validDataTypes) {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "INVALID_DATA_TYPE"
                    Rule = "Section 1.3"
                    Message = "Invalid DataType '$dataType'. Must be one of: $($validDataTypes -join ', ')"
                    Property = "DataType"
                    Content = $line.Trim()
                    Suggestion = "Use valid DataType from Section 1.3"
                }
            }
        }
        
        # Check PropertyKind values
        if ($line -match "PropertyKind:\s*(.+)") {
            $propertyKind = $matches[1].Trim()
            if ($propertyKind -notin $validPropertyKinds) {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "INVALID_PROPERTY_KIND"
                    Rule = "Section 1.4"
                    Message = "Invalid PropertyKind '$propertyKind'. Must be one of: $($validPropertyKinds -join ', ')"
                    Property = "PropertyKind"
                    Content = $line.Trim()
                    Suggestion = "Use: Input, Output, or Event"
                }
            }
        }
        
        # Rule 1.5: Event properties must have correct structure
        if ($line -match "PropertyKind:\s*Event" -and $i + 10 -lt $lines.Count) {
            $hasReturnType = $false
            $hasDefault = $false
            
            # Look ahead for required event properties
            for ($j = $i + 1; $j -lt $i + 15 -and $j -lt $lines.Count; $j++) {
                if ($lines[$j] -match "^\s*ReturnType:") {
                    $hasReturnType = $true
                }
                if ($lines[$j] -match "^\s*Default:\s*=") {
                    $hasDefault = $true
                }
            }
            
            if (-not $hasReturnType) {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "MISSING_EVENT_RETURN_TYPE"
                    Rule = "Section 1.5"
                    Message = "Event properties must include ReturnType"
                    Property = "ReturnType"
                    Content = $line.Trim()
                    Suggestion = "Add: ReturnType: None"
                }
            }
            
            if (-not $hasDefault) {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "MISSING_EVENT_DEFAULT"
                    Rule = "Section 1.5"
                    Message = "Event properties must include Default"
                    Property = "Default"
                    Content = $line.Trim()
                    Suggestion = "Add: Default: ="
                }
            }
        }
    }
    
    return $violations
}

function Fix-FileStructure {
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
        
        switch ($violation.Type) {
            "MISSING_SCREENS_ROOT" {
                $content = @("Screens:") + $content
                $modified = $true
                $fixCount++
            }
            "OLD_CUSTOM_PROPERTY_SYNTAX" {
                if ($lineIndex -lt $content.Count) {
                    $content[$lineIndex] = $violation.Suggestion
                    $modified = $true
                    $fixCount++
                }
            }
            "WRONG_COMPONENT_ROOT" {
                if ($lineIndex -lt $content.Count) {
                    $content[$lineIndex] = $content[$lineIndex] -replace "ComponentDefinition:", "ComponentDefinitions:"
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
        
        # Run all structure validations
        $allViolations += Test-ScreenStructure -FilePath $file.FullName
        $allViolations += Test-ComponentStructure -FilePath $file.FullName
        $allViolations += Test-CustomProperties -FilePath $file.FullName
        
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
                $fixCount = Fix-FileStructure -FilePath $file.FullName -Violations $allViolations
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
# FILE STRUCTURE VALIDATION REPORT

**Rules Reference:** Section 1 - File Structure  
**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  
**Script Version:** 2.0.0 (Clean Slate)  

## SUMMARY

- **Files checked:** $totalFiles
- **Files with violations:** $filesWithViolations
- **Total violations:** $totalViolations
- **Compliance rate:** $([math]::Round((($totalFiles - $filesWithViolations) / $totalFiles) * 100, 2))%

## RULES IMPLEMENTED

1. **Section 1.1:** Screen structure validation
2. **Section 1.2:** Component structure validation  
3. **Section 1.3:** Custom properties data types
4. **Section 1.4:** Custom property kinds
5. **Section 1.5:** Event properties structure

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

$reportPath = Join-Path $SourcePath "FILE_STRUCTURE_VIOLATIONS.md"
Set-Content -Path $reportPath -Value $reportContent -Encoding UTF8

Write-Host ""
Write-Host "Report saved to: $reportPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "  Files checked: $totalFiles" -ForegroundColor White
Write-Host "  Violations found: $totalViolations" -ForegroundColor $(if ($totalViolations -eq 0) { "Green" } else { "Red" })
Write-Host "  Compliance rate: $([math]::Round((($totalFiles - $filesWithViolations) / $totalFiles) * 100, 2))%" -ForegroundColor $(if ($totalViolations -eq 0) { "Green" } else { "Yellow" })

if ($totalViolations -eq 0) {
    Write-Host "`n✅ All files comply with file structure rules!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n❌ Found $totalViolations violations of file structure rules!" -ForegroundColor Red
    exit 1
} 