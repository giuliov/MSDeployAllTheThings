[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation
try {
    # TODO Add Localization:
    #   Import-VstsLocStrings "$PSScriptRoot\Task.json"

    # Get the inputs.
    [string]$SourceProvider = Get-VstsInput -Name SourceProvider
    [string]$SourcePath = Get-VstsInput -Name SourcePath
    [string]$DestinationProvider = Get-VstsInput -Name DestinationProvider
    [string]$DestinationPath = Get-VstsInput -Name DestinationPath
    [bool]$IncludeACLs = Get-VstsInput -Name IncludeACLs -AsBool
    [string]$DestinationComputer = Get-VstsInput -Name DestinationComputer
    [string]$AuthType = Get-VstsInput -Name AuthType
    [string]$Username = Get-VstsInput -Name Username
    [string]$Password = Get-VstsInput -Name Password
    [bool]$AllowUntrusted = Get-VstsInput -Name AllowUntrusted -AsBool
    [string]$AdditionalArguments = Get-VstsInput -Name AdditionalArguments
 
    #Assert-VstsPath -LiteralPath $source -PathType Container

    .\MSDeploySync.ps1 -SourceProvider $SourceProvider -SourcePath $SourcePath -DestinationProvider $DestinationProvider -DestinationPath $DestinationPath -IncludeACLs $IncludeACLs -DestinationComputer $DestinationComputer -AuthType $AuthType -Username $Username -Password $Password -AdditionalArguments $AdditionalArguments

} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}