[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation
try {
    # TODO Add Localization:
    #   Import-VstsLocStrings "$PSScriptRoot\Task.json"

    # Get the inputs.
    [string]$SourceProvider = Get-VstsInput -Name SourceProvider
    [string]$SourcePath = Get-VstsInput -Name SourcePath
    [string]$SourceParameters = Get-VstsInput -Name SourceParameters
    [string]$DestinationProvider = Get-VstsInput -Name DestinationProvider
    [string]$DestinationPath = Get-VstsInput -Name DestinationPath
    [string]$DestinationParameters = Get-VstsInput -Name DestinationParameters
    [bool]$IncludeACLs = Get-VstsInput -Name IncludeACLs -AsBool
    [string]$DestinationComputer = Get-VstsInput -Name DestinationComputer
    [string]$Protocol = Get-VstsInput -Name Protocol
    [string]$AuthType = Get-VstsInput -Name AuthType
    [string]$Username = Get-VstsInput -Name Username
    [string]$Password = Get-VstsInput -Name Password
    [string]$SetParameters = Get-VstsInput -Name SetParameters
    [bool]$AllowUntrusted = Get-VstsInput -Name AllowUntrusted -AsBool
    [string]$AdditionalArguments = Get-VstsInput -Name AdditionalArguments
 
    #Assert-VstsPath -LiteralPath $source -PathType Container

    .\MSDeploySync.ps1 `
        -SourceProvider $SourceProvider -SourcePath $SourcePath -SourceParameters $SourceParameters `
        -DestinationProvider $DestinationProvider -DestinationPath $DestinationPath -DestinationParameters $DestinationParameters `
        -IncludeACLs $IncludeACLs -DestinationComputer $DestinationComputer `
        -Protocol $Protocol -AllowUntrusted $AllowUntrusted `
        -AuthType $AuthType -Username $Username -Password $Password `
        -SetParameters $SetParameters `
        -AdditionalArguments $AdditionalArguments

} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}