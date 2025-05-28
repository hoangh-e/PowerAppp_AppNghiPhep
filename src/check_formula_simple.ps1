# Simple Formula Compliance Checker
Write-Host "POWER APP FORMULA COMPLIANCE CHECKER" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

$violations = 0
$files = Get-ChildItem -Path "src" -Recurse -Filter "*.yaml"

foreach ($file in $files) {
    $content = Get-Content $file.FullName
    $lineNumber = 0
    $fileViolations = 0
    
    foreach ($line in $content) {
        $lineNumber++
        
        # Check for long formulas without pipe operator
        if (($line -match "Text:\s*=") -and ($line.Length -gt 120) -and ($line -notmatch "Text:\s*\|")) {
            Write-Host "ERROR: $($file.Name):$lineNumber - Long formula without pipe operator ($($line.Length) chars)" -ForegroundColor Red
            $violations++
            $fileViolations++
        }
        
        # Check for OnSelect formulas without pipe operator
        if (($line -match "OnSelect:\s*=") -and ($line.Length -gt 120) -and ($line -notmatch "OnSelect:\s*\|")) {
            Write-Host "ERROR: $($file.Name):$lineNumber - Long OnSelect without pipe operator ($($line.Length) chars)" -ForegroundColor Red
            $violations++
            $fileViolations++
        }
        
        # Check for multi-line Concatenate without pipe
        if (($line -match "Text:\s*=.*Concatenate\(") -and ($line -notmatch "Text:\s*\|")) {
            Write-Host "ERROR: $($file.Name):$lineNumber - Concatenate without pipe operator" -ForegroundColor Red
            $violations++
            $fileViolations++
        }
        
        # Check for spaces after colons in key-value pairs
        if ($line -match "Concatenate.*`"[A-Za-z]+:\s[A-Z]") {
            Write-Host "ERROR: $($file.Name):$lineNumber - Space after colon in key-value pair" -ForegroundColor Red
            $violations++
            $fileViolations++
        }
        
        # Check for spaces after colons in Shadow/Color constants
        if ($line -match "`"(Shadow|Color|Text|Space|Radius)[A-Z]*:\s[A-Z]") {
            Write-Host "ERROR: $($file.Name):$lineNumber - Space after colon in design system constant" -ForegroundColor Red
            $violations++
            $fileViolations++
        }
        
        # Check for OnSelect in GroupContainer (PA2108 error)
        if ($line -match "OnSelect:") {
            $contextLines = $content[([Math]::Max(0, $lineNumber - 10))..($lineNumber - 1)]
            if ($contextLines -match "Control:\s*GroupContainer") {
                Write-Host "ERROR: $($file.Name):$lineNumber - PA2108 Error: OnSelect not supported for GroupContainer" -ForegroundColor Red
                $violations++
                $fileViolations++
            }
        }
        
        # Check for invalid TextMode values
        if (($line -match "TextMode:\s*=") -and ($line -notmatch "TextMode\.(SingleLine|MultiLine|Password)")) {
            Write-Host "ERROR: $($file.Name):$lineNumber - Invalid TextMode value - only SingleLine, MultiLine, Password allowed" -ForegroundColor Red
            $violations++
            $fileViolations++
        }
        
        # Check for invalid Self properties (.Focused)
        if ($line -match "'[^']*'\.Focused") {
            Write-Host "ERROR: $($file.Name):$lineNumber - Invalid Self property: 'ControlName'.Focused - use Self.Focus instead" -ForegroundColor Red
            $violations++
            $fileViolations++
        }
        
        # Check for other invalid Self properties
        if ($line -match "'[^']*'\.(IsHovered|IsPressed)") {
            Write-Host "ERROR: $($file.Name):$lineNumber - Invalid Self property: Use hover/press events instead" -ForegroundColor Red
            $violations++
            $fileViolations++
        }
    }
    
    if ($fileViolations -eq 0) {
        Write-Host "OK: $($file.Name): No violations" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "Total violations: $violations" -ForegroundColor $(if ($violations -eq 0) { "Green" } else { "Red" })

if ($violations -eq 0) {
    Write-Host "ALL FILES ARE COMPLIANT!" -ForegroundColor Green
} else {
    Write-Host "VIOLATIONS FOUND - Fix required!" -ForegroundColor Red
} 