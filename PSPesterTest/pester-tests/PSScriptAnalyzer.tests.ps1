[CmdletBinding()]
Param (
  [Parameter(Mandatory = $true)][validateScript({ Test-Path $_ })][string]$Path,
  [Parameter(Mandatory = $false)][Boolean]$Recurse = $false,
  [Parameter(Mandatory = $false)][validateScript({ Test-Path $_ -PathType Container })][string]$CustomRulePath,
  [Parameter(Mandatory = $false)][validateSet('Information', 'Warning', 'Error')][string]$MinimumSeverityLevel = 'Error'
)
#Get native rules
$global:Rules = Get-ScriptAnalyzerRule
If ($CustomRulePath) {
  Write-Verbose "Getting custom PSSA rules from '$CustomRulePath'"
  $Rules += Get-ScriptAnalyzerRule -CustomRulePath $CustomRulePath -RecurseCustomRulePath
}
Write-Verbose "Total Rule Count: $($Rules.count)"
#Get scripts to be tested
if ((Get-Item $path).PSIsContainer) {
  Write-Verbose "Specified path '$path' is a directory"
  if ($Recurse -eq $true) {
    $global:scriptsModules = Get-ChildItem $Path -Include *.psd1, *.psm1, *.ps1 -Recurse
  } else {
    $global:scriptsModules = Get-ChildItem $Path -Include *.psd1, *.psm1, *.ps1 -Depth 0
  }
  
} else {
  Write-Verbose "Specified path '$path' is a file"
  $global:scriptsModules = Get-Item $path -Include *.psd1, *.psm1, *.ps1
}
#work out the severities to be included

Switch ($MinimumSeverityLevel) {
  'Information' { $global:Severities = @('Information', 'Warning', 'Error') }
  'Warning' { $global:Severities = @('Warning', 'Error') }
  'Error' { $global:Severities = @('Error') }
}
Write-Verbose "Total Script file count: $($scriptsModules.count)"
Describe "PowerShell Script Analyzer Test" {
  Context "Test Scripts Should Exist" {
    It "Test file count should be greater than 0" {
      $scriptsModules.count | Should -BeGreaterThan 0
    }
  }
  Foreach ($scriptModule in $global:scriptsModules) {
    switch -Wildcard ($scriptModule) {
      '*.psm1' { $ScriptType = 'Module' }
      '*.ps1' { $ScriptType = 'Script' }
      '*.psd1' { $ScriptType = 'Manifest' }
    }
    $global:scriptPath = $scriptModule.FullName
    Write-Verbose $global:scriptPath
    Write-Verbose "Test $ScriptType '$scriptModule' against Script Analyzer Rules"
    Context "Test $ScriptType '$($scriptModule.Name)' against to Script Analyzer Rules" {
      Foreach ($rule in $global:Rules) {
        Write-Verbose "Rule name: $rule"
        Write-Verbose "Script Path: $global:scriptPath"
        It "Should Pass Script Analyzer Rule '$rule'" {
          $result = Invoke-ScriptAnalyzer -Path "$global:scriptPath" -IncludeRule "$rule" -Severity $global:Severities
          $result.count | Should -Be 0
        }
      }
    }
  }
}