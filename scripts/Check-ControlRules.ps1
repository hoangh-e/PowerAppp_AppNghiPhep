# ====================================================================
# CHECK CONTROL RULES VIOLATIONS  
# Script: Check-ControlRules.ps1
# Purpose: Validate Control Rules according to Section 2 of .cursorrules
# Rules Reference: Section 2 - Control Rules
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$TargetFile = "",
    [switch]$Verbose
)

Write-Host "🔍 CONTROL RULES VALIDATION" -ForegroundColor Blue
Write-Host "============================" -ForegroundColor Blue
Write-Host "Rules Reference: Section 2 - Control Rules" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalViolations = 0
$results = @()

# Function to check control rules violations
function Check-ControlRulesViolations {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $lines = Get-Content $FilePath -Encoding UTF8
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Rule 2.1: Version Restriction - No version numbers in Control declarations
        if ($line -match "^\s*Control:\s*\w+@[\d\.]+") {
            $violations += [PSCustomObject]@{
                Rule = "2.1"
                Severity = "Error"
                Message = "FORBIDDEN: Version numbers in Control declarations"
                Line = $lineNumber
                Content = $line.Trim()
                Fix = "Remove version number from Control declaration"
            }
        }
        
        # Rule 2.2: Component Control Declarations - Must use CanvasComponent + ComponentName
        if ($line -match "^\s*Control:\s*(\w+Component)$" -and $line -notmatch "CanvasComponent") {
            $violations += [PSCustomObject]@{
                Rule = "2.2"
                Severity = "Error"
                Message = "CRITICAL: Invalid component control syntax"
                Line = $lineNumber
                Content = $line.Trim()
                Fix = "Use 'Control: CanvasComponent' + 'ComponentName: $($matches[1])'"
            }
        }
        
        # Rule 2.3: Forbidden Properties - ZIndex
        if ($line -match "^\s*ZIndex:\s*") {
            $violations += [PSCustomObject]@{
                Rule = "2.3"
                Severity = "Error"  
                Message = "FORBIDDEN: ZIndex property not supported"
                Line = $lineNumber
                Content = $line.Trim()
                Fix = "Remove ZIndex property"
            }
        }
        
        # Rule 2.4: Button-specific forbidden properties
        if ($content -match "Control:\s*Classic/Button") {
            if ($line -match "^\s*BorderRadius:\s*") {
                $violations += [PSCustomObject]@{
                    Rule = "2.4"
                    Severity = "Error"
                    Message = "FORBIDDEN: BorderRadius not supported for Classic/Button"
                    Line = $lineNumber
                    Content = $line.Trim()
                    Fix = "Remove BorderRadius property for buttons"
                }
            }
            
            if ($line -match "^\s*Disabled:\s*") {
                $violations += [PSCustomObject]@{
                    Rule = "2.4"
                    Severity = "Error"
                    Message = "FORBIDDEN: Use DisplayMode instead of Disabled for buttons"
                    Line = $lineNumber
                    Content = $line.Trim()
                    Fix = "Replace with DisplayMode property"
                }
            }
            
            if ($line -match "^\s*Align:\s*") {
                $violations += [PSCustomObject]@{
                    Rule = "2.4"
                    Severity = "Error"
                    Message = "FORBIDDEN: Align property not supported for buttons"
                    Line = $lineNumber
                    Content = $line.Trim()
                    Fix = "Remove Align property for buttons"
                }
            }
        }
        
        # Rule 2.4: Rectangle-specific forbidden properties
        if ($content -match "Control:\s*Rectangle") {
            if ($line -match "^\s*Radius(BottomLeft|BottomRight|TopLeft|TopRight):\s*") {
                $violations += [PSCustomObject]@{
                    Rule = "2.4"
                    Severity = "Error"
                    Message = "FORBIDDEN: Individual corner radius not supported for Rectangle"
                    Line = $lineNumber
                    Content = $line.Trim()
                    Fix = "Use BorderRadius for uniform radius"
                }
            }
        }
        
        # Rule 2.4: TextInput-specific forbidden properties
        if ($content -match "Control:\s*Classic/TextInput") {
            if ($line -match "Self\.Focused") {
                $violations += [PSCustomObject]@{
                    Rule = "2.4"
                    Severity = "Error"
                    Message = "FORBIDDEN: Use Self.Focus instead of Self.Focused for TextInput"
                    Line = $lineNumber
                    Content = $line.Trim()
                    Fix = "Replace Self.Focused with Self.Focus"
                }
            }
            
            if ($line -match "Self\.IsHovered") {
                $violations += [PSCustomObject]@{
                    Rule = "2.4"
                    Severity = "Error"
                    Message = "FORBIDDEN: Self.IsHovered not recognized, use hover events"
                    Line = $lineNumber
                    Content = $line.Trim()
                    Fix = "Use hover events instead of Self.IsHovered"
                }
            }
            
            if ($line -match "^\s*TextMode:\s*") {
                $violations += [PSCustomObject]@{
                    Rule = "2.4"
                    Severity = "Error"
                    Message = "FORBIDDEN: Use Mode instead of TextMode for Classic/TextInput"
                    Line = $lineNumber
                    Content = $line.Trim()
                    Fix = "Replace TextMode with Mode property"
                }
            }
        }
        
        # Rule 2.5: Missing required properties for positioned controls
        if ($line -match "^\s*Control:\s*(Label|Classic/Button|Classic/TextInput|Image|Rectangle|GroupContainer)$") {
            $controlSection = ""
            $hasX = $false
            $hasY = $false
            $hasWidth = $false
            $hasHeight = $false
            
            # Look ahead in Properties section
            for ($j = $i + 1; $j -lt $i + 20 -and $j -lt $lines.Count; $j++) {
                if ($lines[$j] -match "^\s*Properties:") {
                    $controlSection = "Properties"
                }
                if ($controlSection -eq "Properties") {
                    if ($lines[$j] -match "^\s*X:\s*") { $hasX = $true }
                    if ($lines[$j] -match "^\s*Y:\s*") { $hasY = $true }
                    if ($lines[$j] -match "^\s*Width:\s*") { $hasWidth = $true }
                    if ($lines[$j] -match "^\s*Height:\s*") { $hasHeight = $true }
                }
                # Stop if we hit next control or section
                if ($lines[$j] -match "^\s*-\s*\w+:" -or $lines[$j] -match "^\s*Children:") {
                    break
                }
            }
            
            if ($controlSection -eq "Properties") {
                if (-not $hasX) {
                    $violations += [PSCustomObject]@{
                        Rule = "2.5"
                        Severity = "Warning"
                        Message = "MISSING: X position property required for positioned controls"
                        Line = $lineNumber
                        Content = $line.Trim()
                        Fix = "Add X property with relative positioning"
                    }
                }
                if (-not $hasY) {
                    $violations += [PSCustomObject]@{
                        Rule = "2.5"
                        Severity = "Warning"
                        Message = "MISSING: Y position property required for positioned controls"
                        Line = $lineNumber
                        Content = $line.Trim()
                        Fix = "Add Y property with relative positioning"
                    }
                }
                if (-not $hasWidth) {
                    $violations += [PSCustomObject]@{
                        Rule = "2.5"
                        Severity = "Warning"
                        Message = "MISSING: Width property required for positioned controls"
                        Line = $lineNumber
                        Content = $line.Trim()
                        Fix = "Add Width property with relative sizing"
                    }
                }
                if (-not $hasHeight) {
                    $violations += [PSCustomObject]@{
                        Rule = "2.5"
                        Severity = "Warning"
                        Message = "MISSING: Height property required for positioned controls"
                        Line = $lineNumber
                        Content = $line.Trim()
                        Fix = "Add Height property with relative sizing"
                    }
                }
            }
        }
    }
    
    return $violations
}

