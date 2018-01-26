[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $DestinationProvider,
    [String] [Parameter(Mandatory = $false)]
    $DestinationPath,
    [String] [Parameter(Mandatory = $false)]
    $DestinationComputer,
    
    [String] [Parameter(Mandatory = $false)]
    $AuthType,
    [String] [Parameter(Mandatory = $false)]
    $Username,
    [String] [Parameter(Mandatory = $false)]
    $Password,

    [bool]  [Parameter(Mandatory = $false)]
    $AllowUntrusted,
    [String] [Parameter(Mandatory = $false)]
    $AdditionalArguments
)

Write-Warning "Not implemented yet!"