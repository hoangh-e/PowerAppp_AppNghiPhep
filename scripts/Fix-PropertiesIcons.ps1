# ====================================================================
# FIX PROPERTIES & ICONS VIOLATIONS
# Script: Fix-PropertiesIcons.ps1
# Purpose: Auto-fix properties and icons violations detected by Check-PropertiesIcons.ps1
# Rules Reference: Section 5 - Properties, Section 6 - Icons
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$TargetFile = "",
    [switch]$DryRun,
    [switch]$Verbose
)

Write-Host "🎨 PROPERTIES & ICONS AUTO-FIX" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host "Rules Reference: Section 5-6 - Properties & Icons" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalFixes = 0
$results = @()

# Valid icons from rules
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

# Icon mapping for common invalid icons
$iconMapping = @{
    "Calendar" = "CalendarBlank"
    "BarChart" = "Sort" 
    "Document" = "DocumentPDF"
    "User" = "Person"
    "Profile" = "Person"
    "Account" = "Person"
    "Email" = "Mail"
    "Call" = "Phone"
    "Delete" = "Cancel"
    "Remove" = "Cancel"
    "Close" = "Cancel"
}

function Fix-PropertiesAndIcons {
    param(
        [string]$FilePath
    )
    
    $fixes = @()
    $lines = Get-Content $FilePath
    $modified = $false
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Fix 1: Add missing = prefix for dynamic properties
        if ($line -match "^\s*(Visible|Text|Fill|OnSelect|OnChange|OnVisible|Default):\s*([^=].+)") {
            $property = $matches[1]
            $value = $matches[2].Trim()
            
            # Skip static text that should not have =
            if (-not ($property -eq "Text" -and ($value -match "^`".*`"$" -or $value -match "^'.*'$"))) {
                $lines[$i] = $line -replace "^(\s*)($property):\s*([^=].+)$", "`$1`$2: =`$3"
                $modified = $true
                $fixes += "Added = prefix to $property on line $lineNumber"
            }
        }
        
        # Fix 2: Fix invalid icon references
        if ($line -match "^\s*Icon:\s*=Icon\.(.+)") {
            $iconName = $matches[1].Trim()
            
            if ($iconName -notin $validIcons) {
                # Check if we have a mapping for this icon
                if ($iconMapping.ContainsKey($iconName)) {
                    $newIcon = $iconMapping[$iconName]
                    $lines[$i] = $line -replace "Icon\.$iconName", "Icon.$newIcon"
                    $modified = $true
                    $fixes += "Changed invalid icon Icon.$iconName to Icon.$newIcon on line $lineNumber"
                }
                # Handle common invalid icons
                elseif ($iconName -eq "Calendar") {
                    $lines[$i] = $line -replace "Icon\.Calendar", "Icon.CalendarBlank"
                    $modified = $true
                    $fixes += "Changed Icon.Calendar to Icon.CalendarBlank on line $lineNumber"
                }
                elseif ($iconName -eq "Document") {
                    $lines[$i] = $line -replace "Icon\.Document", "Icon.DocumentPDF"
                    $modified = $true
                    $fixes += "Changed Icon.Document to Icon.DocumentPDF on line $lineNumber"
                }
                else {
                    # Default to a safe icon
                    $lines[$i] = $line -replace "Icon\.$iconName", "Icon.Information"
                    $modified = $true
                    $fixes += "Changed invalid icon Icon.$iconName to Icon.Information on line $lineNumber"
                }
            }
        }
        
        # Fix 3: Fix color format to RGBA
        if ($line -match "^\s*(Fill|Color|BorderColor):\s*=(.+)") {
            $property = $matches[1]
            $value = $matches[2].Trim()
            
            # Simple fixes for common non-RGBA colors
            if ($value -match "^Color\.White$") {
                $lines[$i] = $line -replace "Color\.White", "RGBA(255, 255, 255, 1)"
                $modified = $true
                $fixes += "Changed Color.White to RGBA format on line $lineNumber"
            }
            elseif ($value -match "^Color\.Black$") {
                $lines[$i] = $line -replace "Color\.Black", "RGBA(0, 0, 0, 1)"
                $modified = $true
                $fixes += "Changed Color.Black to RGBA format on line $lineNumber"
            }
            elseif ($value -match "^Color\.Blue$") {
                $lines[$i] = $line -replace "Color\.Blue", "RGBA(0, 120, 212, 1)"
                $modified = $true
                $fixes += "Changed Color.Blue to RGBA format on line $lineNumber"
            }
            elseif ($value -match "^Color\.Red$") {
                $lines[$i] = $line -replace "Color\.Red", "RGBA(220, 53, 69, 1)"
                $modified = $true
                $fixes += "Changed Color.Red to RGBA format on line $lineNumber"
            }
            elseif ($value -match "^Color\.Green$") {
                $lines[$i] = $line -replace "Color\.Green", "RGBA(40, 167, 69, 1)"
                $modified = $true
                $fixes += "Changed Color.Green to RGBA format on line $lineNumber"
            }
        }
        
        # Fix 4: Fix DropShadow invalid values
        if ($line -match "^\s*DropShadow:\s*=(.+)") {
            $value = $matches[1].Trim()
            
            if ($value -notmatch "DropShadow\.(Light|Regular|Bold|ExtraBold|Semilight|None)") {
                $lines[$i] = $line -replace "=.+$", "=DropShadow.Regular"
                $modified = $true
                $fixes += "Fixed invalid DropShadow value to DropShadow.Regular on line $lineNumber"
            }
        }
        
        # Fix 5: Fix text formatting - remove spaces after colons
        if ($line -match "Text:\s*=.*`"[^`"]*:\s") {
            # This is a complex fix, for now just flag it
            # In a real implementation, we'd need more sophisticated parsing
            $fixes += "WARNING: Text formatting may need manual fix on line $lineNumber (spaces after colon)"
        }
    }
    
    return @{
        Modified = $modified
        Lines = $lines
        Fixes = $fixes
    }
}

# Main processing
if ($TargetFile) {
    $yamlFiles = @(Get-Item $TargetFile)
} else {
    $yamlFiles = Get-ChildItem -Path $SourcePath -Recurse -Include "*.yaml", "*.yml" | Where-Object { !$_.PSIsContainer }
}

Write-Host "Found $($yamlFiles.Count) YAML files to process" -ForegroundColor Yellow
Write-Host ""

foreach ($file in $yamlFiles) {
    $totalFiles++
    Write-Host "Processing: $($file.Name)" -ForegroundColor White
    
    try {
        $result = Fix-PropertiesAndIcons -FilePath $file.FullName
        
        if ($result.Modified) {
            $fileFixes = $result.Fixes.Count
            
            if ($DryRun) {
                Write-Host "  DRY RUN: Would apply $fileFixes fixes:" -ForegroundColor Yellow
                foreach ($fix in $result.Fixes) {
                    Write-Host "    - $fix" -ForegroundColor Yellow
                }
            } else {
                Set-Content -Path $file.FullName -Value $result.Lines -Encoding UTF8
                Write-Host "  APPLIED: $fileFixes fixes" -ForegroundColor Green
                if ($Verbose) {
                    foreach ($fix in $result.Fixes) {
                        Write-Host "    - $fix" -ForegroundColor Green
                    }
                }
            }
            
            $totalFixes += $fileFixes
            $results += [PSCustomObject]@{
                File = $file.Name
                Path = $file.FullName
                Fixes = $fileFixes
                Applied = -not $DryRun
            }
        } else {
            Write-Host "  SKIP: No fixes needed" -ForegroundColor Gray
        }
        
    }
    catch {
        Write-Host "  ERROR: Failed to process file - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Summary
Write-Host ""
Write-Host "=" * 50 -ForegroundColor Green
Write-Host "FIX SUMMARY:" -ForegroundColor Green
Write-Host "  Files processed: $totalFiles" -ForegroundColor White
Write-Host "  Files with fixes: $($results.Count)" -ForegroundColor White
Write-Host "  Total fixes: $totalFixes" -ForegroundColor White
Write-Host "  Mode: $(if ($DryRun) { 'DRY RUN' } else { 'APPLIED' })" -ForegroundColor $(if ($DryRun) { 'Yellow' } else { 'Green' })

if ($results.Count -gt 0) {
    Write-Host ""
    Write-Host "FILES WITH FIXES:" -ForegroundColor Green
    foreach ($result in $results) {
        $status = if ($result.Applied) { "FIXED" } else { "PLANNED" }
        Write-Host "  $status - $($result.File) ($($result.Fixes) fixes)" -ForegroundColor $(if ($result.Applied) { 'Green' } else { 'Yellow' })
    }
}

if (-not $DryRun -and $totalFixes -gt 0) {
    Write-Host ""
    Write-Host "✅ Applied $totalFixes fixes successfully!" -ForegroundColor Green
    Write-Host "💡 Run Check-PropertiesIcons.ps1 again to verify fixes" -ForegroundColor Cyan
} 