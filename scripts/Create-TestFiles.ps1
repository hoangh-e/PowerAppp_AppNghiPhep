# ====================================================================
# CREATE TEST FILES WITH VIOLATIONS
# Script: Create-TestFiles.ps1
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

# Test file 1: Control Rules violations
$controlRulesTest = @"
# Test file for Control Rules violations (Section 2)
Screens:
  TestScreen:
    Properties:
      Fill: =RGBA(248, 250, 252, 1)
    Children:
      # Rule 2.1: Version in Control declaration
      - BadVersionControl:
          Control: GroupContainer@1.3.0
          Properties:
            X: =Parent.X
            Y: =Parent.Y
            Width: =Parent.Width
            Height: =Parent.Height
      
      # Rule 2.2: Direct component reference
      - BadComponentControl:
          Control: HeaderComponent
          Properties:
            X: =Parent.X + 20
            Y: =Parent.Y + 10
            Width: =Parent.Width - 40
            Height: =60
      
      # Rule 2.3: Forbidden ZIndex property
      - BadZIndexControl:
          Control: Rectangle
          Properties:
            X: =Parent.X + 20
            Y: =Parent.Y + 80
            Width: =Parent.Width - 40
            Height: =100
            ZIndex: =5
            Fill: =RGBA(255, 255, 255, 1)
      
      # Rule 2.4: Button with forbidden properties
      - BadButtonControl:
          Control: Classic/Button
          Properties:
            X: =Parent.X + 20
            Y: =Parent.Y + 200
            Width: =Parent.Width / 4
            Height: =40
            BorderRadius: =8
            Disabled: =true
            Align: =Align.Center
            Text: ="Bad Button"
      
      # Rule 2.4: Rectangle with individual corner radius
      - BadRectangleControl:
          Control: Rectangle
          Properties:
            X: =Parent.X + 20
            Y: =Parent.Y + 260
            Width: =Parent.Width - 40
            Height: =80
            RadiusTopLeft: =8
            RadiusTopRight: =8
            RadiusBottomLeft: =8
            RadiusBottomRight: =8
            Fill: =RGBA(200, 200, 200, 1)
      
      # Rule 2.4: TextInput with forbidden properties
      - BadTextInputControl:
          Control: Classic/TextInput
          Properties:
            X: =Parent.X + 20
            Y: =Parent.Y + 360
            Width: =Parent.Width - 40
            Height: =32
            TextMode: =TextMode.SingleLine
            BorderColor: =If(Self.Focused, RGBA(0, 120, 212, 1), RGBA(200, 200, 200, 1))
      
      # Rule 2.5: Missing required properties
      - MissingPropsControl:
          Control: Label
          Properties:
            Text: ="Missing position properties"
"@

# Test file 2: Position & Size violations
$positionSizeTest = @"
# Test file for Position & Size violations (Section 3)
Screens:
  TestScreen:
    Properties:
      Fill: =RGBA(248, 250, 252, 1)
      # Rule 3.4: Screen should not have Width/Height
      Width: =1920
      Height: =1080
    Children:
      # Rule 3.1 & 3.2: Absolute positioning
      - AbsoluteControl:
          Control: Rectangle
          Properties:
            X: 100
            Y: 50
            Width: 300
            Height: 200
            Fill: =RGBA(255, 0, 0, 1)
      
      # Rule 3.3: Large fixed numbers in calculations
      - LargeFixedNumbersControl:
          Control: Label
          Properties:
            X: =Parent.X + 150
            Y: =Parent.Y + 75
            Width: =Parent.Width - 200
            Height: =Parent.Height / 2 - 100
            Text: ="Large fixed numbers"
      
      # Rule 3.3: Missing = prefix
      - MissingEqualsControl:
          Control: Classic/Button
          Properties:
            X: Parent.X + 20
            Y: Parent.Y + 300
            Width: Parent.Width / 4
            Height: 40
            Text: ="Missing equals"
      
      # Rule 3.1 & 3.2: Direct parent references (improvement needed)
      - DirectParentControl:
          Control: Image
          Properties:
            X: =Parent.X
            Y: =Parent.Y
            Width: =Parent.Width
            Height: =Parent.Height
