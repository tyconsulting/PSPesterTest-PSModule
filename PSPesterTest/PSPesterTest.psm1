# .EXTERNALHELP PSPesterTest.psm1-Help.xml
Function Test-ImportModule {
  [CmdletBinding()]
  Param (
    [Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory = $true)]
    [Parameter(ParameterSetName = 'NoOutputFile', Mandatory = $true)]
    [validateScript({ Test-Path $_ })][string]$ModulePath,
    [Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory = $true)][ValidateNotNullOrEmpty()][string]$OutputFile,
    [Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory = $false)][ValidateSet('NUnitXml', 'LegacyNUnitXML')][string]$OutputFormat = 'NUnitXml'
  )

  $TestFilePath = Join-path $PSScriptRoot '\pester-tests\ImportModule.tests.ps1'
  Write-Verbose "Module Path: '$ModulePath'"
  $container = New-PesterContainer -Path $TestFilePath -Data @{ModulePath = $ModulePath }
  $config = New-PesterConfiguration
  $config.Run.Container = $container
  $config.Run.PassThru = $true
  $config.Output.verbosity = 'Detailed'
  If ($PSCmdlet.ParameterSetName -eq 'ProduceOutputFile') {
    $config.TestResult.Enabled = $true
    $config.TestResult.OutputFormat = $OutputFormat
    $config.TestResult.OutputPath = $OutputFile
  }
  $TestResult = Invoke-Pester -Configuration $config
  If ($TestResult.TestResult.Result -ieq 'failed') {
    Write-Error "Test failed."
    #exit 1
  }
}

# .EXTERNALHELP PSPesterTest.psm1-Help.xml
Function Test-PSScriptAnalyzerRule {
  [CmdletBinding()]
  Param (
    [Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory = $true)]
    [Parameter(ParameterSetName = 'NoOutputFile', Mandatory = $true)]
    [validateScript({ Test-Path $_ })][string]$Path,

    [Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory = $false)]
    [Parameter(ParameterSetName = 'NoOutputFile', Mandatory = $false)]
    [Boolean]$recurse = $false,

    [Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory = $false)]
    [Parameter(ParameterSetName = 'NoOutputFile', Mandatory = $false)]
    [validateScript({ Test-Path $_ -PathType Container })][string]$CustomRulePath,

    [Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory = $false)]
    [Parameter(ParameterSetName = 'NoOutputFile', Mandatory = $false)]
    [validateSet('Information', 'Warning', 'Error')][string]$MinimumSeverityLevel = 'Error',

    [Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory = $true)][ValidateNotNullOrEmpty()][string]$OutputFile,

    [Parameter(ParameterSetName = 'ProduceOutputFile', Mandatory = $false)][ValidateSet('NUnitXml', 'LegacyNUnitXML')][string]$OutputFormat = 'NUnitXml'
  )

  $TestFilePath = Join-path $PSScriptRoot '\pester-tests\PSScriptAnalyzer.tests.ps1'
  Write-Verbose "Script Path: '$Path'"
  $container = New-PesterContainer -Path $TestFilePath -Data @{Path = $path; MinimumSeverityLevel = $MinimumSeverityLevel; Recurse = $recurse }
  $config = New-PesterConfiguration
  $config.Run.Container = $container
  $config.Run.PassThru = $true
  $config.Output.verbosity = 'Detailed'
  If ($PSCmdlet.ParameterSetName -eq 'ProduceOutputFile') {
    $config.TestResult.Enabled = $true
    $config.TestResult.OutputFormat = $OutputFormat
    $config.TestResult.OutputPath = $OutputFile
  }
  $TestResult = Invoke-Pester -Configuration $config

  If ($TestResult.TestResult.Result -ieq 'failed') {
    Write-Error "Test failed."
    #exit 1
  }
}
