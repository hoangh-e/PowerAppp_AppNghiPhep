# ====================================================================
# FIX ICON GUIDELINES VIOLATIONS
# Script: Fix-IconGuidelines.ps1
# Purpose: Auto-fix icon guidelines violations detected by Check-IconGuidelines.ps1
# Rules Reference: Section 6 - Icon Guidelines
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$TargetFile = "",
    [switch]$DryRun,
    [switch]$Verbose
)

Write-Host "🎨 ICON GUIDELINES AUTO-FIX" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
Write-Host "Rules Reference: Section 6 - Icon Guidelines" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalFixes = 0
$results = @()

function Fix-IconGuidelinesViolations {
    param(
        [string]$FilePath
    )
    
    $fixes = @()
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $originalContent = $content
    
    # Rule 6.2: Fix common icon mapping mistakes
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
        if ($content -match "Icon`:\s*=Icon\.$mistake") {
            $content = $content -replace "Icon`:\s*=Icon\.$mistake", "Icon: =Icon.$correct"
            $fixes += @{
                Rule = "6.2"
                Type = "Common Icon Mistake Fix"
                Description = "Changed Icon.$mistake to Icon.$correct"
            }
        }
    }
    
    # Rule 6.1: Fix non-existent custom icons
    $customIconMappings = @{
        "CustomIcon" = "Settings"
        "MyIcon" = "Person"
        "SpecialIcon" = "Star"
        "RandomIcon" = "More"
        "UndefinedIcon" = "QuestionMark"
    }
    
    foreach ($customIcon in $customIconMappings.Keys) {
        $replacement = $customIconMappings[$customIcon]
        if ($content -match "Icon`:\s*=Icon\.$customIcon") {
            $content = $content -replace "Icon`:\s*=Icon\.$customIcon", "Icon: =Icon.$replacement"
            $fixes += @{
                Rule = "6.1"
                Type = "Custom Icon Fix"
                Description = "Changed non-existent Icon.$customIcon to Icon.$replacement"
            }
        }
    }
    
    # Rule 6.1: Fix other invalid icons with intelligent suggestions
    $allowedIcons = @(
        "Add", "AddDocument", "AddLibrary", "AddToCalendar", "AddUser", "Airplane", "Alarm", "ArrowDown", "ArrowLeft", "ArrowRight", "ArrowUp", "BackArrow", "Bell", "Blocked", "Bookmark", "BookmarkFilled", "Bug", "Bus", "Calculator", "CalendarBlank", "Camera", "CameraAperture", "Cancel", "CancelBadge", "Cars", "Check", "CheckBadge", "ChevronDown", "ChevronLeft", "ChevronRight", "ChevronUp", "ClearDrawing", "Clock", "CollapseView", "ColorPicker", "Compose", "ComputerDesktop", "Controller", "Copy", "Crop", "Currency", "Cut", "Database", "DetailList", "Devices", "Diamond", "DockCheckProperties", "DockLeft", "DockRight", "Document", "DocumentPDF", "DocumentWithContent", "Download", "Draw", "Edit", "EmojiFrown", "EmojiHappy", "EmojiNeutral", "EmojiSad", "EmojiSmile", "Enhance", "Erase", "Error", "ExpandView", "Export", "Filter", "FilterFlat", "FilterFlatFilled", "Flag", "Folder", "ForkKnife", "Globe", "GlobeChangesPending", "GlobeError", "GlobeNotConnected", "GlobeRefresh", "GlobeWarning", "HalfFilledCircle", "Hamburger", "Health", "Heart", "Help", "Hide", "History", "Home", "HorizontalLine", "Hospital", "Import", "Information", "Items", "Journal", "Key", "Laptop", "Leave", "LevelsLayersItems", "Lightbulb", "LightningBolt", "LikeDislike", "LineWeight", "Link", "ListScrollEmpty", "ListScrollWatchlist", "ListWatchlistRemind", "Location", "Lock", "LogJournal", "Mail", "Manufacture", "Medical", "Message", "Microphone", "Mobile", "Money", "More", "Newspaper", "NextArrow", "Note", "Notebook", "OpenInNewWindow", "OptionsList", "PaperClip", "Paste", "People", "Person", "Phone", "Phonebook", "Pictures", "Pin", "Post", "Print", "Printing3D", "Publish", "QuestionMark", "RadarActivityMonitor", "Redo", "Reload", "Save", "Scan", "Search", "Send", "Settings", "Share", "Shirt", "Shop", "ShoppingCart", "Show", "ShowDrawing", "SignOut", "Site", "SkipBack", "SkipForward", "SkipNext", "SkipPrevious", "Slider", "Sort", "Speed", "Split", "SplitHorizontal", "SplitVertical", "Star", "StarFilled", "Stop", "Strikethrough", "Subtract", "Support", "Sync", "Tablet", "Tag", "Text", "ThumbsDown", "ThumbsDownFilled", "ThumbsUp", "ThumbsUpFilled", "Tools", "Train", "Transportation", "Trash", "Tray", "Trending", "TrendingHashtag", "TrendingUpwards", "Undo", "Unlock", "VerticalLine", "Video", "View", "Waffle", "Warning", "Waypoint", "Weather", "ZoomIn", "ZoomOut"
    )
    
    # Find all icon references and fix invalid ones
    $iconMatches = [regex]::Matches($content, "Icon`:\s*=Icon\.(\w+)")
    foreach ($match in $iconMatches) {
        $iconName = $match.Groups[1].Value
        
        if ($iconName -notin $allowedIcons -and $iconName -notin $commonMistakes.Keys -and $iconName -notin $customIconMappings.Keys) {
            $suggestedIcon = Get-SuggestedIcon -IconName $iconName
            $content = $content -replace "Icon`:\s*=Icon\.$iconName", "Icon: =Icon.$suggestedIcon"
            $fixes += @{
                Rule = "6.1"
                Type = "Invalid Icon Fix"
                Description = "Changed invalid Icon.$iconName to Icon.$suggestedIcon"
            }
        }
    }
    
    # Apply fixes if content changed
    if ($content -ne $originalContent -and -not $DryRun) {
        Set-Content -Path $FilePath -Value $content -Encoding UTF8
    }
    
    return $fixes
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
    $fixes = Fix-IconGuidelinesViolations -FilePath $file
    
    if ($fixes.Count -gt 0) {
        $totalFixes += $fixes.Count
        $results += @{
            File = $file
            Fixes = $fixes
        }
        
        $status = if ($DryRun) { "DRY RUN" } else { "FIXED" }
        Write-Host "📄 $file [$status]" -ForegroundColor White
        
        foreach ($fix in $fixes) {
            $typeColor = switch ($fix.Type) {
                "Common Icon Mistake Fix" { "Yellow" }
                "Custom Icon Fix" { "Red" }
                "Invalid Icon Fix" { "Cyan" }
                default { "Gray" }
            }
            
            Write-Host "  ✅ $($fix.Type)" -ForegroundColor $typeColor
            Write-Host "     Rule: $($fix.Rule) | $($fix.Description)" -ForegroundColor Gray
        }
        Write-Host ""
    }
}

