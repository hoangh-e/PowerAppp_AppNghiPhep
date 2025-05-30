# Check for Excessive Fixed Numbers in Power App YAML Files
# This script identifies potential issues with fixed number usage in positioning/sizing

Write-Host "🔍 Checking for Fixed Number Usage in Power App Files..." -ForegroundColor Green

$srcPath = "src"
$issuesFound = 0
$filesChecked = 0

# Get all YAML files in src directory
$yamlFiles = Get-ChildItem -Path $srcPath -Recurse -Filter "*.yaml" | Where-Object { $_.Name -notlike "*copy*" }

Write-Host "📁 Found $($yamlFiles.Count) YAML files to check" -ForegroundColor Yellow

# Define patterns for positioning/sizing properties with fixed numbers
$positioningProperties = @("X", "Y", "Width", "Height", "Size", "FontSize", "BorderThickness")
$largeNumberPattern = "=.*[+\-]\s*([2-9][0-9]|[1-9][0-9]{2,})"  # Numbers >= 20
$mediumNumberPattern = "=.*[+\-]\s*(1[0-9])"                      # Numbers 10-19
$smallNumberPattern = "=.*[+\-]\s*([1-9])"                        # Numbers 1-9

foreach ($file in $yamlFiles) {
    Write-Host "`n🔍 Checking: $($file.Name)" -ForegroundColor Cyan
    $content = Get-Content $file.FullName
    $fileIssues = 0
    $filesChecked++
    
    for ($i = 0; $i -lt $content.Length; $i++) {
        $line = $content[$i]
        $lineNumber = $i + 1
        
        # Check each positioning property
        foreach ($prop in $positioningProperties) {
            if ($line -match "^\s*$prop\s*:") {
                # Check for large fixed numbers (>= 20) - HIGH PRIORITY
                if ($line -match $largeNumberPattern) {
                    $matches = [regex]::Matches($line, "[+\-]\s*([2-9][0-9]|[1-9][0-9]{2,})")
                    foreach ($match in $matches) {
                        $number = $match.Groups[1].Value
                        Write-Host "  🚨 HIGH: Line $lineNumber - $prop uses large fixed number: $number" -ForegroundColor Red
                        Write-Host "    $line" -ForegroundColor Gray
                        $fileIssues++
                        $issuesFound++
                    }
                }
                # Check for medium fixed numbers (10-19) - MEDIUM PRIORITY
                elseif ($line -match $mediumNumberPattern) {
                    $matches = [regex]::Matches($line, "[+\-]\s*(1[0-9])")
                    foreach ($match in $matches) {
                        $number = $match.Groups[1].Value
                        Write-Host "  ⚠️  MEDIUM: Line $lineNumber - $prop uses medium fixed number: $number" -ForegroundColor Yellow
                        Write-Host "    $line" -ForegroundColor Gray
                        $fileIssues++
                        $issuesFound++
                    }
                }
                # Check for small fixed numbers (1-9) - LOW PRIORITY (just info)
                elseif ($line -match $smallNumberPattern -and $prop -ne "Size" -and $prop -ne "FontSize" -and $prop -ne "BorderThickness") {
                    $matches = [regex]::Matches($line, "[+\-]\s*([1-9])")
                    foreach ($match in $matches) {
                        $number = $match.Groups[1].Value
                        Write-Host "  ℹ️  INFO: Line $lineNumber - $prop uses small fixed number: $number (consider relative)" -ForegroundColor Blue
                        Write-Host "    $line" -ForegroundColor Gray
                    }
                }
                
                # Check for pure fixed values (no = sign or just =number)
                if ($line -match "^\s*$prop\s*:\s*[0-9]+\s*$" -or $line -match "^\s*$prop\s*:\s*=[0-9]+\s*$") {
                    Write-Host "  🚨 CRITICAL: Line $lineNumber - $prop uses pure fixed value (should be relative)" -ForegroundColor Magenta
                    Write-Host "    $line" -ForegroundColor Gray
                    $fileIssues++
                    $issuesFound++
                }
            }
        }
    }
    
    if ($fileIssues -eq 0) {
        Write-Host "  ✅ No fixed number issues found" -ForegroundColor Green
    } else {
        Write-Host "  📊 Found $fileIssues potential issues" -ForegroundColor Yellow
    }
}

Write-Host "`n📊 FIXED NUMBER USAGE SUMMARY" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "Files checked: $filesChecked" -ForegroundColor White
Write-Host "Total issues found: $issuesFound" -ForegroundColor White

if ($issuesFound -eq 0) {
    Write-Host "`n🎉 Excellent! No significant fixed number issues found." -ForegroundColor Green
    Write-Host "Your Power App uses good relative positioning practices!" -ForegroundColor Green
} else {
    Write-Host "`n💡 RECOMMENDATIONS:" -ForegroundColor Yellow
    Write-Host "🔴 HIGH Priority: Replace large fixed numbers (>=20) with relative calculations" -ForegroundColor Red
    Write-Host "🟡 MEDIUM Priority: Consider replacing medium fixed numbers (10-19) with relative calculations" -ForegroundColor Yellow
    Write-Host "🔵 INFO: Small fixed numbers (1-9) are acceptable but consider relative alternatives" -ForegroundColor Blue
    
    Write-Host "`n✅ PREFERRED ALTERNATIVES:" -ForegroundColor Green
    Write-Host "Instead of: Width: =Parent.Width - 50" -ForegroundColor Gray
    Write-Host "Use:        Width: =Parent.Width * 0.9" -ForegroundColor Green
    Write-Host "Instead of: X: =Parent.X + 30" -ForegroundColor Gray
    Write-Host "Use:        X: =Parent.X + Parent.Width * 0.05" -ForegroundColor Green
    Write-Host "Instead of: Y: =Control1.Y + 20" -ForegroundColor Gray
    Write-Host "Use:        Y: =Control1.Y + Control1.Height / 2" -ForegroundColor Green
}

Write-Host "`n🎯 For better responsive design, minimize fixed numbers in favor of relative calculations!" -ForegroundColor Cyan 