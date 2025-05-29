# ===============================================
# CHECK CONTROL REFERENCES SCRIPT
# ===============================================
# Description: Validates control name references according to Power App rules
# Rules: 8.12, 7.1 - Control names with dots must be wrapped in single quotes
# ❌ WRONG: Text: =LoginCard.FormSection.UsernameInput.Text
# ✅ CORRECT: Text: ='LoginCard.FormSection.UsernameInput'.Text

param(
    [Parameter(Mandatory=$false)]
    [string]$SourcePath = "src",
    
    [Parameter(Mandatory=$false)]
    [switch]$VerboseOutput,
    
    [Parameter(Mandatory=$false)]
    [switch]$FixIssues,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "control_reference_violations.txt"
)

# Initialize counters
$global:totalFiles = 0
$global:violationFiles = 0
$global:totalViolations = 0
$global:fixedViolations = 0

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    
    $colorMap = @{
        "Red" = [ConsoleColor]::Red
        "Yellow" = [ConsoleColor]::Yellow
        "Green" = [ConsoleColor]::Green
        "Cyan" = [ConsoleColor]::Cyan
        "Magenta" = [ConsoleColor]::Magenta
        "White" = [ConsoleColor]::White
    }
    
    Write-Host $Message -ForegroundColor $colorMap[$Color]
}

function Check-ControlReferenceViolations {
    param([string]$FilePath, [string[]]$Content)
    
    $violations = @()
    $lineNumber = 0
    
    foreach ($line in $Content) {
        $lineNumber++
        $trimmedLine = $line.Trim()
        
        # Skip comments and empty lines
        if ($trimmedLine -match "^\s*#" -or $trimmedLine -eq "") {
            continue
        }
        
        # Pattern 1: Control references with dots not in quotes
        # Match patterns like ControlName.PropertyName but exclude already quoted ones
        if ($trimmedLine -match "=.*\b([A-Za-z][A-Za-z0-9]*\.[A-Za-z][A-Za-z0-9.]*)\b" -and 
            $trimmedLine -notmatch "='[^']*'") {
            
            $matches = [regex]::Matches($trimmedLine, "\b([A-Za-z][A-Za-z0-9]*\.[A-Za-z][A-Za-z0-9.]*)\b")
            
            foreach ($match in $matches) {
                $controlRef = $match.Groups[1].Value
                
                # Skip if already in quotes or is a known function/object
                if ($trimmedLine -match "'$([regex]::Escape($controlRef))'" -or
                    $controlRef -match "^(Parent|Self|App|ThisItem|Screen|Color|Icon|Font|FontWeight|DisplayMode|TextMode|RGBA|DropShadow)\." -or
                    $controlRef -match "^(Concatenate|If|And|Or|Not|Set|Navigate|Filter|Sort|First|Last|Count|Sum|Max|Min)\." -or
                    $controlRef -match "^\d" -or
                    $controlRef -match "^[A-Z]{2,}\." -or
                    $controlRef -contains "Version") {
                    continue
                }
                
                $violations += [PSCustomObject]@{
                    File = $FilePath
                    Line = $lineNumber
                    Content = $trimmedLine
                    ViolationType = "UnquotedControlReference"
                    ControlReference = $controlRef
                    Rule = "8.12"
                    Description = "Control name with dots must be wrapped in single quotes"
                    Suggestion = "Use '$controlRef' instead of $controlRef"
                }
                $global:totalViolations++
            }
        }
        
        # Pattern 2: Check for control names with special characters not quoted
        if ($trimmedLine -match "=.*\b([A-Za-z][A-Za-z0-9]*[\s\-][A-Za-z][A-Za-z0-9]*)\b" -and 
            $trimmedLine -notmatch "='[^']*'") {
            
            $matches = [regex]::Matches($trimmedLine, "\b([A-Za-z][A-Za-z0-9]*[\s\-][A-Za-z][A-Za-z0-9]*)\b")
            
            foreach ($match in $matches) {
                $controlRef = $match.Groups[1].Value
                
                # Skip if already in quotes or common words
                if ($trimmedLine -match "'$([regex]::Escape($controlRef))'" -or
                    $controlRef -match "^(Power Apps|Display Mode|Text Mode|Drop Shadow)\b") {
                    continue
                }
                
                $violations += [PSCustomObject]@{
                    File = $FilePath
                    Line = $lineNumber
                    Content = $trimmedLine
                    ViolationType = "UnquotedControlWithSpecialChars"
                    ControlReference = $controlRef
                    Rule = "7.1"
                    Description = "Control name with special characters must be wrapped in single quotes"
                    Suggestion = "Use '$controlRef' instead of $controlRef"
                }
                $global:totalViolations++
            }
        }
        
        # Pattern 3: Check for control declaration names that need quotes
        if ($trimmedLine -match "^\s*-\s*([A-Za-z][A-Za-z0-9]*[\.\s\-][A-Za-z][A-Za-z0-9\.\s\-]*):") {
            $matches = [regex]::Matches($trimmedLine, "^\s*-\s*([A-Za-z][A-Za-z0-9]*[\.\s\-][A-Za-z][A-Za-z0-9\.\s\-]*):")
            
            foreach ($match in $matches) {
                $controlName = $match.Groups[1].Value
                
                # Check if already quoted
                if ($trimmedLine -match "^\s*-\s*'[^']*':") {
                    continue
                }
                
                $violations += [PSCustomObject]@{
                    File = $FilePath
                    Line = $lineNumber
                    Content = $trimmedLine
                    ViolationType = "UnquotedControlDeclaration"
                    ControlReference = $controlName
                    Rule = "7.1"
                    Description = "Control declaration with special characters must be wrapped in single quotes"
                    Suggestion = "Use - '$controlName': instead of - $controlName`:"
                }
                $global:totalViolations++
            }
        }
        
        # Pattern 4: Common problematic control reference patterns
        $problematicPatterns = @(
            @{ Pattern = '\b([A-Za-z]+\.Form\.[A-Za-z]+)(?!\s*=)'; Issue = "Form control reference" }
            @{ Pattern = '\b([A-Za-z]+\.Input\.[A-Za-z]+)(?!\s*=)'; Issue = "Input control reference" }
            @{ Pattern = '\b([A-Za-z]+\.Button\.[A-Za-z]+)(?!\s*=)'; Issue = "Button control reference" }
            @{ Pattern = '\b([A-Za-z]+\.Card\.[A-Za-z]+)(?!\s*=)'; Issue = "Card control reference" }
        )
        
        foreach ($pattern in $problematicPatterns) {
            $matches = [regex]::Matches($trimmedLine, $pattern.Pattern)
            
            foreach ($match in $matches) {
                $controlRef = $match.Groups[1].Value
                
                # Skip if already in quotes
                if ($trimmedLine -match "'$([regex]::Escape($controlRef))'") {
                    continue
                }
                
                $violations += [PSCustomObject]@{
                    File = $FilePath
                    Line = $lineNumber
                    Content = $trimmedLine
                    ViolationType = "ProblematicControlPattern"
                    ControlReference = $controlRef
                    Rule = "8.12"
                    Description = "$($pattern.Issue) needs quotes"
                    Suggestion = "Use '$controlRef' instead of $controlRef"
                }
                $global:totalViolations++
            }
        }
    }
    
    return $violations
}

