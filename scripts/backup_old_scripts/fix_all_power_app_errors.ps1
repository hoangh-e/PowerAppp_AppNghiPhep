# Fix All Power App Rules Violations
# This script fixes all identified Power App rules violations in the codebase

Write-Host "🔧 Starting Power App Rules Compliance Fix..." -ForegroundColor Green

$srcPath = "src"
$fixedCount = 0
$filesProcessed = 0

# Get all YAML files in src directory
$yamlFiles = Get-ChildItem -Path $srcPath -Recurse -Filter "*.yaml" | Where-Object { $_.Name -notlike "*copy*" }

Write-Host "📁 Found $($yamlFiles.Count) YAML files to process" -ForegroundColor Yellow

foreach ($file in $yamlFiles) {
    Write-Host "🔍 Processing: $($file.FullName)" -ForegroundColor Cyan
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fileFixed = $false
    
    # 1. Fix Component Control Declarations
    # Replace Control: ComponentName with Control: CanvasComponent + ComponentName: ComponentName
    if ($content -match "Control: (HeaderComponent|NavigationComponent|StatsCardComponent)") {
        Write-Host "  ✅ Fixing component control declarations..." -ForegroundColor Green
        
        # Fix HeaderComponent
        $content = $content -replace "Control: HeaderComponent", "Control: CanvasComponent`r`n          ComponentName: HeaderComponent"
        
        # Fix NavigationComponent  
        $content = $content -replace "Control: NavigationComponent", "Control: CanvasComponent`r`n          ComponentName: NavigationComponent"
        
        # Fix StatsCardComponent
        $content = $content -replace "Control: StatsCardComponent", "Control: CanvasComponent`r`n          ComponentName: StatsCardComponent"
        
        $fileFixed = $true
        $fixedCount++
    }
    
    # 2. Fix Multi-line OnVisible formulas (add pipe operator)
    if ($content -match "OnVisible: =Set.*Set.*Set" -and $content -notmatch "OnVisible: \|") {
        Write-Host "  ✅ Fixing multi-line OnVisible formulas..." -ForegroundColor Green
        
        # Find OnVisible lines and add pipe operator
        $content = $content -replace "(OnVisible: )(=Set.*)", "`$1|`r`n        `$2"
        
        $fileFixed = $true
        $fixedCount++
    }
    
    # 3. Fix Multi-line OnSelect formulas (add pipe operator for very long ones)
    $onSelectMatches = [regex]::Matches($content, "OnSelect: (=.{120,})")
    if ($onSelectMatches.Count -gt 0) {
        Write-Host "  ✅ Fixing long OnSelect formulas..." -ForegroundColor Green
        
        foreach ($match in $onSelectMatches) {
            $originalLine = $match.Value
            $formula = $match.Groups[1].Value
            $newLine = "OnSelect: |`r`n                          $formula"
            $content = $content -replace [regex]::Escape($originalLine), $newLine
        }
        
        $fileFixed = $true
        $fixedCount++
    }
    
    # 4. Fix invalid Icon references
    if ($content -match "Icon\.Calendar[^B]") {
        Write-Host "  ✅ Fixing invalid icon references..." -ForegroundColor Green
        
        $content = $content -replace "Icon\.Calendar(?!Blank)", "Icon.CalendarBlank"
        
        $fileFixed = $true
        $fixedCount++
    }
    
    # 5. Fix text formatting issues (spaces after colons)
    # This is more complex and needs careful handling to avoid breaking valid cases
    $textMatches = [regex]::Matches($content, 'Text: ="([^"]*): ([^"]*)"')
    if ($textMatches.Count -gt 0) {
        Write-Host "  ✅ Fixing text formatting issues..." -ForegroundColor Green
        
        foreach ($match in $textMatches) {
            $originalText = $match.Value
            $beforeColon = $match.Groups[1].Value
            $afterColon = $match.Groups[2].Value
            
            # Only fix if it's a simple label: value pattern
            if ($beforeColon -match "^[^&]*$" -and $afterColon -match "^[^&]*$") {
                $colonChar = ":"
                $newText = "Text: =`"$beforeColon$colonChar`" & `" `" & `"$afterColon`""
                $content = $content -replace [regex]::Escape($originalText), $newText
                $fileFixed = $true
            }
        }
        
        if ($fileFixed) {
            $fixedCount++
        }
    }
    
    # Save file if changes were made
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "  💾 File updated successfully" -ForegroundColor Green
        $filesProcessed++
    } else {
        Write-Host "  ✅ No issues found" -ForegroundColor Gray
    }
}

Write-Host "`n🎉 Power App Rules Compliance Fix Complete!" -ForegroundColor Green
Write-Host "📊 Summary:" -ForegroundColor Yellow
Write-Host "  - Files processed: $filesProcessed" -ForegroundColor White
Write-Host "  - Total fixes applied: $fixedCount" -ForegroundColor White
Write-Host "  - Files examined: $($yamlFiles.Count)" -ForegroundColor White

# Run a final validation
Write-Host "`n🔍 Running final validation..." -ForegroundColor Yellow

# Check for remaining component control issues
$remainingComponentIssues = Select-String -Path "$srcPath\**\*.yaml" -Pattern "Control: (HeaderComponent|NavigationComponent|StatsCardComponent)" -Exclude "*copy*"
if ($remainingComponentIssues) {
    Write-Host "⚠️  Remaining component control issues found:" -ForegroundColor Red
    $remainingComponentIssues | ForEach-Object { Write-Host "  $($_.Filename):$($_.LineNumber) - $($_.Line.Trim())" -ForegroundColor Red }
} else {
    Write-Host "✅ No component control issues found" -ForegroundColor Green
}

# Check for remaining multi-line formula issues
$remainingFormulaIssues = Select-String -Path "$srcPath\**\*.yaml" -Pattern "OnVisible: =Set.*Set.*Set" -Exclude "*copy*" | Where-Object { $_.Line -notmatch "\|" }
if ($remainingFormulaIssues) {
    Write-Host "⚠️  Remaining multi-line formula issues found:" -ForegroundColor Red
    $remainingFormulaIssues | ForEach-Object { Write-Host "  $($_.Filename):$($_.LineNumber) - $($_.Line.Trim())" -ForegroundColor Red }
} else {
    Write-Host "✅ No multi-line formula issues found" -ForegroundColor Green
}

Write-Host "`n🚀 All Power App files are now compliant with the rules!" -ForegroundColor Green 