# Main processing
if ($TargetFile) {
    $yamlFiles = @(Get-Item $TargetFile)
} else {
    $yamlFiles = Get-ChildItem -Path $SourcePath -Recurse -Include "*.yaml", "*.yml" | Where-Object { !$_.PSIsContainer }
}

Write-Host "Found $($yamlFiles.Count) YAML files to check" -ForegroundColor Yellow
Write-Host ""

foreach ($file in $yamlFiles) {
    $totalFiles++
    Write-Host "Checking: $($file.Name)" -ForegroundColor White
    
    try {
        $violations = Check-ControlRulesViolations -FilePath $file.FullName
        $fileViolations = $violations.Count
        $totalViolations += $fileViolations
        
        if ($fileViolations -gt 0) {
            Write-Host "  VIOLATIONS: $fileViolations" -ForegroundColor Red
            
            if ($Verbose) {
                foreach ($violation in $violations) {
                    $color = switch ($violation.Severity) {
                        "Error" { "Red" }
                        "Warning" { "Yellow" }
                        default { "Gray" }
                    }
                    Write-Host "    [$($violation.Rule)] $($violation.Message)" -ForegroundColor $color
                    Write-Host "      Line $($violation.Line): $($violation.Content)" -ForegroundColor Gray
                    Write-Host "      Fix: $($violation.Fix)" -ForegroundColor Cyan
                }
            }
            
            $results += [PSCustomObject]@{
                File = $file.Name
                Path = $file.FullName
                Violations = $fileViolations
                Rules = ($violations | Group-Object Rule | ForEach-Object { "$($_.Name)($($_.Count))" }) -join ", "
            }
        } else {
            Write-Host "  PASS: No violations" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  ERROR: Failed to check file - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Summary
Write-Host ""
Write-Host "=" * 50 -ForegroundColor Blue
Write-Host "CONTROL RULES SUMMARY:" -ForegroundColor Blue
Write-Host "  Files checked: $totalFiles" -ForegroundColor White
Write-Host "  Total violations: $totalViolations" -ForegroundColor $(if ($totalViolations -eq 0) { 'Green' } else { 'Red' })

if ($totalViolations -gt 0) {
    $complianceRate = [math]::Round(((($totalFiles * 10) - $totalViolations) / ($totalFiles * 10)) * 100, 1)
    Write-Host "  Compliance rate: $complianceRate%" -ForegroundColor $(if ($complianceRate -ge 90) { 'Green' } elseif ($complianceRate -ge 70) { 'Yellow' } else { 'Red' })
    
    Write-Host ""
    Write-Host "FILES WITH VIOLATIONS:" -ForegroundColor Red
    foreach ($result in $results) {
        Write-Host "  $($result.File) ($($result.Violations) violations) - Rules: $($result.Rules)" -ForegroundColor Red
    }
}

Write-Host ""
if ($totalViolations -eq 0) {
    Write-Host "✅ All control rules validation passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ Found $totalViolations control rules violations that need fixing" -ForegroundColor Red
    Write-Host "💡 Run Fix-ControlRules.ps1 to auto-fix these issues" -ForegroundColor Cyan
    exit 1
} 