function Fix-ControlReferenceViolations {
    param([string]$FilePath, [string[]]$Content, [array]$Violations)
    
    $modifiedContent = $Content
    $fixedCount = 0
    
    # Group violations by line to fix multiple issues on same line
    $violationsByLine = $Violations | Group-Object Line
    
    foreach ($lineGroup in $violationsByLine) {
        $lineIndex = [int]$lineGroup.Name - 1
        $originalLine = $modifiedContent[$lineIndex]
        $fixedLine = $originalLine
        
        foreach ($violation in $lineGroup.Group) {
            switch ($violation.ViolationType) {
                "UnquotedControlReference" {
                    # Fix ControlName.Property → 'ControlName.Property'
                    $controlRef = [regex]::Escape($violation.ControlReference)
                    $fixedLine = $fixedLine -replace "\b$controlRef\b", "'$($violation.ControlReference)'"
                    $fixedCount++
                }
                "UnquotedControlWithSpecialChars" {
                    # Fix Control Name → 'Control Name'
                    $controlRef = [regex]::Escape($violation.ControlReference)
                    $fixedLine = $fixedLine -replace "\b$controlRef\b", "'$($violation.ControlReference)'"
                    $fixedCount++
                }
                "UnquotedControlDeclaration" {
                    # Fix - ControlName: → - 'ControlName':
                    $controlName = [regex]::Escape($violation.ControlReference)
                    $fixedLine = $fixedLine -replace "^(\s*-\s*)$controlName`:", "`$1'$($violation.ControlReference)':"
                    $fixedCount++
                }
                "ProblematicControlPattern" {
                    # Fix problematic patterns
                    $controlRef = [regex]::Escape($violation.ControlReference)
                    $fixedLine = $fixedLine -replace "\b$controlRef\b", "'$($violation.ControlReference)'"
                    $fixedCount++
                }
            }
        }
        
        if ($fixedLine -ne $originalLine) {
            $modifiedContent[$lineIndex] = $fixedLine
            $global:fixedViolations++
            
            if ($VerboseOutput) {
                Write-ColorOutput "  FIXED Line $($lineGroup.Name):" "Green"
                Write-ColorOutput "    OLD: $originalLine" "Red"
                Write-ColorOutput "    NEW: $fixedLine" "Green"
            }
        }
    }
    
    if ($fixedCount -gt 0) {
        Set-Content -Path $FilePath -Value $modifiedContent -Encoding UTF8
        Write-ColorOutput "Fixed $fixedCount violations in $FilePath" "Green"
    }
    
    return $fixedCount
}

