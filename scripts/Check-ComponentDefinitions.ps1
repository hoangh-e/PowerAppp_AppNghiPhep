# ====================================================================
# CHECK COMPONENT DEFINITIONS VIOLATIONS
# Script: Check-ComponentDefinitions.ps1
# Purpose: Validate Component Definitions according to Section 1.2 of .cursorrules
# Rules Reference: Section 1.2 - Components (Thành phần)
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$TargetFile = "",
    [switch]$Verbose
)

Write-Host "🧩 COMPONENT DEFINITIONS VALIDATION" -ForegroundColor Blue
Write-Host "====================================" -ForegroundColor Blue
Write-Host "Rules Reference: Section 1.2 - Components" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalViolations = 0
$results = @()

function Check-ComponentDefinitionsViolations {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $lines = Get-Content -Path $FilePath -Encoding UTF8
    
    # Rule 1.2: Check for old ComponentDefinition structure (should be ComponentDefinitions)
    if ($content -match "ComponentDefinition`:\s*\n") {
        $lineNumber = ($lines | Select-String -Pattern "ComponentDefinition`:" | Select-Object -First 1).LineNumber
        $violations += @{
            Rule = "1.2"
            Type = "Wrong Component Structure"
            Line = $lineNumber
            Issue = "Using old 'ComponentDefinition:' instead of 'ComponentDefinitions:'"
            Current = "ComponentDefinition:"
            Suggested = "ComponentDefinitions:"
            Severity = "Critical"
        }
    }
    
    # Rule 1.2: Check for old custom property structure
    if ($content -match "CustomProperties`:\s*\n\s*-\s*\w+`:")  {
        $lineNumber = ($lines | Select-String -Pattern "CustomProperties`:" | Select-Object -First 1).LineNumber
        $violations += @{
            Rule = "1.2"
            Type = "Wrong Custom Properties Structure"
            Line = $lineNumber
            Issue = "Using old array format for CustomProperties"
            Current = "CustomProperties:\n  - PropertyName:"
            Suggested = "CustomProperties:\n  PropertyName:"
            Severity = "Critical"
        }
    }
    
    # Rule 1.2: Check for old property names
    $oldPropertyMappings = @{
        "PropertyType" = "PropertyKind"
        "PropertyDataType" = "DataType"
        "DefaultValue" = "Default"
    }
    
    foreach ($oldProp in $oldPropertyMappings.Keys) {
        if ($content -match "$oldProp`:") {
            $lineNumbers = ($lines | Select-String -Pattern "$oldProp`:" | ForEach-Object { $_.LineNumber })
            foreach ($lineNumber in $lineNumbers) {
                $violations += @{
                    Rule = "1.2"
                    Type = "Old Property Name"
                    Line = $lineNumber
                    Issue = "Using old property name '$oldProp'"
                    Current = "$oldProp`:"
                    Suggested = "$($oldPropertyMappings[$oldProp])`:"
                    Severity = "High"
                }
            }
        }
    }
    
    # Rule 1.2: Check for missing required custom property fields
    $requiredFields = @("PropertyKind", "DisplayName", "Description", "DataType", "Default")
    
    # Find custom properties sections
    $customPropsMatches = [regex]::Matches($content, "CustomProperties`:\s*\n((?:\s+\w+`:\s*\n(?:\s+\w+`:.*\n)*)*)")
    foreach ($match in $customPropsMatches) {
        $propsSection = $match.Groups[1].Value
        $propNames = [regex]::Matches($propsSection, "^\s+(\w+)`:\s*$", [System.Text.RegularExpressions.RegexOptions]::Multiline)
        
        foreach ($propMatch in $propNames) {
            $propName = $propMatch.Groups[1].Value
            $propSection = [regex]::Match($propsSection, "$propName`:\s*\n((?:\s+\w+`:.*\n)*)")
            
            if ($propSection.Success) {
                $propContent = $propSection.Groups[1].Value
                
                foreach ($field in $requiredFields) {
                    if ($propContent -notmatch "$field`:") {
                        $lineNumber = ($lines | Select-String -Pattern "$propName`:" | Select-Object -First 1).LineNumber
                        $violations += @{
                            Rule = "1.2"
                            Type = "Missing Required Field"
                            Line = $lineNumber
                            Issue = "Custom property '$propName' missing required field '$field'"
                            Current = "Property without $field"
                            Suggested = "Add $field`: <appropriate_value>"
                            Severity = "High"
                        }
                    }
                }
            }
        }
    }
    
    # Rule 1.2: Check for invalid data types
    $validDataTypes = @(
        "Text", "Number", "Boolean", "Date and time", "Screen", 
        "Record", "Table", "Image", "Video or audio", "Color", "Currency"
    )
    
    $dataTypeMatches = [regex]::Matches($content, "DataType`:\s*(.+)")
    foreach ($match in $dataTypeMatches) {
        $dataType = $match.Groups[1].Value.Trim()
        if ($dataType -notin $validDataTypes) {
            $lineNumber = ($lines | Select-String -Pattern "DataType`:\s*$([regex]::Escape($dataType))" | Select-Object -First 1).LineNumber
            $violations += @{
                Rule = "1.2"
                Type = "Invalid Data Type"
                Line = $lineNumber
                Issue = "Invalid DataType '$dataType'"
                Current = "DataType: $dataType"
                Suggested = "DataType: Text (or other valid type: $($validDataTypes -join ', '))"
                Severity = "High"
            }
        }
    }
    
    # Rule 1.2: Check for invalid property kinds
    $validPropertyKinds = @("Input", "Output", "Event")
    
    $propertyKindMatches = [regex]::Matches($content, "PropertyKind`:\s*(.+)")
    foreach ($match in $propertyKindMatches) {
        $propertyKind = $match.Groups[1].Value.Trim()
        if ($propertyKind -notin $validPropertyKinds) {
            $lineNumber = ($lines | Select-String -Pattern "PropertyKind`:\s*$([regex]::Escape($propertyKind))" | Select-Object -First 1).LineNumber
            $violations += @{
                Rule = "1.2"
                Type = "Invalid Property Kind"
                Line = $lineNumber
                Issue = "Invalid PropertyKind '$propertyKind'"
                Current = "PropertyKind: $propertyKind"
                Suggested = "PropertyKind: Input (or Output/Event)"
                Severity = "High"
            }
        }
    }
    
    # Rule 1.2: Check for missing component-level properties
    if ($content -match "ComponentDefinitions`:" -or $content -match "ComponentDefinition`:") {
        $hasHeight = $content -match "Properties`:\s*\n(?:[^\n]*\n)*?\s*Height`:"
        $hasWidth = $content -match "Properties`:\s*\n(?:[^\n]*\n)*?\s*Width`:"
        
        if (-not $hasHeight) {
            $violations += @{
                Rule = "1.2"
                Type = "Missing Component Property"
                Line = 1
                Issue = "Component missing required Height property"
                Current = "Component without Height"
                Suggested = "Add Height: =App.Height in Properties section"
                Severity = "High"
            }
        }
        
        if (-not $hasWidth) {
            $violations += @{
                Rule = "1.2"
                Type = "Missing Component Property"
                Line = 1
                Issue = "Component missing required Width property"
                Current = "Component without Width"
                Suggested = "Add Width: =App.Width in Properties section"
                Severity = "High"
            }
        }
    }
    
    return $violations
}

