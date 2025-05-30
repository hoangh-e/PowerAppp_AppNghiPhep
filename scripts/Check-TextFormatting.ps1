# ====================================================================
# CHECK TEXT FORMATTING VIOLATIONS
# Script: Check-TextFormatting.ps1
# Purpose: Validate Text Formatting according to Section 5.6 of .cursorrules
# Rules Reference: Section 5.6 - Text Formatting & Section 8.18 - Text Function with RGBA
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$TargetFile = "",
    [switch]$Verbose
)

Write-Host "📝 TEXT FORMATTING VALIDATION" -ForegroundColor Blue
Write-Host "=============================" -ForegroundColor Blue
Write-Host "Rules Reference: Section 5.6 - Text Formatting" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalViolations = 0
$results = @()

function Check-TextFormattingViolations {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $lines = Get-Content -Path $FilePath -Encoding UTF8
    
    # Rule 5.6: Check for wrong text concatenation formatting
    # Pattern: "Label: " & Value should be "Label:" & " " & Value
    $wrongConcatMatches = [regex]::Matches($content, 'Text`:\s*=.*?"([^"]*:\s+)"\s*&\s*([^&\n]+)')
    foreach ($match in $wrongConcatMatches) {
        $wrongPart = $match.Groups[1].Value
        $lineNumber = ($lines | Select-String -Pattern [regex]::Escape($match.Value) | Select-Object -First 1).LineNumber
        
        if ($wrongPart -match ':\s+$') {
            # Extract the label part before the colon
            $label = $wrongPart -replace ':\s+$', ''
            $violations += @{
                Rule = "5.6"
                Type = "Wrong Text Concatenation"
                Line = $lineNumber
                Issue = "Space after colon in quoted string"
                Current = "`"$wrongPart`""
                Suggested = "`"$label`:`" & `" `""
                Severity = "Medium"
            }
        }
    }
    
    # Rule 5.6: Check for direct text with colon and space (not concatenated)
    $directTextMatches = [regex]::Matches($content, 'Text`:\s*=.*?"([^"]*:\s[^"]*)"')
    foreach ($match in $directTextMatches) {
        $textContent = $match.Groups[1].Value
        $lineNumber = ($lines | Select-String -Pattern [regex]::Escape($match.Value) | Select-Object -First 1).LineNumber
        
        if ($textContent -match '^([^:]+):\s(.+)$') {
            $label = $matches[1]
            $value = $matches[2]
            $violations += @{
                Rule = "5.6"
                Type = "Direct Text with Colon Space"
                Line = $lineNumber
                Issue = "Direct text with colon and space should be concatenated"
                Current = "`"$textContent`""
                Suggested = "`"$label`:`" & `" `" & `"$value`""
                Severity = "Medium"
            }
        }
    }
    
    # Rule 8.18: Check for Text() function with RGBA values
    $rgbaTextMatches = [regex]::Matches($content, 'Text\s*\(\s*RGBA\s*\([^)]+\)\s*\)')
    foreach ($match in $rgbaTextMatches) {
        $lineNumber = ($lines | Select-String -Pattern [regex]::Escape($match.Value) | Select-Object -First 1).LineNumber
        $violations += @{
            Rule = "8.18"
            Type = "Text Function with RGBA"
            Line = $lineNumber
            Issue = "Text() function cannot convert RGBA values"
            Current = $match.Value
            Suggested = "Use string literal instead: `"RGBA(...)`""
            Severity = "Critical"
        }
    }
    
    # Rule 8.18: Check for Concatenate with Text(RGBA(...))
    $concatRgbaMatches = [regex]::Matches($content, 'Concatenate\s*\([^,]+,\s*Text\s*\(\s*RGBA\s*\([^)]+\)\s*\)\s*\)')
    foreach ($match in $concatRgbaMatches) {
        $lineNumber = ($lines | Select-String -Pattern [regex]::Escape($match.Value) | Select-Object -First 1).LineNumber
        $violations += @{
            Rule = "8.18"
            Type = "Concatenate with Text(RGBA)"
            Line = $lineNumber
            Issue = "Concatenate with Text(RGBA(...)) is invalid"
            Current = $match.Value
            Suggested = "Use string literal: Concatenate(..., `"RGBA(...)`")"
            Severity = "Critical"
        }
    }
    
    # Additional check: Common text formatting patterns that should be improved
    $commonPatterns = @{
        '"Email: "' = '"Email:" & " "'
        '"Status: "' = '"Status:" & " "'
        '"Name: "' = '"Name:" & " "'
        '"Date: "' = '"Date:" & " "'
        '"Time: "' = '"Time:" & " "'
        '"User: "' = '"User:" & " "'
        '"Role: "' = '"Role:" & " "'
        '"Department: "' = '"Department:" & " "'
        '"Phone: "' = '"Phone:" & " "'
        '"Address: "' = '"Address:" & " "'
    }
    
    foreach ($pattern in $commonPatterns.Keys) {
        $suggestion = $commonPatterns[$pattern]
        if ($content -match [regex]::Escape($pattern)) {
            $lineNumbers = ($lines | Select-String -Pattern [regex]::Escape($pattern) | ForEach-Object { $_.LineNumber })
            foreach ($lineNumber in $lineNumbers) {
                $violations += @{
                    Rule = "5.6"
                    Type = "Common Text Pattern"
                    Line = $lineNumber
                    Issue = "Common text pattern should use proper concatenation"
                    Current = $pattern
                    Suggested = $suggestion
                    Severity = "Low"
                }
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
    $violations = Check-TextFormattingViolations -FilePath $file
    
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
                "Low" { "Gray" }
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
Write-Host "TEXT FORMATTING VALIDATION SUMMARY" -ForegroundColor Blue
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
            "Low" { "Gray" }
            default { "Gray" }
        }
        Write-Host "  $($severity.Name): $($severity.Count)" -ForegroundColor $color
    }
    
    Write-Host ""
    Write-Host "💡 Run Fix-TextFormatting.ps1 to auto-fix these violations" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "✅ No text formatting violations found!" -ForegroundColor Green
}

exit $totalViolations 