function Main {
    Write-ColorOutput "CHECKING CONTROL REFERENCE VIOLATIONS" "Cyan"
    Write-ColorOutput "=========================================" "Cyan"
    Write-ColorOutput "Source Path: $SourcePath" "White"
    Write-ColorOutput "Fix Issues: $FixIssues" "White"
    Write-ColorOutput ""
    
    # Check if source path exists
    if (-not (Test-Path $SourcePath)) {
        Write-ColorOutput "ERROR: Source path '$SourcePath' does not exist!" "Red"
        exit 1
    }
    
    # Get all YAML files
    $yamlFiles = Get-ChildItem -Path $SourcePath -Recurse -Include "*.yaml", "*.yml" | Where-Object { !$_.PSIsContainer }
    
    if ($yamlFiles.Count -eq 0) {
        Write-ColorOutput "WARNING: No YAML files found in '$SourcePath'" "Yellow"
        exit 0
    }
    
    Write-ColorOutput "Found $($yamlFiles.Count) YAML files" "White"
    Write-ColorOutput ""
    
    $allViolations = @()
    
    foreach ($file in $yamlFiles) {
        $global:totalFiles++
        $content = Get-Content $file.FullName -Encoding UTF8
        
        Write-ColorOutput "Checking: $($file.Name)" "White"
        
        $violations = Check-ControlReferenceViolations -FilePath $file.FullName -Content $content
        
        if ($violations.Count -gt 0) {
            $global:violationFiles++
            $allViolations += $violations
            
            Write-ColorOutput "  FAIL: Found $($violations.Count) control reference violations" "Red"
            
            if ($VerboseOutput) {
                foreach ($violation in $violations) {
                    Write-ColorOutput "    Line $($violation.Line): $($violation.ViolationType)" "Yellow"
                    Write-ColorOutput "    Control: $($violation.ControlReference)" "White"
                    Write-ColorOutput "    Rule: $($violation.Rule) - $($violation.Description)" "Magenta"
                    Write-ColorOutput "    Suggestion: $($violation.Suggestion)" "Cyan"
                    Write-ColorOutput ""
                }
            }
            
            # Fix violations if requested
            if ($FixIssues) {
                Fix-ControlReferenceViolations -FilePath $file.FullName -Content $content -Violations $violations
            }
        } else {
            Write-ColorOutput "  PASS: No control reference violations found" "Green"
        }
    }
    
    # Save violations to file
    if ($allViolations.Count -gt 0) {
        $allViolations | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
        Write-ColorOutput ""
        Write-ColorOutput "Violations saved to: $OutputFile" "Cyan"
    }
    
    # Summary
    Write-ColorOutput ""
    Write-ColorOutput "SUMMARY" "Cyan"
    Write-ColorOutput "==========" "Cyan"
    Write-ColorOutput "Total files checked: $global:totalFiles" "White"
    Write-ColorOutput "Files with violations: $global:violationFiles" "White"
    Write-ColorOutput "Total violations: $global:totalViolations" "White"
    
    if ($FixIssues) {
        Write-ColorOutput "Violations fixed: $global:fixedViolations" "Green"
    }
    
    if ($global:totalViolations -gt 0) {
        Write-ColorOutput ""
        Write-ColorOutput "CONTROL REFERENCE VIOLATIONS FOUND!" "Red"
        Write-ColorOutput "Rules violated: 8.12, 7.1 - Control name reference formatting" "Red"
        
        if (-not $FixIssues) {
            Write-ColorOutput ""
            Write-ColorOutput "Run with -FixIssues to automatically fix these violations" "Yellow"
        }
        
        exit 1
    } else {
        Write-ColorOutput ""
        Write-ColorOutput "All files comply with control reference rules!" "Green"
        exit 0
    }
}

# Run the main function
Main 