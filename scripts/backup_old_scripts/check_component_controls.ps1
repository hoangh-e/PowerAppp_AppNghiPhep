# ===============================================
# CHECK COMPONENT CONTROLS SCRIPT
# ===============================================
# Description: Validates component control usage according to Power App rules
# Rules: 2.3, 8.2 - Component declarations must use Control: CanvasComponent
# ❌ WRONG: Control: HeaderComponent
# ✅ CORRECT: Control: CanvasComponent + ComponentName: HeaderComponent

param(
    [Parameter(Mandatory=$false)]
    [string]$SourcePath = "src",
    
    [Parameter(Mandatory=$false)]
    [switch]$VerboseOutput,
    
    [Parameter(Mandatory=$false)]
    [switch]$FixIssues,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "component_control_violations.txt"
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

function Check-ComponentControlViolations {
    param([string]$FilePath, [string[]]$Content)
    
    $violations = @()
    $lineNumber = 0
    $inControlBlock = $false
    $controlBlockIndent = 0
    
    # Common Power Apps control types that should NOT be treated as components
    $validControlTypes = @(
        "Label", "Classic/TextInput", "Classic/Button", "Classic/DropDown", "Classic/ComboBox",
        "Classic/CheckBox", "Classic/Radio", "Classic/Toggle", "Classic/Slider", "Classic/DatePicker",
        "Classic/Icon", "Image", "Gallery", "Form", "FormViewer", "GroupContainer", "Rectangle",
        "Circle", "Triangle", "Pentagon", "Octagon", "Star", "Arrow", "PartialCircle",
        "BarChart", "LineChart", "PieChart", "Legend", "AddMedia", "Timer", "Import", "Export",
        "ListBox", "PowerBI", "Rating", "PenInput", "HtmlViewer", "RichTextEditor", "PDFViewer",
        "DataTable", "CanvasComponent"
    )
    
    foreach ($line in $Content) {
        $lineNumber++
        $trimmedLine = $line.Trim()
        
        # Skip comments and empty lines
        if ($trimmedLine -match "^\s*#" -or $trimmedLine -eq "") {
            continue
        }
        
        # Pattern 1: Direct component reference as Control type
        if ($trimmedLine -match "^\s*Control:\s*([A-Za-z][A-Za-z0-9_]*Component)\s*$") {
            $componentName = $Matches[1]
            
            # Skip if it's already CanvasComponent
            if ($componentName -eq "CanvasComponent") {
                continue
            }
            
            $violations += [PSCustomObject]@{
                File = $FilePath
                Line = $lineNumber
                Content = $trimmedLine
                ViolationType = "DirectComponentReference"
                ComponentName = $componentName
                Rule = "2.3"
                Description = "Direct component reference in Control field"
                Suggestion = "Use Control: CanvasComponent and ComponentName: $componentName"
            }
            $global:totalViolations++
        }
        
        # Pattern 2: Control types that look like components but aren't valid control types
        if ($trimmedLine -match "^\s*Control:\s*([A-Za-z][A-Za-z0-9_]*)\s*$") {
            $controlType = $Matches[1]
            
            # Check if it's not a valid control type and looks like a component
            if ($controlType -notin $validControlTypes -and 
                ($controlType -match "Component$" -or $controlType -match "^[A-Z][a-z]+[A-Z]")) {
                
                $violations += [PSCustomObject]@{
                    File = $FilePath
                    Line = $lineNumber
                    Content = $trimmedLine
                    ViolationType = "InvalidComponentControl"
                    ComponentName = $controlType
                    Rule = "8.2"
                    Description = "Invalid component control type"
                    Suggestion = "Use Control: CanvasComponent and ComponentName: $controlType"
                }
                $global:totalViolations++
            }
        }
        
        # Pattern 3: Missing ComponentName after CanvasComponent
        if ($trimmedLine -match "^\s*Control:\s*CanvasComponent\s*$") {
            $nextLineNumber = $lineNumber + 1
            $foundComponentName = $false
            
            # Check next few lines for ComponentName
            for ($i = $lineNumber; $i -lt [Math]::Min($lineNumber + 5, $Content.Count); $i++) {
                if ($Content[$i] -match "^\s*ComponentName:\s*") {
                    $foundComponentName = $true
                    break
                }
                # Stop if we hit another control or properties
                if ($Content[$i] -match "^\s*(Control:|Properties:|\s*-\s*[A-Za-z])") {
                    break
                }
            }
            
            if (-not $foundComponentName) {
                $violations += [PSCustomObject]@{
                    File = $FilePath
                    Line = $lineNumber
                    Content = $trimmedLine
                    ViolationType = "MissingComponentName"
                    ComponentName = ""
                    Rule = "2.3"
                    Description = "CanvasComponent without ComponentName property"
                    Suggestion = "Add ComponentName: [YourComponentName] after Control: CanvasComponent"
                }
                $global:totalViolations++
            }
        }
        
        # Pattern 4: Check for version numbers in component references
        if ($trimmedLine -match "^\s*Control:\s*([A-Za-z][A-Za-z0-9_]*@[\d\.]+)\s*$") {
            $controlWithVersion = $Matches[1]
            $controlName = $controlWithVersion -replace "@.*", ""
            
            $violations += [PSCustomObject]@{
                File = $FilePath
                Line = $lineNumber
                Content = $trimmedLine
                ViolationType = "ComponentWithVersion"
                ComponentName = $controlName
                Rule = "2.1"
                Description = "Version numbers in Control declarations are forbidden"
                Suggestion = "Use Control: CanvasComponent and ComponentName: $controlName (remove version)"
            }
            $global:totalViolations++
        }
        
        # Pattern 5: Common misspelled or incorrect component patterns
        $incorrectPatterns = @(
            @{ Pattern = "^\s*Control:\s*Canvas\s*$"; Suggestion = "Control: CanvasComponent" }
            @{ Pattern = "^\s*Control:\s*Component\s*$"; Suggestion = "Control: CanvasComponent" }
            @{ Pattern = "^\s*Component:\s*"; Suggestion = "Control: CanvasComponent + ComponentName:" }
        )
        
        foreach ($pattern in $incorrectPatterns) {
            if ($trimmedLine -match $pattern.Pattern) {
                $violations += [PSCustomObject]@{
                    File = $FilePath
                    Line = $lineNumber
                    Content = $trimmedLine
                    ViolationType = "IncorrectComponentPattern"
                    ComponentName = ""
                    Rule = "2.3"
                    Description = "Incorrect component declaration pattern"
                    Suggestion = $pattern.Suggestion
                }
                $global:totalViolations++
            }
        }
    }
    
    return $violations
}

function Fix-ComponentControlViolations {
    param([string]$FilePath, [string[]]$Content, [array]$Violations)
    
    $modifiedContent = $Content
    $fixedCount = 0
    
    # Sort violations by line number in descending order to avoid line number shifts
    $sortedViolations = $Violations | Sort-Object Line -Descending
    
    foreach ($violation in $sortedViolations) {
        $lineIndex = $violation.Line - 1
        $originalLine = $modifiedContent[$lineIndex]
        
        switch ($violation.ViolationType) {
            "DirectComponentReference" {
                # Fix Control: HeaderComponent → Control: CanvasComponent + ComponentName: HeaderComponent
                $componentName = $violation.ComponentName
                $indent = $originalLine -replace '^(\s*).*', '$1'
                
                $modifiedContent[$lineIndex] = "${indent}Control: CanvasComponent"
                
                # Insert ComponentName line after
                $componentNameLine = "${indent}ComponentName: $componentName"
                $modifiedContent = $modifiedContent[0..$lineIndex] + $componentNameLine + $modifiedContent[($lineIndex + 1)..($modifiedContent.Length - 1)]
                
                $fixedCount++
                $global:fixedViolations++
            }
            
            "InvalidComponentControl" {
                # Fix Control: CustomComponent → Control: CanvasComponent + ComponentName: CustomComponent
                $componentName = $violation.ComponentName
                $indent = $originalLine -replace '^(\s*).*', '$1'
                
                $modifiedContent[$lineIndex] = "${indent}Control: CanvasComponent"
                
                # Insert ComponentName line after
                $componentNameLine = "${indent}ComponentName: $componentName"
                $modifiedContent = $modifiedContent[0..$lineIndex] + $componentNameLine + $modifiedContent[($lineIndex + 1)..($modifiedContent.Length - 1)]
                
                $fixedCount++
                $global:fixedViolations++
            }
            
            "ComponentWithVersion" {
                # Fix Control: Component@1.0.0 → Control: CanvasComponent + ComponentName: Component
                $componentName = $violation.ComponentName
                $indent = $originalLine -replace '^(\s*).*', '$1'
                
                $modifiedContent[$lineIndex] = "${indent}Control: CanvasComponent"
                
                # Insert ComponentName line after
                $componentNameLine = "${indent}ComponentName: $componentName"
                $modifiedContent = $modifiedContent[0..$lineIndex] + $componentNameLine + $modifiedContent[($lineIndex + 1)..($modifiedContent.Length - 1)]
                
                $fixedCount++
                $global:fixedViolations++
            }
            
            "IncorrectComponentPattern" {
                # Fix various incorrect patterns
                $indent = $originalLine -replace '^(\s*).*', '$1'
                
                if ($originalLine -match "Component:") {
                    # Extract component name and fix
                    $componentName = $originalLine -replace '.*Component:\s*', ''
                    $modifiedContent[$lineIndex] = "${indent}Control: CanvasComponent"
                    
                    # Insert ComponentName line after
                    $componentNameLine = "${indent}ComponentName: $componentName"
                    $modifiedContent = $modifiedContent[0..$lineIndex] + $componentNameLine + $modifiedContent[($lineIndex + 1)..($modifiedContent.Length - 1)]
                } else {
                    $modifiedContent[$lineIndex] = "${indent}Control: CanvasComponent"
                }
                
                $fixedCount++
                $global:fixedViolations++
            }
        }
        
        if ($VerboseOutput) {
            Write-ColorOutput "  FIXED Line $($violation.Line): $($violation.ViolationType)" "Green"
            Write-ColorOutput "    OLD: $originalLine" "Red"
            Write-ColorOutput "    NEW: Fixed component declaration" "Green"
        }
    }
    
    if ($fixedCount -gt 0) {
        Set-Content -Path $FilePath -Value $modifiedContent -Encoding UTF8
        Write-ColorOutput "Fixed $fixedCount violations in $FilePath" "Green"
    }
    
    return $fixedCount
}

function Main {
    Write-ColorOutput "CHECKING COMPONENT CONTROL VIOLATIONS" "Cyan"
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
        
        $violations = Check-ComponentControlViolations -FilePath $file.FullName -Content $content
        
        if ($violations.Count -gt 0) {
            $global:violationFiles++
            $allViolations += $violations
            
            Write-ColorOutput "  FAIL: Found $($violations.Count) component control violations" "Red"
            
            if ($VerboseOutput) {
                foreach ($violation in $violations) {
                    Write-ColorOutput "    Line $($violation.Line): $($violation.ViolationType)" "Yellow"
                    Write-ColorOutput "    Component: $($violation.ComponentName)" "White"
                    Write-ColorOutput "    Rule: $($violation.Rule) - $($violation.Description)" "Magenta"
                    Write-ColorOutput "    Suggestion: $($violation.Suggestion)" "Cyan"
                    Write-ColorOutput ""
                }
            }
            
            # Fix violations if requested
            if ($FixIssues) {
                Fix-ComponentControlViolations -FilePath $file.FullName -Content $content -Violations $violations
            }
        } else {
            Write-ColorOutput "  PASS: No component control violations found" "Green"
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
        Write-ColorOutput "COMPONENT CONTROL VIOLATIONS FOUND!" "Red"
        Write-ColorOutput "Rules violated: 2.3, 8.2 - Component control declarations" "Red"
        
        if (-not $FixIssues) {
            Write-ColorOutput ""
            Write-ColorOutput "Run with -FixIssues to automatically fix these violations" "Yellow"
        }
        
        exit 1
    } else {
        Write-ColorOutput ""
        Write-ColorOutput "All files comply with component control rules!" "Green"
        exit 0
    }
}

# Run the main function
Main 