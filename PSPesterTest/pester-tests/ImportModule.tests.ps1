[CmdletBinding()]
Param (
	[Parameter(Mandatory=$true)][validateScript({Test-Path $_})][string]$ModulePath
)
Write-Verbose "Module Path: '$ModulePath'"
$TestName = "PowerShell Module Import Test"

Describe $TestName {

	It 'Module Path should exist' {
		Test-Path $ModulePath -ErrorAction SilentlyContinue | should Be $true
	}
	
	It 'Should be imported successfully' {
		Import-Module -Name $ModulePath -ErrorVariable ImportError
		$ImportError | Should Be $Null
	}
}
	