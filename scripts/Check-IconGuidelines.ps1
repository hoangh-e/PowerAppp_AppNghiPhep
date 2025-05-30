# ====================================================================
# CHECK ICON GUIDELINES VIOLATIONS
# Script: Check-IconGuidelines.ps1
# Purpose: Validate Icon Guidelines according to Section 6 of .cursorrules
# Rules Reference: Section 6 - Icon Guidelines
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$TargetFile = "",
    [switch]$Verbose
)

Write-Host "🎨 ICON GUIDELINES VALIDATION" -ForegroundColor Blue
Write-Host "=============================" -ForegroundColor Blue
Write-Host "Rules Reference: Section 6 - Icon Guidelines" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalViolations = 0
$results = @()

# Allowed icons from Section 6.1
$allowedIcons = @(
    "Add", "AddDocument", "AddLibrary", "AddToCalendar", "AddUser", "Airplane", "Alarm", "ArrowDown", "ArrowLeft", "ArrowRight", "ArrowUp", "BackArrow", "Bell", "Blocked", "Bookmark", "BookmarkFilled", "Bug", "Bus", "Calculator", "CalendarBlank", "Camera", "CameraAperture", "Cancel", "CancelBadge", "Cars", "Check", "CheckBadge", "ChevronDown", "ChevronLeft", "ChevronRight", "ChevronUp", "ClearDrawing", "Clock", "CollapseView", "ColorPicker", "Compose", "ComputerDesktop", "Controller", "Copy", "Crop", "Currency", "Cut", "Database", "DetailList", "Devices", "Diamond", "DockCheckProperties", "DockLeft", "DockRight", "Document", "DocumentPDF", "DocumentWithContent", "Download", "Draw", "Edit", "EmojiFrown", "EmojiHappy", "EmojiNeutral", "EmojiSad", "EmojiSmile", "Enhance", "Erase", "Error", "ExpandView", "Export", "Filter", "FilterFlat", "FilterFlatFilled", "Flag", "Folder", "ForkKnife", "Globe", "GlobeChangesPending", "GlobeError", "GlobeNotConnected", "GlobeRefresh", "GlobeWarning", "HalfFilledCircle", "Hamburger", "Health", "Heart", "Help", "Hide", "History", "Home", "HorizontalLine", "Hospital", "Import", "Information", "Items", "Journal", "Key", "Laptop", "Leave", "LevelsLayersItems", "Lightbulb", "LightningBolt", "LikeDislike", "LineWeight", "Link", "ListScrollEmpty", "ListScrollWatchlist", "ListWatchlistRemind", "Location", "Lock", "LogJournal", "Mail", "Manufacture", "Medical", "Message", "Microphone", "Mobile", "Money", "More", "Newspaper", "NextArrow", "Note", "Notebook", "OpenInNewWindow", "OptionsList", "PaperClip", "Paste", "People", "Person", "Phone", "Phonebook", "Pictures", "Pin", "Post", "Print", "Printing3D", "Publish", "QuestionMark", "RadarActivityMonitor", "Redo", "Reload", "Save", "Scan", "Search", "Send", "Settings", "Share", "Shirt", "Shop", "ShoppingCart", "Show", "ShowDrawing", "SignOut", "Site", "SkipBack", "SkipForward", "SkipNext", "SkipPrevious", "Slider", "Sort", "Speed", "Split", "SplitHorizontal", "SplitVertical", "Star", "StarFilled", "Stop", "Strikethrough", "Subtract", "Support", "Sync", "Tablet", "Tag", "Text", "ThumbsDown", "ThumbsDownFilled", "ThumbsUp", "ThumbsUpFilled", "Tools", "Train", "Transportation", "Trash", "Tray", "Trending", "TrendingHashtag", "TrendingUpwards", "Undo", "Unlock", "VerticalLine", "Video", "View", "Waffle", "Warning", "Waypoint", "Weather", "ZoomIn", "ZoomOut"
)

