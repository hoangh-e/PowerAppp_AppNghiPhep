# ====================================================================
# POWER APP RULES VALIDATION ENGINE
# Purpose: Core framework for all Power App YAML validation
# Rules Reference: Complete .cursorrules implementation
# Author: AI Assistant (Rules-Based Framework)
# Date: 2024-12-19
# Version: 2.0.0 (Clean Slate)
# ====================================================================

param(
    [string]$SourcePath = "src",
    [string[]]$RuleSections = @(),
    [switch]$FixIssues,
    [switch]$Verbose,
    [switch]$GenerateReport
)

# Core validation framework
class PowerAppRule {
    [string]$Section
    [string]$Title
    [string]$Severity
    [scriptblock]$ValidationLogic
    [scriptblock]$FixLogic
    
    PowerAppRule([string]$section, [string]$title, [string]$severity, [scriptblock]$validation, [scriptblock]$fix) {
        $this.Section = $section
        $this.Title = $title
        $this.Severity = $severity
        $this.ValidationLogic = $validation
        $this.FixLogic = $fix
    }
}

class ValidationResult {
    [string]$File
    [string]$Rule
    [int]$Line
    [string]$Message
    [string]$Severity
    [string]$Content
    [string]$Suggestion
}

# YAML parsing utility
function Get-YamlStructure {
    param([string]$FilePath)
    
    try {
        # Simple YAML structure parser for Power Apps
        $content = Get-Content $FilePath -Raw
        $lines = Get-Content $FilePath
        
        $structure = @{
            Type = ""
            Content = $content
            Lines = $lines
            Controls = @()
            Properties = @{}
        }
        
        # Detect file type
        if ($content -match "^Screens:") {
            $structure.Type = "Screen"
        } elseif ($content -match "^ComponentDefinitions:") {
            $structure.Type = "Component"
        }
        
        return $structure
    }
    catch {
        Write-Warning "Failed to parse YAML: $($_.Exception.Message)"
        return $null
    }
}

# Core validation executor
function Invoke-RuleValidation {
    param(
        [string]$FilePath,
        [PowerAppRule[]]$Rules
    )
    
    $results = @()
    $yamlStructure = Get-YamlStructure -FilePath $FilePath
    
    if (-not $yamlStructure) {
        return $results
    }
    
    foreach ($rule in $Rules) {
        try {
            $ruleResults = & $rule.ValidationLogic $yamlStructure $FilePath
            if ($ruleResults) {
                $results += $ruleResults
            }
        }
        catch {
            Write-Warning "Rule $($rule.Section) failed: $($_.Exception.Message)"
        }
    }
    
    return $results
}

# Export framework functions
Export-ModuleMember -Function Get-YamlStructure, Invoke-RuleValidation 