"@

# Test file 3: Component Definitions violations
$componentTest = @"
# Test file for Component Definitions violations (Section 1.2)

# Rule 1.2: Wrong component structure (old format)
ComponentDefinition:
  DefinitionType: CanvasComponent
  CustomProperties:
    - UserRole:
        PropertyType: Data
        PropertyDataType: Text
        DefaultValue: ="Employee"
    - OnNavigate:
        PropertyType: Event
        PropertyDataType: Text
        DefaultValue: =""
  Properties:
    Height: =App.Height
    Width: =App.Width
  Children:
    - HeaderTitle:
        Control: Label
        Properties:
          X: =Parent.X + 20
          Y: =Parent.Y + 10
          Width: =Parent.Width - 40
          Height: =40
          Text: ="Header"
"@

# Test file 4: Icon Guidelines violations
$iconTest = @"
# Test file for Icon Guidelines violations (Section 6)
Screens:
  TestScreen:
    Properties:
      Fill: =RGBA(248, 250, 252, 1)
    Children:
      # Rule 6.1: Invalid icon references
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
      
      - BadIcon3:
          Control: Classic/Icon
          Properties:
            X: =Parent.X + 100
            Y: =Parent.Y + 20
            Width: =32
            Height: =32
            Icon: =Icon.MySpecialIcon
            Color: =RGBA(0, 0, 0, 1)
"@

# Test file 5: Text Formatting violations
$textFormattingTest = @"
# Test file for Text Formatting violations (Section 5.6)
Screens:
  TestScreen:
    Properties:
      Fill: =RGBA(248, 250, 252, 1)
    Children:
      # Rule 5.6: Wrong text concatenation formatting
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
            Text: ="Status: " & ThisItem.Status
      
      - BadTextFormat3:
          Control: Label
          Properties:
            X: =Parent.X + 20
            Y: =Parent.Y + 100
            Width: =Parent.Width - 40
            Height: =30
            Text: ="Demo: Phần lớn của ứng dụng"
      
      # Rule 8.18: Text function with RGBA values
      - BadRGBAText:
          Control: Label
          Properties:
            X: =Parent.X + 20
            Y: =Parent.Y + 140
            Width: =Parent.Width - 40
            Height: =30
            Text: =Concatenate("Color: ", Text(RGBA(255, 0, 0, 1)))
"@

# Write test files
$testFiles = @(
    @{ Name = "control_rules_violations.yaml"; Content = $controlRulesTest },
    @{ Name = "position_size_violations.yaml"; Content = $positionSizeTest },
    @{ Name = "component_violations.yaml"; Content = $componentTest },
    @{ Name = "icon_violations.yaml"; Content = $iconTest },
    @{ Name = "text_formatting_violations.yaml"; Content = $textFormattingTest }
)

foreach ($testFile in $testFiles) {
    $filePath = Join-Path $OutputPath $testFile.Name
    Set-Content -Path $filePath -Value $testFile.Content -Encoding UTF8
    Write-Host "Created: $($testFile.Name)" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ Created $($testFiles.Count) test files in '$OutputPath'" -ForegroundColor Green
Write-Host ""
Write-Host "Test files created:" -ForegroundColor Yellow
foreach ($testFile in $testFiles) {
    Write-Host "  - $($testFile.Name)" -ForegroundColor White
}

Write-Host ""
Write-Host "💡 Usage examples:" -ForegroundColor Cyan
Write-Host "  Test validation: .\scripts\Check-ControlRules.ps1 -SourcePath $OutputPath -Verbose" -ForegroundColor Gray
Write-Host "  Test fixes: .\scripts\Fix-ControlRules.ps1 -SourcePath $OutputPath -DryRun -Verbose" -ForegroundColor Gray
Write-Host "  Test all: .\scripts\Test-AllFixScripts.ps1 -SourcePath $OutputPath -RunFixes" -ForegroundColor Gray 