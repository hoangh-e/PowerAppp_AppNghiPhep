param([string]$FilePath)

if (-not $FilePath) {
    Write-Host "Usage: .\Show-Changes.ps1 -FilePath <path>"
    exit 1
}

Write-Host "Changes made to: $FilePath" -ForegroundColor Green
Write-Host ""

if (Test-Path $FilePath) {
    $content = Get-Content $FilePath
    $lineNumber = 1
    
    foreach ($line in $content) {
        $changed = $false
        $changeType = ""
        
        # Detect icon changes
        if ($line -match "Icon.*CalendarBlank") {
            $changed = $true
            $changeType = "ICON FIX"
        }
        
        if ($line -match "Icon.*QuestionMark") {
            $changed = $true  
            $changeType = "ICON FIX"
        }
        
        # Detect text changes
        if ($line -match 'Text.*:".*&.*".*"') {
            $changed = $true
            $changeType = "TEXT FIX"
        }
        
        if ($changed) {
            Write-Host "Line $lineNumber ($changeType): $line" -ForegroundColor Yellow
        }
        
        $lineNumber++
    }
} else {
    Write-Host "File not found: $FilePath" -ForegroundColor Red
}

Write-Host ""
Write-Host "Analysis completed!" -ForegroundColor Green 