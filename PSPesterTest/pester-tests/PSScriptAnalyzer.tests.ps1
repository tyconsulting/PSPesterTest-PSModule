[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)][validateScript({Test-Path $_})][string]$Path,
    [Parameter(Mandatory=$false)][switch]$recurse,
	[Parameter(Mandatory=$false)][validateScript({Test-Path $_ -PathType Container})][string]$CustomRulePath,
	[Parameter(Mandatory=$false)][validateSet('Information', 'Warning','Error')][string]$MinimumSeverityLevel = 'Error'
)
#Get native rules
$Rules = Get-ScriptAnalyzerRule
If ($CustomRulePath)
{
    Write-Verbose "Getting custom PSSA rules from '$CustomRulePath'"
    $Rules += Get-ScriptAnalyzerRule -CustomRulePath $CustomRulePath -RecurseCustomRulePath
}
Write-Verbose "Total Rule Count: $($Rules.count)"
#Get scripts to be tested
if ((Get-Item $path).PSIsContainer)
{
	Write-Verbose "Specified path '$path' is a directory"
	$scriptsModules = Get-ChildItem $Path -Include *.psd1, *.psm1, *.ps1 -Recurse
} else {
	Write-Verbose "Specified path '$path' is a file"
    $scriptsModules = Get-Item $path -Include *.psd1, *.psm1, *.ps1 
}
#work out the severities to be included

Switch ($MinimumSeverityLevel)
{
	'Information' {$Severities = @('Information', 'Warning', 'Error')}
	'Warning' {$Severities = @('Warning', 'Error')}
	'Error' {$Severities = @('Error')}
}
Write-Verbose "Total Script file count: $($scriptsModules.count)"
Describe "PowerShell Script Analyzer Test" {
    Context "Test Scripts Should Exist" {
		It "Test file count should be greater than 0" {
			$scriptsModules.count | Should Not Be 0
		}
	}
	Foreach ($scriptModule in $scriptsModules) {
		switch -Wildcard ($scriptModule) { 
			'*.psm1' { $ScriptType = 'Module' } 
			'*.ps1'  { $ScriptType = 'Script' } 
			'*.psd1' { $ScriptType = 'Manifest' } 
		}
		Write-Verbose "Test $ScriptType '$scriptModule' against to Script Analyzer Rules"
		Context "Test $ScriptType '$scriptModule' against to Script Analyzer Rules" {
			Foreach ($rule in $Rules) {
				Write-Verbose "Rule name: $rule"
				
				It "Should Pass Script Analyzer Rule '$rule'"{
					(Invoke-ScriptAnalyzer -Path $scriptModule -IncludeRule $rule -Severity $Severities -SaveDscDependency).count | Should Be 0
				}
			}
		}
	}
}