# Process files
if ($TargetFile) {
    $files = @($TargetFile)
} else {
    $files = Get-ChildItem -Path $SourcePath -Recurse -Include "*.yaml", "*.yml" | ForEach-Object { $_.FullName }
}

foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        Write-Warning "File not found: $file"
        continue
    }
    
    $totalFiles++
    $violations = Check-ComponentDefinitionsViolations -FilePath $file
    
    if ($violations.Count -gt 0) {
        $totalViolations += $violations.Count
        $results += @{
            File = $file
            Violations = $violations
        }
        
        Write-Host "📄 $file" -ForegroundColor White
        foreach ($violation in $violations) {
            $severityColor = switch ($violation.Severity) {
                "Critical" { "Red" }
                "High" { "Yellow" }
                "Medium" { "Cyan" }
                default { "Gray" }
            }
            
            Write-Host "  ❌ Line $($violation.Line): $($violation.Type)" -ForegroundColor $severityColor
            Write-Host "     Rule: $($violation.Rule) | $($violation.Issue)" -ForegroundColor Gray
            if ($Verbose) {
                Write-Host "     Current: $($violation.Current)" -ForegroundColor Red
                Write-Host "     Suggested: $($violation.Suggested)" -ForegroundColor Green
            }
        }
        Write-Host ""
    }
}

# Summary
Write-Host "=" * 60 -ForegroundColor Blue
Write-Host "COMPONENT DEFINITIONS VALIDATION SUMMARY" -ForegroundColor Blue
Write-Host "=" * 60 -ForegroundColor Blue
Write-Host ""

Write-Host "Files processed: $totalFiles" -ForegroundColor White
Write-Host "Total violations: $totalViolations" -ForegroundColor $(if ($totalViolations -eq 0) { 'Green' } else { 'Red' })

if ($totalViolations -gt 0) {
    Write-Host ""
    Write-Host "VIOLATION BREAKDOWN:" -ForegroundColor Yellow
    
    $violationTypes = $results | ForEach-Object { $_.Violations } | Group-Object Type
    foreach ($type in $violationTypes) {
        Write-Host "  $($type.Name): $($type.Count)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "SEVERITY BREAKDOWN:" -ForegroundColor Yellow
    
    $severityTypes = $results | ForEach-Object { $_.Violations } | Group-Object Severity
    foreach ($severity in $severityTypes) {
        $color = switch ($severity.Name) {
            "Critical" { "Red" }
            "High" { "Yellow" }
            "Medium" { "Cyan" }
            default { "Gray" }
        }
        Write-Host "  $($severity.Name): $($severity.Count)" -ForegroundColor $color
    }
    
    Write-Host ""
    Write-Host "💡 Run Fix-ComponentDefinitions.ps1 to auto-fix these violations" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "✅ No component definition violations found!" -ForegroundColor Green
}

exit $totalViolations 