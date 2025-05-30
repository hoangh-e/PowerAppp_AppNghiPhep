# ====================================================================
# CREATE TEST FILES WITH VIOLATIONS (SIMPLE VERSION)
# Script: Create-TestFiles-Simple.ps1
# Purpose: Create test YAML files with known violations to test validation and fix scripts
# Date: 2024-12-19
# ====================================================================

param(
    [string]$OutputPath = "test_files",
    [switch]$CleanFirst
)

Write-Host "📝 CREATING TEST FILES WITH VIOLATIONS" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Clean output directory if requested
if ($CleanFirst -and (Test-Path $OutputPath)) {
    Write-Host "Cleaning existing test files..." -ForegroundColor Yellow
    Remove-Item -Path $OutputPath -Recurse -Force
}

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
}

# Create test files directly
Write-Host "Creating control_rules_violations.yaml..." -ForegroundColor Green
$controlRulesContent = @'
# Test file for Control Rules violations (Section 2)
Screens:
  TestScreen:
    Properties:
      Fill: =RGBA(248, 250, 252, 1)
    Children:
      - BadVersionControl:
          Control: GroupContainer@1.3.0
          Properties:
            X: =Parent.X
            Y: =Parent.Y
            Width: =Parent.Width
            Height: =Parent.Height
      
      - BadComponentControl:
          Control: HeaderComponent
          Properties:
            X: =Parent.X + 20
            Y: =Parent.Y + 10
            Width: =Parent.Width - 40
            Height: =60
      
      - BadZIndexControl:
          Control: Rectangle
          Properties:
            X: =Parent.X + 20
            Y: =Parent.Y + 80
            Width: =Parent.Width - 40
            Height: =100
            ZIndex: =5
            Fill: =RGBA(255, 255, 255, 1)
'@

Set-Content -Path (Join-Path $OutputPath "control_rules_violations.yaml") -Value $controlRulesContent -Encoding UTF8

Write-Host "Creating position_size_violations.yaml..." -ForegroundColor Green
$positionSizeContent = @'
# Test file for Position & Size violations (Section 3)
Screens:
  TestScreen:
    Properties:
      Fill: =RGBA(248, 250, 252, 1)
      Width: =1920
      Height: =1080
    Children:
      - AbsoluteControl:
          Control: Rectangle
          Properties:
            X: 100
            Y: 50
            Width: 300
            Height: 200
            Fill: =RGBA(255, 0, 0, 1)
      
      - LargeFixedNumbersControl:
          Control: Label
          Properties:
            X: =Parent.X + 150
            Y: =Parent.Y + 75
            Width: =Parent.Width - 200
            Height: =Parent.Height / 2 - 100
            Text: ="Large fixed numbers"
'@

Set-Content -Path (Join-Path $OutputPath "position_size_violations.yaml") -Value $positionSizeContent -Encoding UTF8

Write-Host "Creating component_violations.yaml..." -ForegroundColor Green
$componentContent = @'
# Test file for Component Definitions violations (Section 1.2)
ComponentDefinition:
  DefinitionType: CanvasComponent
  CustomProperties:
    - UserRole:
        PropertyType: Data
        PropertyDataType: Text
        DefaultValue: ="Employee"
  Properties:
    Height: =App.Height
    Width: =App.Width
'@

Set-Content -Path (Join-Path $OutputPath "component_violations.yaml") -Value $componentContent -Encoding UTF8

Write-Host "Creating icon_violations.yaml..." -ForegroundColor Green
$iconContent = @'
# Test file for Icon Guidelines violations (Section 6)
Screens:
  TestScreen:
    Properties:
      Fill: =RGBA(248, 250, 252, 1)
    Children:
      - BadIcon1:
          Control: Classic/Icon
          Properties:
            X: =Parent.X + 20
            Y: =Parent.Y + 20
            Width: =32
            Height: =32
            Icon: =Icon.Calendar
            Color: =RGBA(0, 0, 0, 1)
      
      - BadIcon2:
          Control: Classic/Icon
          Properties:
            X: =Parent.X + 60
            Y: =Parent.Y + 20
            Width: =32
            Height: =32
            Icon: =Icon.CustomIcon
            Color: =RGBA(0, 0, 0, 1)
'@

Set-Content -Path (Join-Path $OutputPath "icon_violations.yaml") -Value $iconContent -Encoding UTF8

Write-Host "Creating text_formatting_violations.yaml..." -ForegroundColor Green
$textContent = @'
# Test file for Text Formatting violations (Section 5.6)
Screens:
  TestScreen:
    Properties:
      Fill: =RGBA(248, 250, 252, 1)
    Children:
      - BadTextFormat1:
          Control: Label
          Properties:
            X: =Parent.X + 20
            Y: =Parent.Y + 20
            Width: =Parent.Width - 40
            Height: =30
            Text: ="Email: " & ThisItem.Email
      
      - BadTextFormat2:
          Control: Label
          Properties:
            X: =Parent.X + 20
            Y: =Parent.Y + 60
            Width: =Parent.Width - 40
            Height: =30
            Text: ="Demo: Phần lớn của ứng dụng"
      
      - BadRGBAText:
          Control: Label
          Properties:
            X: =Parent.X + 20
            Y: =Parent.Y + 100
            Width: =Parent.Width - 40
            Height: =30
            Text: =Concatenate("Color: ", Text(RGBA(255, 0, 0, 1)))
'@

Set-Content -Path (Join-Path $OutputPath "text_formatting_violations.yaml") -Value $textContent -Encoding UTF8

Write-Host ""
Write-Host "✅ Created 5 test files in '$OutputPath'" -ForegroundColor Green
Write-Host ""
Write-Host "Test files created:" -ForegroundColor Yellow
Write-Host "  - control_rules_violations.yaml" -ForegroundColor White
Write-Host "  - position_size_violations.yaml" -ForegroundColor White
Write-Host "  - component_violations.yaml" -ForegroundColor White
Write-Host "  - icon_violations.yaml" -ForegroundColor White
Write-Host "  - text_formatting_violations.yaml" -ForegroundColor White

Write-Host ""
Write-Host "💡 Usage examples:" -ForegroundColor Cyan
Write-Host "  Test validation: .\scripts\Check-ControlRules.ps1 -SourcePath $OutputPath -Verbose" -ForegroundColor Gray
Write-Host "  Test fixes: .\scripts\Fix-ControlRules.ps1 -SourcePath $OutputPath -DryRun -Verbose" -ForegroundColor Gray
Write-Host "  Test all: .\scripts\Test-AllFixScripts.ps1 -SourcePath $OutputPath -RunFixes" -ForegroundColor Gray 