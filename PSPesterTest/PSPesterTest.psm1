# .EXTERNALHELP PSPesterTest.psm1-Help.xml
Function Test-ImportModule
{
	[CmdletBinding()]
	Param (
		[Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory=$true)]
		[Parameter(ParameterSetName = 'NoOutputFile', Mandatory=$true)]
		[validateScript({Test-Path $_})][string]$ModulePath,
		[Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory=$true)][ValidateNotNullOrEmpty()][string]$OutputFile,
		[Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory=$false)][ValidateSet('NUnitXml', 'LegacyNUnitXML')][string]$OutputFormat='NUnitXml'
	)

	$TestFilePath = Join-path $PSScriptRoot '\pester-tests\ImportModule.tests.ps1'
	Write-Verbose "Module Path: '$ModulePath'"
	
	If ($PSCmdlet.ParameterSetName -eq 'ProduceOutputFile')
	{
		$TestResult = Invoke-Pester -Script @{path= $TestFilePath; Parameters = @{ModulePath = $ModulePath}} -OutputFile $OutputFile -OutputFormat $OutputFormat -PassThru
		#Invoke-Pester -TestName $TestName -OutputFile $OutputFile -OutputFormat $OutputFormat
	} else {
		$TestResult = Invoke-Pester -Script @{path= $TestFilePath; Parameters = @{ModulePath = $ModulePath}} -PassThru
		#Invoke-Pester -TestName $TestName
	}
	If ($TestResult.TestResult.Result -ieq 'failed')
	{
		Write-Error "Test failed."
		#exit 1
	}
}

# .EXTERNALHELP PSPesterTest.psm1-Help.xml
Function Test-PSScriptAnalyzerRule
{
	[CmdletBinding()]
	Param (
		[Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory=$true)]
		[Parameter(ParameterSetName = 'NoOutputFile', Mandatory=$true)]
		[validateScript({Test-Path $_})][string]$Path,

		[Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory=$false)]
		[Parameter(ParameterSetName = 'NoOutputFile', Mandatory=$false)]
		[switch]$recurse,

		[Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory=$false)]
		[Parameter(ParameterSetName = 'NoOutputFile', Mandatory=$false)]
		[validateScript({Test-Path $_ -PathType Container})][string]$CustomRulePath,

		[Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory=$false)]
		[Parameter(ParameterSetName = 'NoOutputFile', Mandatory=$false)]
		[validateSet('Information', 'Warning','Error')][string]$MinimumSeverityLevel = 'Error',

		[Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory=$true)][ValidateNotNullOrEmpty()][string]$OutputFile,
		
		[Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory=$false)][ValidateSet('NUnitXml', 'LegacyNUnitXML')][string]$OutputFormat='NUnitXml'
	)

	$TestFilePath = Join-path $PSScriptRoot '\pester-tests\PSScriptAnalyzer.tests.ps1'
	Write-Verbose "Script Path: '$Path'"
	
	$PesterParameters = $PSBoundParameters
	[void]$PesterParameters.Remove('OutputFile')
	[void]$PesterParameters.Remove('OutputFormat')
	If ($PSCmdlet.ParameterSetName -eq 'ProduceOutputFile')
	{
		$TestResult = Invoke-Pester -Script @{path= $TestFilePath; Parameters = $PesterParameters} -OutputFile $OutputFile -OutputFormat $OutputFormat -PassThru
	} else {
		$TestResult = Invoke-Pester -Script @{path= $TestFilePath; Parameters = $PesterParameters} -PassThru
	}
	If ($TestResult.TestResult.Result -ieq 'failed')
	{
		Write-Error "Test failed."
		#exit 1
	}
}
