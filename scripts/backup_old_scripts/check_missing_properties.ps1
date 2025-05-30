# ===============================================
# CHECK MISSING PROPERTIES SCRIPT
# ===============================================
# Description: Validates required properties according to Power App rules
# Rules: 8.9, 2.5 - Missing X, Y, Width, Height properties for positioned controls
# ❌ WRONG: Control without X, Y, Width, Height properties
# ✅ CORRECT: All positioned controls have X, Y, Width, Height properties

param(
    [Parameter(Mandatory=$false)]
    [string]$SourcePath = "src",
    
    [Parameter(Mandatory=$false)]
    [switch]$VerboseOutput,
    
    [Parameter(Mandatory=$false)]
    [switch]$FixIssues,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "missing_properties_violations.txt"
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

function Check-MissingPropertiesViolations {
    param([string]$FilePath, [string[]]$Content)
    
    $violations = @()
    $lineNumber = 0
    $currentControl = $null
    $currentControlLine = 0
    $inProperties = $false
    $controlProperties = @{}
    
    # Controls that typically need positioning properties
    $positionedControlTypes = @(
        "Label", "Classic/TextInput", "Classic/Button", "Classic/DropDown", "Classic/ComboBox",
        "Classic/CheckBox", "Classic/Radio", "Classic/Toggle", "Classic/Slider", "Classic/DatePicker",
        "Classic/Icon", "Image", "Rectangle", "Circle", "Triangle", "Pentagon", "Octagon", 
        "Star", "Arrow", "PartialCircle", "Gallery", "GroupContainer", "CanvasComponent"
    )
    
    # Controls that don't need positioning (screen-level or auto-layout)
    $excludedControlTypes = @(
        "Form", "FormViewer", "BarChart", "LineChart", "PieChart", "Legend", 
        "AddMedia", "Timer", "Import", "Export", "ListBox", "PowerBI",
        "HtmlViewer", "RichTextEditor", "PDFViewer", "DataTable"
    )
    
    # Required positioning properties
    $requiredPositionProps = @("X", "Y", "Width", "Height")
    
    foreach ($line in $Content) {
        $lineNumber++
        $trimmedLine = $line.Trim()
        
        # Skip comments and empty lines
        if ($trimmedLine -match "^\s*#" -or $trimmedLine -eq "") {
            continue
        }
        
        # Detect control declaration
        if ($trimmedLine -match "^\s*-\s*([^:]+):\s*$" -or $trimmedLine -match "^\s*-\s*'([^']+)':\s*$") {
            # Process previous control if exists
            if ($currentControl -ne $null -and $currentControl.ControlType -in $positionedControlTypes) {
                $missing = Check-MissingPositionProperties -Control $currentControl -Properties $controlProperties
                if ($missing.Count -gt 0) {
                    $violations += $missing
                }
            }
            
            # Start new control
            $controlName = if ($Matches[1]) { $Matches[1] } else { $Matches[1] }
            $currentControl = @{
                Name = $controlName
                Line = $lineNumber
                ControlType = $null
            }
            $currentControlLine = $lineNumber
            $controlProperties = @{}
            $inProperties = $false
        }
        
        # Detect control type
        if ($trimmedLine -match "^\s*Control:\s*(.+)\s*$" -and $currentControl) {
            $currentControl.ControlType = $Matches[1].Trim()
        }
        
        # Detect properties section
        if ($trimmedLine -match "^\s*Properties:\s*$") {
            $inProperties = $true
        }
        
        # Detect end of properties (next control or section)
        if (($trimmedLine -match "^\s*Children:\s*$" -or 
             $trimmedLine -match "^\s*-\s*[^:]+:\s*$" -or
             $trimmedLine -match "^\s*ComponentName:\s*$") -and $inProperties) {
            $inProperties = $false
        }
        
        # Collect properties
        if ($inProperties -and $trimmedLine -match "^\s*([A-Za-z][A-Za-z0-9]*)\s*:\s*(.+)\s*$") {
            $propName = $Matches[1]
            $propValue = $Matches[2]
            $controlProperties[$propName] = $propValue
        }
    }
    
    # Process last control
    if ($currentControl -ne $null -and $currentControl.ControlType -in $positionedControlTypes) {
        $missing = Check-MissingPositionProperties -Control $currentControl -Properties $controlProperties
        if ($missing.Count -gt 0) {
            $violations += $missing
        }
    }
    
    return $violations
}

function Check-MissingPositionProperties {
    param($Control, $Properties)
    
    $violations = @()
    $requiredProps = @("X", "Y", "Width", "Height")
    $missingProps = @()
    
    foreach ($prop in $requiredProps) {
        if (-not $Properties.ContainsKey($prop)) {
            $missingProps += $prop
        }
    }
    
    if ($missingProps.Count -gt 0) {
        $violations += [PSCustomObject]@{
            File = $FilePath
            Line = $Control.Line
            Content = "- $($Control.Name):"
            ViolationType = "MissingRequiredProperties"
            ControlName = $Control.Name
            ControlType = $Control.ControlType
            MissingProperties = ($missingProps -join ", ")
            Rule = "8.9"
            Description = "Missing required positioning properties: $($missingProps -join ', ')"
            Suggestion = "Add missing properties: $($missingProps -join ', ') with relative values"
        }
        $global:totalViolations++
    }
    
    return $violations
}

function Get-SuggestedPropertyValues {
    param($ControlType, $MissingProperty)
    
    # Suggest appropriate default values based on control type
    switch ($MissingProperty) {
        "X" { 
            return "=Parent.X + Parent.Width * 0.05"
        }
        "Y" { 
            return "=Parent.Y + Parent.Height * 0.05"
        }
        "Width" { 
            switch ($ControlType) {
                "Classic/Button" { return "=Parent.Width * 0.3" }
                "Classic/TextInput" { return "=Parent.Width * 0.6" }
                "Label" { return "=Parent.Width * 0.4" }
                "Classic/Icon" { return "=Parent.Width / 20" }
                default { return "=Parent.Width * 0.5" }
            }
        }
        "Height" { 
            switch ($ControlType) {
                "Classic/Button" { return "=Parent.Height * 0.08" }
                "Classic/TextInput" { return "=Parent.Height * 0.06" }
                "Label" { return "=Parent.Height * 0.05" }
                "Classic/Icon" { return "=Self.Width" }
                "Rectangle" { return "=Parent.Height * 0.3" }
                default { return "=Parent.Height * 0.1" }
            }
        }
    }
    
    return "=Parent.$MissingProperty * 0.1"
}

function Fix-MissingPropertiesViolations {
    param([string]$FilePath, [string[]]$Content, [array]$Violations)
    
    $modifiedContent = $Content
    $fixedCount = 0
    
    foreach ($violation in $Violations) {
        # Find the properties section for this control
        $controlStartLine = $violation.Line
        $propertiesLine = -1
        
        # Look for Properties: section after control declaration
        for ($i = $controlStartLine; $i -lt [Math]::Min($controlStartLine + 20, $modifiedContent.Count); $i++) {
            if ($modifiedContent[$i] -match "^\s*Properties:\s*$") {
                $propertiesLine = $i
                break
            }
        }
        
        if ($propertiesLine -eq -1) {
            # No Properties section found - need to add one
            $controlIndent = $modifiedContent[$controlStartLine - 1] -replace '^(\s*).*', '$1'
            $propsIndent = $controlIndent + "  "
            
            # Find where to insert Properties section (after Control: line)
            $insertLine = $controlStartLine
            for ($i = $controlStartLine; $i -lt [Math]::Min($controlStartLine + 10, $modifiedContent.Count); $i++) {
                if ($modifiedContent[$i] -match "^\s*Control:\s*" -or $modifiedContent[$i] -match "^\s*ComponentName:\s*") {
                    $insertLine = $i + 1
                    break
                }
            }
            
            # Add Properties section
            $newLines = @()
            $newLines += "${propsIndent}Properties:"
            
            # Add missing properties
            $missingProps = $violation.MissingProperties -split ", "
            foreach ($prop in $missingProps) {
                $suggestedValue = Get-SuggestedPropertyValues -ControlType $violation.ControlType -MissingProperty $prop
                $newLines += "${propsIndent}  $prop`: $suggestedValue"
            }
            
            # Insert new lines
            $modifiedContent = $modifiedContent[0..($insertLine - 1)] + $newLines + $modifiedContent[$insertLine..($modifiedContent.Length - 1)]
            
            $fixedCount += $missingProps.Count
            $global:fixedViolations += $missingProps.Count
            
        } else {
            # Properties section exists - add missing properties
            $propsIndent = $modifiedContent[$propertiesLine] -replace '^(\s*).*', '$1'
            $propValueIndent = $propsIndent + "  "
            
            # Find end of properties section
            $propsEndLine = $propertiesLine + 1
            for ($i = $propertiesLine + 1; $i -lt $modifiedContent.Count; $i++) {
                if ($modifiedContent[$i] -match "^\s*[A-Za-z][A-Za-z0-9]*\s*:" -and 
                    $modifiedContent[$i] -match "^$propsIndent\s\s") {
                    $propsEndLine = $i + 1
                } else {
                    break
                }
            }
            
            # Add missing properties
            $missingProps = $violation.MissingProperties -split ", "
            $newLines = @()
            
            foreach ($prop in $missingProps) {
                $suggestedValue = Get-SuggestedPropertyValues -ControlType $violation.ControlType -MissingProperty $prop
                $newLines += "${propValueIndent}$prop`: $suggestedValue"
            }
            
            # Insert new properties
            $modifiedContent = $modifiedContent[0..($propsEndLine - 1)] + $newLines + $modifiedContent[$propsEndLine..($modifiedContent.Length - 1)]
            
            $fixedCount += $missingProps.Count
            $global:fixedViolations += $missingProps.Count
        }
        
        if ($VerboseOutput) {
            Write-ColorOutput "  FIXED Control '$($violation.ControlName)': Added missing properties" "Green"
            Write-ColorOutput "    Missing: $($violation.MissingProperties)" "Yellow"
        }
    }
    
    if ($fixedCount -gt 0) {
        Set-Content -Path $FilePath -Value $modifiedContent -Encoding UTF8
        Write-ColorOutput "✅ Fixed $fixedCount missing properties in $FilePath" "Green"
    }
    
    return $fixedCount
}

function Main {
    Write-ColorOutput "CHECKING MISSING PROPERTIES VIOLATIONS" "Cyan"
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
        
        $violations = Check-MissingPropertiesViolations -FilePath $file.FullName -Content $content
        
        if ($violations.Count -gt 0) {
            $global:violationFiles++
            $allViolations += $violations
            
            Write-ColorOutput "  FAIL: Found $($violations.Count) missing properties violations" "Red"
            
            if ($VerboseOutput) {
                foreach ($violation in $violations) {
                    Write-ColorOutput "    Line $($violation.Line): $($violation.ViolationType)" "Yellow"
                    Write-ColorOutput "    Control: $($violation.ControlName)" "White"
                    Write-ColorOutput "    Rule: $($violation.Rule) - $($violation.Description)" "Magenta"
                    Write-ColorOutput "    Suggestion: $($violation.Suggestion)" "Cyan"
                    Write-ColorOutput ""
                }
            }
            
            # Fix violations if requested
            if ($FixIssues) {
                Fix-MissingPropertiesViolations -FilePath $file.FullName -Content $content -Violations $violations
            }
        } else {
            Write-ColorOutput "  PASS: No missing properties violations found" "Green"
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
        Write-ColorOutput "MISSING PROPERTIES VIOLATIONS FOUND!" "Red"
        Write-ColorOutput "Rules violated: 2.5, 8.9 - Required properties validation" "Red"
        
        if (-not $FixIssues) {
            Write-ColorOutput ""
            Write-ColorOutput "Run with -FixIssues to automatically fix these violations" "Yellow"
        }
        
        exit 1
    } else {
        Write-ColorOutput ""
        Write-ColorOutput "All files comply with missing properties rules!" "Green"
        exit 0
    }
}

# Run the main function
Main 