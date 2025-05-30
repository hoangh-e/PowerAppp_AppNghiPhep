# ====================================================================
# CHECK POSITION & SIZE VIOLATIONS
# Script: Check-PositionSize.ps1
# Purpose: Validate Position & Size Rules according to Section 3 of .cursorrules
# Rules Reference: Section 3 - Position & Size Rules
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$TargetFile = "",
    [switch]$Verbose
)

Write-Host "📐 POSITION & SIZE VALIDATION" -ForegroundColor Blue
Write-Host "=============================" -ForegroundColor Blue
Write-Host "Rules Reference: Section 3 - Position & Size Rules" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalViolations = 0
$results = @()

function Check-PositionSizeViolations {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $lines = Get-Content $FilePath -Encoding UTF8
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Rule 3.1: Width and Height - MANDATORY RELATIVE POSITIONING
        if ($line -match "^\s*(Width|Height):\s*=?(\d+)$") {
            $property = $matches[1]
            $value = $matches[2]
            $violations += [PSCustomObject]@{
                Rule = "3.1"
                Severity = "Error"
                Message = "FORBIDDEN: Absolute values for $property - must use relative positioning"
                Line = $lineNumber
                Content = $line.Trim()
                Fix = "Use relative value like =Parent.$property or =Parent.$property / 2"
            }
        }
        
        # Rule 3.2: X and Y Positioning - MANDATORY RELATIVE POSITIONING  
        if ($line -match "^\s*(X|Y):\s*=?(\d+)$") {
            $property = $matches[1]
            $value = $matches[2]
            $violations += [PSCustomObject]@{
                Rule = "3.2"
                Severity = "Error"
                Message = "FORBIDDEN: Absolute values for $property - must use relative positioning"
                Line = $lineNumber
                Content = $line.Trim()
                Fix = "Use relative value like =Parent.$property or =Control.Y + Control.Height"
            }
        }
        
        # Rule 3.3: Arithmetic Operations - AVOID FIXED NUMBERS
        if ($line -match "^\s*(Width|Height|X|Y|Size):\s*=.*[+\-\*/]\s*\d{2,}") {
            $property = $matches[1]
            $violations += [PSCustomObject]@{
                Rule = "3.3"
                Severity = "Warning"
                Message = "DISCOURAGED: Large fixed numbers in $property calculations - prefer relative calculations"
                Line = $lineNumber
                Content = $line.Trim()
                Fix = "Use percentage/ratio calculations or relative to other controls"
            }
        }
        
        # Rule 3.3: Pure fixed values detection
        if ($line -match "^\s*(Width|Height|X|Y):\s*=?(\d+)$") {
            $property = $matches[1]
            $value = $matches[2]
            if ([int]$value -gt 10) {
                $violations += [PSCustomObject]@{
                    Rule = "3.3"
                    Severity = "Error"
                    Message = "FORBIDDEN: Pure fixed values - use relative calculations"
                    Line = $lineNumber
                    Content = $line.Trim()
                    Fix = "Convert to relative: =Parent.$property * 0.8 or similar"
                }
            }
        }
        
        # Rule 3.3: Missing = prefix in calculations
        if ($line -match "^\s*(Width|Height|X|Y|Size):\s*(?!=)Parent\.|(?!=)Self\.|(?!=)\w+\.\w+") {
            $property = $matches[1]
            $violations += [PSCustomObject]@{
                Rule = "3.3"
                Severity = "Error"
                Message = "MISSING: = prefix required for dynamic calculations"
                Line = $lineNumber
                Content = $line.Trim()
                Fix = "Add = prefix before the calculation"
            }
        }
        
        # Rule 3.4: Screen-Level Properties validation
        if ($line -match "^\s*Control:\s*Screen" -or $lines -match "Screens:") {
            # Look for Width/Height in screen properties (should not be present)
            for ($j = $i + 1; $j -lt $i + 10 -and $j -lt $lines.Count; $j++) {
                if ($lines[$j] -match "^\s*Properties:") {
                    for ($k = $j + 1; $k -lt $j + 10 -and $k -lt $lines.Count; $k++) {
                        if ($lines[$k] -match "^\s*(Width|Height):\s*") {
                            $violations += [PSCustomObject]@{
                                Rule = "3.4"
                                Severity = "Warning"
                                Message = "DISCOURAGED: Width/Height for screens are automatically handled by Power Apps"
                                Line = $k + 1
                                Content = $lines[$k].Trim()
                                Fix = "Remove Width/Height properties for screens"
                            }
                        }
                        # Stop if we hit next section
                        if ($lines[$k] -match "^\s*Children:" -or $lines[$k] -match "^\s*-\s*\w+:") {
                            break
                        }
                    }
                    break
                }
            }
        }
        
        # Advanced checks for better relative positioning
        if ($line -match "^\s*(Width|Height):\s*=Parent\.(Width|Height)\s*$") {
            $violations += [PSCustomObject]@{
                Rule = "3.1"
                Severity = "Warning"
                Message = "IMPROVEMENT: Consider using percentage/ratio for better responsiveness"
                Line = $lineNumber
                Content = $line.Trim()
                Fix = "Use =Parent.$($matches[2]) * 0.8 for 80% or =Parent.$($matches[2]) / 2 for 50%"
            }
        }
        
        # Check for common mistakes in Parent references
        if ($line -match "^\s*(X|Y):\s*=Parent\.(X|Y)\s*$") {
            $violations += [PSCustomObject]@{
                Rule = "3.2"
                Severity = "Warning"
                Message = "IMPROVEMENT: Direct Parent positioning may cause overlap"
                Line = $lineNumber
                Content = $line.Trim()
                Fix = "Add offset: =Parent.$($matches[2]) + 20 or use control relationships"
            }
        }
        
        # Check for Self references without proper context
        if ($line -match "^\s*(Height):\s*=Self\.Width") {
            $violations += [PSCustomObject]@{
                Rule = "3.1"
                Severity = "Info"
                Message = "GOOD PRACTICE: Using proportional sizing with Self references"
                Line = $lineNumber
                Content = $line.Trim()
                Fix = "This is good practice - no changes needed"
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
        $violations = Check-PositionSizeViolations -FilePath $file.FullName
        $fileViolations = $violations.Count
        $totalViolations += $fileViolations
        
        if ($fileViolations -gt 0) {
            Write-Host "  VIOLATIONS: $fileViolations" -ForegroundColor Red
            
            if ($Verbose) {
                foreach ($violation in $violations) {
                    $color = switch ($violation.Severity) {
                        "Error" { "Red" }
                        "Warning" { "Yellow" }
                        "Info" { "Cyan" }
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
Write-Host "POSITION & SIZE SUMMARY:" -ForegroundColor Blue
Write-Host "  Files checked: $totalFiles" -ForegroundColor White
Write-Host "  Total violations: $totalViolations" -ForegroundColor $(if ($totalViolations -eq 0) { 'Green' } else { 'Red' })

if ($totalViolations -gt 0) {
    $complianceRate = [math]::Round(((($totalFiles * 8) - $totalViolations) / ($totalFiles * 8)) * 100, 1)
    Write-Host "  Compliance rate: $complianceRate%" -ForegroundColor $(if ($complianceRate -ge 90) { 'Green' } elseif ($complianceRate -ge 70) { 'Yellow' } else { 'Red' })
    
    Write-Host ""
    Write-Host "FILES WITH VIOLATIONS:" -ForegroundColor Red
    foreach ($result in $results) {
        Write-Host "  $($result.File) ($($result.Violations) violations) - Rules: $($result.Rules)" -ForegroundColor Red
    }
}

Write-Host ""
if ($totalViolations -eq 0) {
    Write-Host "✅ All position & size validation passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ Found $totalViolations position & size violations that need fixing" -ForegroundColor Red
    Write-Host "💡 Run Fix-PositionSize.ps1 to auto-fix these issues" -ForegroundColor Cyan
    exit 1
} 