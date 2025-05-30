# ====================================================================
# PROPERTIES & ICONS VALIDATION (RULES-COMPLIANT)
# Script: Check-PropertiesIcons.ps1
# Purpose: Validate properties and icons according to Section 5 & 6
# Rules Reference: Section 5 - Properties Guidelines, Section 6 - Icon Guidelines
# Author: AI Assistant (Rules-Based Implementation)
# Date: 2024-12-19
# Version: 2.0.0 (Clean Slate)
# ====================================================================

param(
    [string]$SourcePath = "src",
    [switch]$FixIssues,
    [switch]$Verbose
)

Write-Host "🎨 PROPERTIES & ICONS VALIDATION (RULES-COMPLIANT)" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "Rules Reference: Section 5 - Properties, Section 6 - Icons" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalViolations = 0
$filesWithViolations = 0
$results = @()

# Section 6.1: Valid Icons List from .cursorrules
$validIcons = @(
    "Add", "AddDocument", "AddLibrary", "AddToCalendar", "AddUser", "Airplane", "Alarm", 
    "ArrowDown", "ArrowLeft", "ArrowRight", "ArrowUp", "BackArrow", "Bell", "Blocked", 
    "Bookmark", "BookmarkFilled", "Bug", "Bus", "Calculator", "CalendarBlank", "Camera", 
    "CameraAperture", "Cancel", "CancelBadge", "Cars", "Check", "CheckBadge", "ChevronDown", 
    "ChevronLeft", "ChevronRight", "ChevronUp", "ClearDrawing", "Clock", "CollapseView", 
    "ColorPicker", "Compose", "ComputerDesktop", "Controller", "Copy", "Crop", "Currency", 
    "Cut", "Database", "DetailList", "Devices", "Diamond", "DockCheckProperties", "DockLeft", 
    "DockRight", "Document", "DocumentPDF", "DocumentWithContent", "Download", "Draw", "Edit", 
    "EmojiFrown", "EmojiHappy", "EmojiNeutral", "EmojiSad", "EmojiSmile", "Enhance", "Erase", 
    "Error", "ExpandView", "Export", "Filter", "FilterFlat", "FilterFlatFilled", "Flag", 
    "Folder", "ForkKnife", "Globe", "GlobeChangesPending", "GlobeError", "GlobeNotConnected", 
    "GlobeRefresh", "GlobeWarning", "HalfFilledCircle", "Hamburger", "Health", "Heart", 
    "Help", "Hide", "History", "Home", "HorizontalLine", "Hospital", "Import", "Information", 
    "Items", "Journal", "Key", "Laptop", "Leave", "LevelsLayersItems", "Lightbulb", 
    "LightningBolt", "LikeDislike", "LineWeight", "Link", "ListScrollEmpty", 
    "ListScrollWatchlist", "ListWatchlistRemind", "Location", "Lock", "LogJournal", "Mail", 
    "Manufacture", "Medical", "Message", "Microphone", "Mobile", "Money", "More", "Newspaper", 
    "NextArrow", "Note", "Notebook", "OpenInNewWindow", "OptionsList", "PaperClip", "Paste", 
    "People", "Person", "Phone", "Phonebook", "Pictures", "Pin", "Post", "Print", "Printing3D", 
    "Publish", "QuestionMark", "RadarActivityMonitor", "Redo", "Reload", "Save", "Scan", 
    "Search", "Send", "Settings", "Share", "Shirt", "Shop", "ShoppingCart", "Show", 
    "ShowDrawing", "SignOut", "Site", "SkipBack", "SkipForward", "SkipNext", "SkipPrevious", 
    "Slider", "Sort", "Speed", "Split", "SplitHorizontal", "SplitVertical", "Star", 
    "StarFilled", "Stop", "Strikethrough", "Subtract", "Support", "Sync", "Tablet", "Tag", 
    "Text", "ThumbsDown", "ThumbsDownFilled", "ThumbsUp", "ThumbsUpFilled", "Tools", "Train", 
    "Transportation", "Trash", "Tray", "Trending", "TrendingHashtag", "TrendingUpwards", 
    "Undo", "Unlock", "VerticalLine", "Video", "View", "Waffle", "Warning", "Waypoint", 
    "Weather", "ZoomIn", "ZoomOut"
)

# Section 5.1: Color Properties Validation
function Test-ColorProperties {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $lines = Get-Content $FilePath
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Rule 5.1: Always use RGBA format for colors
        if ($line -match "^\s*(Fill|Color|BorderColor):\s*=(.+)") {
            $property = $matches[1]
            $value = $matches[2].Trim()
            
            # Check if it's not RGBA format
            if ($value -notmatch "RGBA\s*\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*[\d\.]+\s*\)") {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "INVALID_COLOR_FORMAT"
                    Rule = "Section 5.1"
                    Message = "$property must use RGBA format"
                    Property = $property
                    Content = $line.Trim()
                    Suggestion = "$property = RGBA(255, 255, 255, 1)"
                }
            }
        }
    }
    
    return $violations
}

