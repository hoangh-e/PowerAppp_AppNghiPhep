# ====================================================================
# FIX TEXT FORMATTING VIOLATIONS
# Script: Fix-TextFormatting.ps1
# Purpose: Auto-fix text formatting violations detected by Check-TextFormatting.ps1
# Rules Reference: Section 5.6 - Text Formatting & Section 8.18 - Text Function with RGBA
# Date: 2024-12-19
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string]$TargetFile = "",
    [switch]$DryRun,
    [switch]$Verbose
)

Write-Host "📝 TEXT FORMATTING AUTO-FIX" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host "Rules Reference: Section 5.6 - Text Formatting" -ForegroundColor Yellow
Write-Host ""

$totalFiles = 0
$totalFixes = 0
$results = @()

function Fix-TextFormattingViolations {
    param(
        [string]$FilePath
    )
    
    $fixes = @()
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $originalContent = $content
    
    # Rule 5.6: Fix common text patterns with space after colon
    $commonPatterns = @{
        '"Email: "' = '"Email:" & " "'
        '"Status: "' = '"Status:" & " "'
        '"Name: "' = '"Name:" & " "'
        '"Date: "' = '"Date:" & " "'
        '"Time: "' = '"Time:" & " "'
        '"User: "' = '"User:" & " "'
        '"Role: "' = '"Role:" & " "'
        '"Department: "' = '"Department:" & " "'
        '"Phone: "' = '"Phone:" & " "'
        '"Address: "' = '"Address:" & " "'
        '"Demo: "' = '"Demo:" & " "'
        '"Tên: "' = '"Tên:" & " "'
        '"Ngày: "' = '"Ngày:" & " "'
        '"Thời gian: "' = '"Thời gian:" & " "'
        '"Trạng thái: "' = '"Trạng thái:" & " "'
        '"Phòng ban: "' = '"Phòng ban:" & " "'
        '"Chức vụ: "' = '"Chức vụ:" & " "'
    }
    
    foreach ($pattern in $commonPatterns.Keys) {
        $suggestion = $commonPatterns[$pattern]
        if ($content -match [regex]::Escape($pattern)) {
            $content = $content -replace [regex]::Escape($pattern), $suggestion
            $fixes += @{
                Rule = "5.6"
                Type = "Common Text Pattern Fix"
                Description = "Changed $pattern to $suggestion"
            }
        }
    }
    
    # Rule 5.6: Fix more complex concatenation patterns
    # Pattern: ="Label: " & Value -> ="Label:" & " " & Value
    $complexPatterns = @(
        @{ Pattern = '="([^"]+):\s+"'; Replacement = '="$1:" & " "' },
        @{ Pattern = '=Concatenate\("([^"]+):\s+",'; Replacement = '=Concatenate("$1:", " ",'}
    )
    
    foreach ($patternObj in $complexPatterns) {
        $matches = [regex]::Matches($content, $patternObj.Pattern)
        foreach ($match in $matches) {
            $original = $match.Value
            $replacement = $match.Value -replace $patternObj.Pattern, $patternObj.Replacement
            $content = $content -replace [regex]::Escape($original), $replacement
            $fixes += @{
                Rule = "5.6"
                Type = "Complex Concatenation Fix"
                Description = "Fixed concatenation pattern: $original -> $replacement"
            }
        }
    }
    
    # Rule 5.6: Fix direct text with colon and content
    $directTextMatches = [regex]::Matches($content, 'Text:\s*="([^"]+):\s([^"]+)"')
    foreach ($match in $directTextMatches) {
        $fullMatch = $match.Value
        $label = $match.Groups[1].Value
        $value = $match.Groups[2].Value
        $replacement = "Text: =`"${label}:`" & `" `" & `"${value}`""
        $content = $content -replace [regex]::Escape($fullMatch), $replacement
        $fixes += @{
            Rule = "5.6"
            Type = "Direct Text Fix"
            Description = "Converted direct text '${label}: ${value}' to concatenation"
        }
    }
    
    # Rule 8.18: Fix Text() function with RGBA values
    $rgbaTextMatches = [regex]::Matches($content, 'Text\s*\(\s*RGBA\s*\([^)]+\)\s*\)')
    foreach ($match in $rgbaTextMatches) {
        $original = $match.Value
        # Extract RGBA parameters
        $rgbaMatch = [regex]::Match($original, 'RGBA\s*\(([^)]+)\)')
        if ($rgbaMatch.Success) {
            $rgbaParams = $rgbaMatch.Groups[1].Value
            $replacement = "`"RGBA($rgbaParams)`""
            $content = $content -replace [regex]::Escape($original), $replacement
            $fixes += @{
                Rule = "8.18"
                Type = "RGBA Text Function Fix"
                Description = "Replaced Text(RGBA(...)) with string literal"
            }
        }
    }
    
    # Rule 8.18: Fix Concatenate with Text(RGBA(...))
    $concatRgbaMatches = [regex]::Matches($content, 'Concatenate\s*\(([^,]+),\s*Text\s*\(\s*RGBA\s*\(([^)]+)\)\s*\)\s*\)')
    foreach ($match in $concatRgbaMatches) {
        $original = $match.Value
        $firstPart = $match.Groups[1].Value
        $rgbaParams = $match.Groups[2].Value
        $replacement = "Concatenate($firstPart, `"RGBA($rgbaParams)`")"
        $content = $content -replace [regex]::Escape($original), $replacement
        $fixes += @{
            Rule = "8.18"
            Type = "Concatenate RGBA Fix"
            Description = "Fixed Concatenate with Text(RGBA(...))"
        }
    }
    
    # Apply fixes if content changed
    if ($content -ne $originalContent -and -not $DryRun) {
        Set-Content -Path $FilePath -Value $content -Encoding UTF8
    }
    
    return $fixes
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
    $fixes = Fix-TextFormattingViolations -FilePath $file
    
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
                "Common Text Pattern Fix" { "Yellow" }
                "Complex Concatenation Fix" { "Cyan" }
                "Direct Text Fix" { "Green" }
                "RGBA Text Function Fix" { "Red" }
                "Concatenate RGBA Fix" { "Red" }
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
Write-Host "TEXT FORMATTING FIX SUMMARY" -ForegroundColor Green
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
        Write-Host "💡 Run Check-TextFormatting.ps1 to verify the fixes" -ForegroundColor Cyan
    }
} else {
    Write-Host ""
    Write-Host "✅ No text formatting violations found to fix!" -ForegroundColor Green
}

exit 0 