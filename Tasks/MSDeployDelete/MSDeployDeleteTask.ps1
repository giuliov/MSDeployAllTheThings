[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation
try {
    # TODO Add Localization:
    #   Import-VstsLocStrings "$PSScriptRoot\Task.json"

    # Get the inputs.
    [string]$DestinationProvider = Get-VstsInput -Name DestinationProvider
    [string]$DestinationPath = Get-VstsInput -Name DestinationPath
    [string]$DestinationComputer = Get-VstsInput -Name DestinationComputer
    [string]$AuthType = Get-VstsInput -Name AuthType
    [string]$Username = Get-VstsInput -Name Username
    [string]$Password = Get-VstsInput -Name Password
    [bool]$AllowUntrusted = Get-VstsInput -Name AllowUntrusted -AsBool
    [string]$AdditionalArguments = Get-VstsInput -Name AdditionalArguments
 
    #Assert-VstsPath -LiteralPath $source -PathType Container

    .\MSDeployDelete.ps1 `
        -DestinationProvider $DestinationProvider -DestinationPath $DestinationPath `
	    -DestinationComputer $DestinationComputer `
        -Protocol $Protocol `
        -AuthType $AuthType -Username $Username -Password $Password `
        -AdditionalArguments $AdditionalArguments

} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}