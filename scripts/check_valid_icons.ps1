# PowerShell Script to validate Power App Icons
# Usage: .\check_valid_icons.ps1

param(
    [string]$SourcePath = "src",
    [string]$OutputFile = "src/ICON_VALIDATION_RESULTS.md"
)

Write-Host "KIEM TRA ICON POWER APP" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

# Danh sách icon hợp lệ từ power-app-rules
$ValidIcons = @(
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
    "GlobeRefresh", "GlobeWarning", "HalfFilledCircle", "Hamburger", "Health", "Heart", "Help", 
    "Hide", "History", "Home", "HorizontalLine", "Hospital", "Import", "Information", "Items", 
    "Journal", "Key", "Laptop", "Leave", "LevelsLayersItems", "Lightbulb", "LightningBolt", 
    "LikeDislike", "LineWeight", "Link", "ListScrollEmpty", "ListScrollWatchlist", 
    "ListWatchlistRemind", "Location", "Lock", "LogJournal", "Mail", "Manufacture", "Medical", 
    "Message", "Microphone", "Mobile", "Money", "More", "Newspaper", "NextArrow", "Note", 
    "Notebook", "OpenInNewWindow", "OptionsList", "PaperClip", "Paste", "People", "Person", 
    "Phone", "Phonebook", "Pictures", "Pin", "Post", "Print", "Printing3D", "Publish", 
    "QuestionMark", "RadarActivityMonitor", "Redo", "Reload", "Save", "Scan", "Search", "Send", 
    "Settings", "Share", "Shirt", "Shop", "ShoppingCart", "Show", "ShowDrawing", "SignOut", 
    "Site", "SkipBack", "SkipForward", "SkipNext", "SkipPrevious", "Slider", "Sort", "Speed", 
    "Split", "SplitHorizontal", "SplitVertical", "Star", "StarFilled", "Stop", "Strikethrough", 
    "Subtract", "Support", "Sync", "Tablet", "Tag", "Text", "ThumbsDown", "ThumbsDownFilled", 
    "ThumbsUp", "ThumbsUpFilled", "Tools", "Train", "Transportation", "Trash", "Tray", 
    "Trending", "TrendingHashtag", "TrendingUpwards", "Undo", "Unlock", "VerticalLine", "Video", 
    "View", "Waffle", "Warning", "Waypoint", "Weather", "ZoomIn", "ZoomOut"
)

$totalFiles = 0
$totalIcons = 0
$invalidIcons = @()
$results = @()

# Function to extract icons from YAML content
function Get-IconsFromFile {
    param([string]$FilePath)
    
    $content = Get-Content $FilePath -Raw
    # Tìm chỉ pattern Icon: =Icon.IconName hoặc trong giá trị
    $iconMatches = [regex]::Matches($content, "Icon:\s*=\s*Icon\.(\w+)|=\s*Icon\.(\w+)")
    
    $icons = @()
    foreach ($match in $iconMatches) {
        # Check both capture groups
        $iconName = if($match.Groups[1].Value) { $match.Groups[1].Value } else { $match.Groups[2].Value }
        if ($iconName -and $iconName -ne "") {
            $lineNumber = ($content.Substring(0, $match.Index) -split "`n").Count
            $icons += [PSCustomObject]@{
                Name = $iconName
                Line = $lineNumber
                IsValid = $ValidIcons -contains $iconName
            }
        }
    }
    
    return $icons
}

# Get all YAML files
$yamlFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.yaml"