# Summary
Write-Host "=" * 60 -ForegroundColor Green
Write-Host "ICON GUIDELINES FIX SUMMARY" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Green
Write-Host ""

$mode = if ($DryRun) { "DRY RUN MODE" } else { "LIVE MODE" }
Write-Host "Mode: $mode" -ForegroundColor $(if ($DryRun) { 'Yellow' } else { 'Green' })
Write-Host "Files processed: $totalFiles" -ForegroundColor White
Write-Host "Total fixes: $totalFixes" -ForegroundColor $(if ($totalFixes -eq 0) { 'Yellow' } else { 'Green' })

if ($totalFixes -gt 0) {
    Write-Host ""
    Write-Host "FIX BREAKDOWN:" -ForegroundColor Yellow
    
    $fixTypes = $results | ForEach-Object { $_.Fixes } | Group-Object Type
    foreach ($type in $fixTypes) {
        Write-Host "  $($type.Name): $($type.Count)" -ForegroundColor White
    }
    
    if ($DryRun) {
        Write-Host ""
        Write-Host "💡 Run without -DryRun to apply these fixes" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "✅ All fixes have been applied!" -ForegroundColor Green
        Write-Host "💡 Run Check-IconGuidelines.ps1 to verify the fixes" -ForegroundColor Cyan
    }
} else {
    Write-Host ""
    Write-Host "✅ No icon guideline violations found to fix!" -ForegroundColor Green
}

exit 0 