function Check-IconGuidelinesViolations {
    param(
        [string]$FilePath
    )
    
    $violations = @()
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $lines = Get-Content -Path $FilePath -Encoding UTF8
    
    # Rule 6.1: Check for invalid icon references
    $iconMatches = [regex]::Matches($content, "Icon`:\s*=Icon\.(\w+)")
    foreach ($match in $iconMatches) {
        $iconName = $match.Groups[1].Value
        $lineNumber = ($lines | Select-String -Pattern "Icon`:\s*=Icon\.$([regex]::Escape($iconName))" | Select-Object -First 1).LineNumber
        
        if ($iconName -notin $allowedIcons) {
            $violations += @{
                Rule = "6.1"
                Type = "Invalid Icon Reference"
                Line = $lineNumber
                Issue = "Icon '$iconName' is not in the approved list"
                Current = "Icon: =Icon.$iconName"
                Suggested = "Icon: =Icon.$(Get-SuggestedIcon -IconName $iconName)"
                Severity = "High"
            }
        }
    }
    
    # Rule 6.2: Check for common icon mapping mistakes
    $commonMistakes = @{
        "Calendar" = "CalendarBlank"
        "User" = "Person"
        "Profile" = "Person"
        "Account" = "Person"
        "Email" = "Mail"
        "Call" = "Phone"
        "Delete" = "Cancel"
        "Remove" = "Cancel"
        "Success" = "CheckBadge"
        "Info" = "Information"
        "Up" = "ChevronUp"
        "Down" = "ChevronDown"
        "Left" = "ChevronLeft"
        "Right" = "ChevronRight"
        "Back" = "BackArrow"
        "Next" = "NextArrow"
    }
    
    foreach ($mistake in $commonMistakes.Keys) {
        $correct = $commonMistakes[$mistake]
        if ($content -match "Icon`:\s*=Icon\.$mistake\b") {
            $lineNumber = ($lines | Select-String -Pattern "Icon`:\s*=Icon\.$mistake\b" | Select-Object -First 1).LineNumber
            $violations += @{
                Rule = "6.2"
                Type = "Common Icon Mistake"
                Line = $lineNumber
                Issue = "Using common incorrect icon '$mistake'"
                Current = "Icon: =Icon.$mistake"
                Suggested = "Icon: =Icon.$correct"
                Severity = "Medium"
            }
        }
    }
    
    # Rule 6.1: Check for non-existent custom icons
    $customIconPatterns = @(
        "CustomIcon", "MyIcon", "SpecialIcon", "RandomIcon", "UndefinedIcon"
    )
    
    foreach ($pattern in $customIconPatterns) {
        if ($content -match "Icon`:\s*=Icon\.$pattern") {
            $lineNumber = ($lines | Select-String -Pattern "Icon`:\s*=Icon\.$pattern" | Select-Object -First 1).LineNumber
            $violations += @{
                Rule = "6.1"
                Type = "Custom Icon Reference"
                Line = $lineNumber
                Issue = "Using non-existent custom icon '$pattern'"
                Current = "Icon: =Icon.$pattern"
                Suggested = "Icon: =Icon.$(Get-SuggestedIcon -IconName $pattern)"
                Severity = "Critical"
            }
        }
    }
    
    return $violations
}

function Get-SuggestedIcon {
    param([string]$IconName)
    
    # Suggest appropriate icons based on common use cases
    $suggestions = @{
        "Calendar" = "CalendarBlank"
        "User" = "Person"
        "Profile" = "Person"
        "Account" = "Person"
        "Email" = "Mail"
        "Call" = "Phone"
        "Delete" = "Cancel"
        "Remove" = "Cancel"
        "Success" = "CheckBadge"
        "Info" = "Information"
        "CustomIcon" = "Settings"
        "MyIcon" = "Person"
        "SpecialIcon" = "Star"
        "RandomIcon" = "More"
        "UndefinedIcon" = "QuestionMark"
    }
    
    if ($suggestions.ContainsKey($IconName)) {
        return $suggestions[$IconName]
    }
    
    # Default suggestions based on common patterns
    if ($IconName -match "(?i)user|person|profile") { return "Person" }
    if ($IconName -match "(?i)calendar|date|time") { return "CalendarBlank" }
    if ($IconName -match "(?i)mail|email|message") { return "Mail" }
    if ($IconName -match "(?i)phone|call") { return "Phone" }
    if ($IconName -match "(?i)add|plus|new") { return "Add" }
    if ($IconName -match "(?i)edit|modify") { return "Edit" }
    if ($IconName -match "(?i)delete|remove|cancel") { return "Cancel" }
    if ($IconName -match "(?i)save") { return "Save" }
    if ($IconName -match "(?i)search|find") { return "Search" }
    if ($IconName -match "(?i)settings|config") { return "Settings" }
    if ($IconName -match "(?i)home") { return "Home" }
    if ($IconName -match "(?i)back") { return "BackArrow" }
    if ($IconName -match "(?i)next|forward") { return "NextArrow" }
    if ($IconName -match "(?i)up") { return "ChevronUp" }
    if ($IconName -match "(?i)down") { return "ChevronDown" }
    if ($IconName -match "(?i)left") { return "ChevronLeft" }
    if ($IconName -match "(?i)right") { return "ChevronRight" }
    
    return "QuestionMark"  # Default fallback
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
    $violations = Check-IconGuidelinesViolations -FilePath $file
    
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
Write-Host "ICON GUIDELINES VALIDATION SUMMARY" -ForegroundColor Blue
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
    Write-Host "💡 Run Fix-IconGuidelines.ps1 to auto-fix these violations" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "✅ No icon guideline violations found!" -ForegroundColor Green
}

exit $totalViolations 