foreach ($file in $yamlFiles) {
    $totalFiles++
    Write-Host "Kiem tra: $($file.Name)" -ForegroundColor Yellow
    
    $icons = Get-IconsFromFile -FilePath $file.FullName
    $totalIcons += $icons.Count
    
    $fileInvalidIcons = $icons | Where-Object { -not $_.IsValid }
    
    if ($fileInvalidIcons.Count -gt 0) {
        $invalidIcons += $fileInvalidIcons
        $results += [PSCustomObject]@{
            File = $file.FullName.Replace((Get-Location).Path + "\", "")
            ValidIcons = ($icons | Where-Object { $_.IsValid }).Count
            InvalidIcons = $fileInvalidIcons.Count
            InvalidIconsList = $fileInvalidIcons
        }
        
        Write-Host "  $($fileInvalidIcons.Count) icon khong hop le" -ForegroundColor Red
        foreach ($invalid in $fileInvalidIcons) {
            Write-Host "    Line $($invalid.Line): Icon.$($invalid.Name)" -ForegroundColor Red
        }
    } elseif ($icons.Count -gt 0) {
        Write-Host "  $($icons.Count) icon hop le" -ForegroundColor Green
    } else {
        Write-Host "  Khong co icon" -ForegroundColor Gray
    }
}

# Create detailed report
$report = "# KET QUA KIEM TRA ICON POWER APP`n`n"
$report += "**Thoi gian:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
$report += "**Tong files kiem tra:** $totalFiles`n"
$report += "**Tong icon tim thay:** $totalIcons`n"
$report += "**Icon khong hop le:** $($invalidIcons.Count)`n`n"

if ($invalidIcons.Count -eq 0) {
    $report += "## ✅ TAT CA ICON DAT CHUAN`n`n"
    $report += "Khong co icon khong hop le nao duoc tim thay.`n`n"
} else {
    $report += "## ❌ ICON KHONG HOP LE`n`n"
    
    foreach ($result in $results) {
        $report += "### $($result.File)`n"
        $report += "- **Icon hop le:** $($result.ValidIcons)`n"
        $report += "- **Icon khong hop le:** $($result.InvalidIcons)`n`n"
        
        foreach ($invalid in $result.InvalidIconsList) {
            $report += "- **Line $($invalid.Line):** ``Icon.$($invalid.Name)`` ❌`n"
        }
        $report += "`n"
    }
    
    $report += "---`n`n"
    $report += "## ICON KHONG HOP LE THEO LOAI`n`n"
    
    $groupedIcons = $invalidIcons | Group-Object Name | Sort-Object Count -Descending
    foreach ($group in $groupedIcons) {
        $report += "### ``Icon.$($group.Name)`` ($($group.Count) lan)`n"
        $files = $results | Where-Object { $_.InvalidIconsList.Name -contains $group.Name }
        foreach ($file in $files) {
            $lines = ($file.InvalidIconsList | Where-Object { $_.Name -eq $group.Name }).Line
            $report += "- $($file.File) (Line: $($lines -join ', '))`n"
        }
        $report += "`n"
    }
}

$report += "---`n`n"
$report += "## DANH SACH ICON HOP LE`n`n"
$report += "**Tong cong:** $($ValidIcons.Count) icon`n`n"

# Group icons alphabetically
$groupedValidIcons = $ValidIcons | Sort-Object | Group-Object { $_.Substring(0,1).ToUpper() }
foreach ($letterGroup in $groupedValidIcons) {
    $report += "### $($letterGroup.Name)`n"
    $iconList = $letterGroup.Group | ForEach-Object { "``Icon.$_``" }
    $report += ($iconList -join ", ") + "`n`n"
}

$report += "---`n`n"
$report += "## GOI Y THAY THE ICON`n`n"

# Common icon mapping suggestions
$iconMappings = @{
    "Calendar" = "CalendarBlank"
    "User" = "Person"
    "Profile" = "Person"
    "Account" = "Person"
    "Date" = "CalendarBlank"
    "Schedule" = "CalendarBlank"
    "Email" = "Mail"
    "Call" = "Phone"
    "Delete" = "Cancel"
    "Remove" = "Cancel"
    "Close" = "Cancel"
    "Success" = "CheckBadge"
    "Info" = "Information"
    "Up" = "ChevronUp"
    "Down" = "ChevronDown"
    "Left" = "ChevronLeft"
    "Right" = "ChevronRight"
}

foreach ($mapping in $iconMappings.GetEnumerator()) {
    $report += "- ``Icon.$($mapping.Key)`` → ``Icon.$($mapping.Value)``"
    if ($ValidIcons -contains $mapping.Value) {
        $report += " ✅`n"
    } else {
        $report += " ❌ (Icon khong hop le)`n"
    }
}

# Write report
$report | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "`nTONG KET:" -ForegroundColor Cyan
Write-Host "Files kiem tra: $totalFiles" -ForegroundColor White
Write-Host "Tong icon: $totalIcons" -ForegroundColor White
Write-Host "Icon khong hop le: $($invalidIcons.Count)" -ForegroundColor $(if($invalidIcons.Count -gt 0) {"Red"} else {"Green"})
Write-Host "Bao cao: $OutputFile" -ForegroundColor White

if ($invalidIcons.Count -gt 0) {
    Write-Host "`nCO ICON KHONG HOP LE!" -ForegroundColor Red
    
    # Show summary of invalid icons
    $uniqueInvalid = $invalidIcons | Select-Object Name -Unique | Sort-Object Name
    Write-Host "`nIcon khong hop le:" -ForegroundColor Red
    foreach ($icon in $uniqueInvalid) {
        Write-Host "  - Icon.$($icon.Name)" -ForegroundColor Red
    }
    
    exit 1
} else {
    Write-Host "`nTAT CA ICON DAT CHUAN!" -ForegroundColor Green
    exit 0
} 