# Section 5.2: DropShadow Properties Validation
function Test-DropShadowProperties {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $lines = Get-Content $FilePath
    $validDropShadows = @("Light", "Regular", "Bold", "ExtraBold", "Semilight", "None")
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Rule 5.2: Only use valid DropShadow values
        if ($line -match "^\s*DropShadow:\s*=(.+)") {
            $value = $matches[1].Trim()
            
            $isValid = $false
            foreach ($validShadow in $validDropShadows) {
                if ($value -match "DropShadow\.$validShadow") {
                    $isValid = $true
                    break
                }
            }
            
            if (-not $isValid) {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "INVALID_DROPSHADOW_VALUE"
                    Rule = "Section 5.2"
                    Message = "DropShadow must use valid values: $($validDropShadows -join ', ')"
                    Property = "DropShadow"
                    Content = $line.Trim()
                    Suggestion = "DropShadow = DropShadow.Regular"
                }
            }
        }
    }
    
    return $violations
}

# Section 5.4: Formula Properties Validation
function Test-FormulaProperties {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $lines = Get-Content $FilePath
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Rule 5.4: All dynamic properties MUST start with =
        if ($line -match "^\s*(Visible|Text|Fill|OnSelect|OnChange|OnVisible|Default):\s*([^=].+)") {
            $property = $matches[1]
            $value = $matches[2].Trim()
            
            # Skip static text that should not have =
            if ($property -ne "Text" -or ($value -notmatch "^`".*`"$" -and $value -notmatch "^'.*'$")) {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "MISSING_FORMULA_PREFIX"
                    Rule = "Section 5.4"
                    Message = "Dynamic property $property must start with ="
                    Property = $property
                    Content = $line.Trim()
                    Suggestion = "$property = $value"
                }
            }
        }
    }
    
    return $violations
}

# Section 6.1: Icon References Validation
function Test-IconReferences {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $lines = Get-Content $FilePath
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Rule 6.1: Only use valid icon references from approved list
        if ($line -match "^\s*Icon:\s*=Icon\.(.+)") {
            $iconName = $matches[1].Trim()
            
            if ($iconName -notin $validIcons) {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "INVALID_ICON_REFERENCE"
                    Rule = "Section 6.1"
                    Message = "Icon '$iconName' is not in the approved list"
                    Property = "Icon"
                    Content = $line.Trim()
                    Suggestion = "Use valid icon from approved list (e.g., Icon.Person, Icon.Settings)"
                }
            }
        }
        
        # Check for non-existent common icons
        if ($line -match "^\s*Icon:\s*=Icon\.(Calendar|BarChart|Document)$") {
            $invalidIcon = $matches[1]
            $suggestion = switch ($invalidIcon) {
                "Calendar" { "Icon.CalendarBlank" }
                "BarChart" { "Icon.Sort" }
                "Document" { "Icon.DocumentPDF" }
            }
            
            $violations += [PSCustomObject]@{
                Line = $lineNumber
                Type = "COMMON_INVALID_ICON"
                Rule = "Section 6.1"
                Message = "Icon.$invalidIcon does not exist - use $suggestion"
                Property = "Icon"
                Content = $line.Trim()
                Suggestion = "Icon = $suggestion"
            }
        }
    }
    
    return $violations
}

# Section 5.6: Text Formatting Validation
function Test-TextFormatting {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $lines = Get-Content $FilePath
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Rule 5.6: Proper text concatenation formatting
        if ($line -match "Text:\s*=.*""[^""]*:\s") {
            $violations += [PSCustomObject]@{
                Line = $lineNumber
                Type = "IMPROPER_TEXT_FORMATTING"
                Rule = "Section 5.6"
                Message = "Use proper spacing: 'Label:' & ' ' & Value instead of 'Label: ' & Value"
                Property = "Text"
                Content = $line.Trim()
                Suggestion = "Separate colon and space in concatenation"
            }
        }
        
        # Rule 8.18: Never use Text() function with RGBA values
        if ($line -match "Text\s*\(\s*RGBA\s*\(") {
            $violations += [PSCustomObject]@{
                Line = $lineNumber
                Type = "TEXT_FUNCTION_WITH_RGBA"
                Rule = "Section 8.18"
                Message = "Text() function cannot convert RGBA values"
                Property = "Text"
                Content = $line.Trim()
                Suggestion = "Use string literals for RGBA in text"
            }
        }
    }
    
    return $violations
}

# Section 8.11: YAML Syntax for Multi-line Formulas
function Test-FormulaLength {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $lines = Get-Content $FilePath
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Rule 8.11: Check formula length and pipe operator usage
        if ($line -match "^\s*(\w+):\s*=(.+)$") {
            $property = $matches[1]
            $formula = $matches[2].Trim()
            
            # Case 1: Long formula without pipe operator (>120 chars)
            if ($formula.Length -gt 120 -and $line -notmatch ":\s*\|$") {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "LONG_FORMULA_NO_PIPE"
                    Rule = "Section 8.11"
                    Message = "Formula longer than 120 characters should use pipe operator"
                    Property = $property
                    Content = $line.Trim()
                    Suggestion = "Use multi-line format with pipe operator"
                }
            }
        }
        
        # Case 2: Pipe operator for short formula (check next line)
        if ($line -match ":\s*\|$" -and $i + 1 -lt $lines.Count) {
            $nextLine = $lines[$i + 1]
            if ($nextLine.Trim().Length -le 120) {
                $violations += [PSCustomObject]@{
                    Line = $lineNumber
                    Type = "PIPE_FOR_SHORT_FORMULA"
                    Rule = "Section 8.11"
                    Message = "Pipe operator used for short formula - use single line format"
                    Property = "Formula"
                    Content = $line.Trim()
                    Suggestion = "Use single line format for formulas ≤120 characters"
                }
            }
        }
    }
    
    return $violations
}

function Fix-PropertiesIcons {
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
            "MISSING_FORMULA_PREFIX" {
                if ($lineIndex -lt $content.Count) {
                    $line = $content[$lineIndex]
                    if ($line -match "^(\s*)(\w+):\s*([^=].+)$") {
                        $indent = $matches[1]
                        $property = $matches[2]
                        $value = $matches[3]
                        $content[$lineIndex] = "$indent$property = $value"
                        $modified = $true
                        $fixCount++
                    }
                }
            }
            "COMMON_INVALID_ICON" {
                if ($lineIndex -lt $content.Count) {
                    $content[$lineIndex] = $violation.Suggestion -replace "Icon = ", "Icon: ="
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
        
        # Run all properties/icons validations
        $allViolations += Test-ColorProperties -FilePath $file.FullName
        $allViolations += Test-DropShadowProperties -FilePath $file.FullName
        $allViolations += Test-FormulaProperties -FilePath $file.FullName
        $allViolations += Test-IconReferences -FilePath $file.FullName
        $allViolations += Test-TextFormatting -FilePath $file.FullName
        $allViolations += Test-FormulaLength -FilePath $file.FullName
        
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
                $fixCount = Fix-PropertiesIcons -FilePath $file.FullName -Violations $allViolations
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
# PROPERTIES & ICONS VALIDATION REPORT

**Rules Reference:** Section 5 - Properties Guidelines, Section 6 - Icon Guidelines  
**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  
**Script Version:** 2.0.0 (Clean Slate)  

## SUMMARY

- **Files checked:** $totalFiles
- **Files with violations:** $filesWithViolations
- **Total violations:** $totalViolations
- **Compliance rate:** $([math]::Round((($totalFiles - $filesWithViolations) / $totalFiles) * 100, 2))%

## RULES IMPLEMENTED

1. **Section 5.1:** Color properties (RGBA format)
2. **Section 5.2:** DropShadow properties validation
3. **Section 5.4:** Formula properties (= prefix)
4. **Section 5.6:** Text formatting validation
5. **Section 6.1:** Icon references validation
6. **Section 8.11:** Formula length and pipe operator usage

## VIOLATION TYPES

- **INVALID_COLOR_FORMAT:** Colors not in RGBA format
- **INVALID_DROPSHADOW_VALUE:** Invalid DropShadow values
- **MISSING_FORMULA_PREFIX:** Dynamic properties without = prefix
- **INVALID_ICON_REFERENCE:** Icons not in approved list
- **IMPROPER_TEXT_FORMATTING:** Wrong text concatenation format
- **LONG_FORMULA_NO_PIPE:** Long formulas without pipe operator

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

$reportPath = Join-Path $SourcePath "PROPERTIES_ICONS_VIOLATIONS.md"
Set-Content -Path $reportPath -Value $reportContent -Encoding UTF8

Write-Host ""
Write-Host "Report saved to: $reportPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "  Files checked: $totalFiles" -ForegroundColor White
Write-Host "  Violations found: $totalViolations" -ForegroundColor $(if ($totalViolations -eq 0) { "Green" } else { "Red" })
Write-Host "  Compliance rate: $([math]::Round((($totalFiles - $filesWithViolations) / $totalFiles) * 100, 2))%" -ForegroundColor $(if ($totalViolations -eq 0) { "Green" } else { "Yellow" })

if ($totalViolations -eq 0) {
    Write-Host "`n✅ All files comply with properties & icons rules!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n❌ Found $totalViolations violations of properties & icons rules!" -ForegroundColor Red
    exit 1
} 