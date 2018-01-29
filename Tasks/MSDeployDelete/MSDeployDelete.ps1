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
    $Protocol,
    
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

Import-Module $PSScriptRoot\ps_modules\VstsTaskSdk\VstsTaskSdk.psd1 -ArgumentList @{ NonInteractive = $true } -Verbose:$false
$MSDeployKey = 'HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy\3' 
 if(!(Test-Path $MSDeployKey)) { 
 throw "Could not find MSDeploy. Use Web Platform Installer to install the 'Web Deployment Tool' and re-run this command" 
 } 

$InstallPath = (Get-ItemProperty $MSDeployKey).InstallPath 
 if(!$InstallPath -or !(Test-Path $InstallPath)) { 
 throw "Could not find MSDeploy. Use Web Platform Installer to install the 'Web Deployment Tool' and re-run this command" 
 } 

$msdeploy = Join-Path $InstallPath "msdeploy.exe" 
 if(!(Test-Path $MSDeploy)) { 
 throw "Could not find MSDeploy. Use Web Platform Installer to install the 'Web Deployment Tool' and re-run this command" 
 } 

if (-not $DestinationComputer -or $AuthType -eq 'none' -or -not $AuthType) {
    Write-Host "No destination or authType defined, performing local operation"
    $remoteArguments = ""
} else {

    $URL = switch ($Protocol) {
        "MsDepSvc" { "https://${DestinationComputer}/MSDeployAgentService" }
        "WMSvc" { "https://${DestinationComputer}:8172/MSDeploy.axd" }
        "AzureWebSite" { "https://${DestinationComputer}.scm.azurewebsites.net:443/msdeploy.axd?site=${DestinationComputer}" }
        "custom" { $DestinationComputer }
        Default {  $DestinationComputer }
    }
    
    $remoteArguments = "computerName='${URL}',userName='${UserName}',password='${Password}',authType='${AuthType}',"
}

if ($DestinationPath) {
    $DestinationProvider = "${DestinationProvider}='${DestinationPath}'"
}

[string[]] $arguments = 
 "-verb:delete",
 "-dest:${DestinationProvider},${remoteArguments}"

if ($AllowUntrusted) {
    $arguments += "-allowUntrusted"
}

Invoke-VstsTool -FileName $msdeploy -Arguments "${arguments} ${AdditionalArguments}" -RequireExitCodeZero