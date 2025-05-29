# ===============================================
# CHECK TEXT FORMATTING SCRIPT
# ===============================================
# Description: Validates text concatenation formatting according to Power App rules
# Rules: 8.6, 5.6 - Text concatenation with proper spacing
# WRONG: Text: ="Email: " & ThisItem.Email
# CORRECT: Text: ="Email:" & " " & ThisItem.Email

param(
    [Parameter(Mandatory=$false)]
    [string]$SourcePath = "src",
    
    [Parameter(Mandatory=$false)]
    [switch]$VerboseOutput,
    
    [Parameter(Mandatory=$false)]
    [switch]$FixIssues,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "text_formatting_violations.txt"
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

function Check-TextFormattingViolations {
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
        
        # Pattern 1: Check for "Label: " & value (space after colon inside quotes)
        if ($trimmedLine -match 'Text:\s*=\s*"[^"]*:\s+".*&') {
            $violations += [PSCustomObject]@{
                File = $FilePath
                Line = $lineNumber
                Content = $trimmedLine
                ViolationType = "SpaceAfterColonInQuotes"
                Rule = "8.6"
                Description = "Space after colon inside quotes should be separated"
                Suggestion = 'Use "Label:" & " " & value instead of "Label: " & value'
            }
            $global:totalViolations++
        }
        
        # Pattern 2: Check for single quoted strings with space after colon
        if ($trimmedLine -match "Text:\s*=\s*'[^']*:\s+'.*&") {
            $violations += [PSCustomObject]@{
                File = $FilePath
                Line = $lineNumber
                Content = $trimmedLine
                ViolationType = "SpaceAfterColonInSingleQuotes"
                Rule = "8.6"
                Description = "Space after colon inside single quotes should be separated"
                Suggestion = "Use 'Label:' & ' ' & value instead of 'Label: ' & value"
            }
            $global:totalViolations++
        }
        
        # Pattern 3: Check for concatenate function with space after colon
        if ($trimmedLine -match 'Concatenate\s*\(\s*"[^"]*:\s+"') {
            $violations += [PSCustomObject]@{
                File = $FilePath
                Line = $lineNumber
                Content = $trimmedLine
                ViolationType = "SpaceAfterColonInConcatenate"
                Rule = "5.6"
                Description = "Space after colon in Concatenate function should be separated"
                Suggestion = 'Use Concatenate("Label:", " ", value) instead of Concatenate("Label: ", value)'
            }
            $global:totalViolations++
        }
        
        # Pattern 4: Check for common text formatting issues
        $commonPatterns = @(
            @{ Pattern = '"Email:\s+"'; Issue = "Email field formatting" }
            @{ Pattern = '"Status:\s+"'; Issue = "Status field formatting" }
            @{ Pattern = '"Name:\s+"'; Issue = "Name field formatting" }
            @{ Pattern = '"ID:\s+"'; Issue = "ID field formatting" }
            @{ Pattern = '"Date:\s+"'; Issue = "Date field formatting" }
        )
        
        foreach ($pattern in $commonPatterns) {
            if ($trimmedLine -match $pattern.Pattern) {
                $violations += [PSCustomObject]@{
                    File = $FilePath
                    Line = $lineNumber
                    Content = $trimmedLine
                    ViolationType = "CommonTextFormattingIssue"
                    Rule = "8.6"
                    Description = "$($pattern.Issue) with space after colon"
                    Suggestion = "Remove space after colon and use separate concatenation"
                }
                $global:totalViolations++
            }
        }
    }
    
    return $violations
}

function Fix-TextFormattingViolations {
    param([string]$FilePath, [string[]]$Content, [array]$Violations)
    
    $modifiedContent = $Content
    $fixedCount = 0
    
    foreach ($violation in $Violations) {
        $lineIndex = $violation.Line - 1
        $originalLine = $modifiedContent[$lineIndex]
        $fixedLine = $originalLine
        
        switch ($violation.ViolationType) {
            "SpaceAfterColonInQuotes" {
                # Fix "Label: " & value → "Label:" & " " & value
                $fixedLine = $fixedLine -replace '("([^"]*?):\s+")(\s*&)', '"$2:" & " " &'
                $fixedCount++
            }
            "SpaceAfterColonInSingleQuotes" {
                # Fix 'Label: ' & value → 'Label:' & ' ' & value
                $fixedLine = $fixedLine -replace "('([^']*?):\s+')(\s*&)", "'`$2:' & ' ' &"
                $fixedCount++
            }
            "SpaceAfterColonInConcatenate" {
                # Fix Concatenate("Label: ", value) → Concatenate("Label:", " ", value)
                $fixedLine = $fixedLine -replace 'Concatenate\s*\(\s*"([^"]*?):\s+"', 'Concatenate("$1:", " "'
                $fixedCount++
            }
            "CommonTextFormattingIssue" {
                # Fix common patterns
                $fixedLine = $fixedLine -replace '"([^"]*?):\s+"', '"$1:" & " "'
                $fixedCount++
            }
        }
        
        if ($fixedLine -ne $originalLine) {
            $modifiedContent[$lineIndex] = $fixedLine
            $global:fixedViolations++
            
            if ($VerboseOutput) {
                Write-ColorOutput "  FIXED Line $($violation.Line):" "Green"
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
    Write-ColorOutput "CHECKING TEXT FORMATTING VIOLATIONS" "Cyan"
    Write-ColorOutput "=======================================" "Cyan"
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
        
        $violations = Check-TextFormattingViolations -FilePath $file.FullName -Content $content
        
        if ($violations.Count -gt 0) {
            $global:violationFiles++
            $allViolations += $violations
            
            Write-ColorOutput "  FAIL: Found $($violations.Count) text formatting violations" "Red"
            
            if ($VerboseOutput) {
                foreach ($violation in $violations) {
                    Write-ColorOutput "    Line $($violation.Line): $($violation.ViolationType)" "Yellow"
                    Write-ColorOutput "    Content: $($violation.Content)" "White"
                    Write-ColorOutput "    Rule: $($violation.Rule) - $($violation.Description)" "Magenta"
                    Write-ColorOutput "    Suggestion: $($violation.Suggestion)" "Cyan"
                    Write-ColorOutput ""
                }
            }
            
            # Fix violations if requested
            if ($FixIssues) {
                Fix-TextFormattingViolations -FilePath $file.FullName -Content $content -Violations $violations
            }
        } else {
            Write-ColorOutput "  PASS: No text formatting violations found" "Green"
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
        Write-ColorOutput "TEXT FORMATTING VIOLATIONS FOUND!" "Red"
        Write-ColorOutput "Rules violated: 8.6, 5.6 - Text concatenation formatting" "Red"
        
        if (-not $FixIssues) {
            Write-ColorOutput ""
            Write-ColorOutput "Run with -FixIssues to automatically fix these violations" "Yellow"
        }
        
        exit 1
    } else {
        Write-ColorOutput ""
        Write-ColorOutput "All files comply with text formatting rules!" "Green"
        exit 0
    }
}

# Run the main function
Main 