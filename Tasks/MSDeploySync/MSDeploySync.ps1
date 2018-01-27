[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $false)]
    $SourceProvider,
    [String] [Parameter(Mandatory = $true)]
    $SourcePath,
    [String] [Parameter(Mandatory = $true)]
    $DestinationProvider,
    [String] [Parameter(Mandatory = $false)]
    $DestinationPath,
    [String] [Parameter(Mandatory = $false)]
    $DestinationComputer,
    [String] [Parameter(Mandatory = $false)]
    $Protocol,
    [bool] [Parameter(Mandatory = $false)]
    $IncludeACLs,    
    
    [String] [Parameter(Mandatory = $false)]
    $AuthType,
    [String] [Parameter(Mandatory = $false)]
    $Username,
    [String] [Parameter(Mandatory = $false)]
    $Password,
    [bool]$AllowUntrusted,

    [String] [Parameter(Mandatory = $false)]
    $AdditionalArguments

)

Import-Module $PSScriptRoot\ps_modules\VstsTaskSdk\VstsTaskSdk.psd1 -ArgumentList @{ NonInteractive = $true } -Verbose:$false

function Get-SingleFile($files, $pattern)
{
    if ($files -is [system.array])
    {
        throw (Get-LocalizedString -Key "Found more than one file to deploy with search pattern {0}. There can be only one." -ArgumentList $pattern)
    }
    else
    {
        if (!$files)
        {
            throw (Get-LocalizedString -Key "No files were found to deploy with search pattern {0}" -ArgumentList $pattern)
        }
        return $files
    }
}

Write-Verbose "Entering script MSDeployPackageSync.ps1"

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

# $publishUrl ="https://$Name.scm.azurewebsites.net:443/msdeploy.axd?site-name=$Name"
# $webApp ="$Name\$App"

if (-not $DestinationComputer -or $AuthType -eq 'none' -or -not $AuthType) {
    Write-Host "No destination or authType defined, performing local operation"
    $remoteArguments = ""
} else {

    $URL = switch ($Protocol) {
        "MsDepSvc" { "https://${DestinationComputer}/MSDeployAgentService" }
        "WMSvc" { "https://${DestinationComputer}:8172/MSDeploy.axd" }
        "custom" { $DestinationComputer }
        Default {  $DestinationComputer }
    }
    
    $remoteArguments = "computerName='${URL}',userName='${UserName}',password='${Password}',authType='${AuthType}',"
}

if (-not $SourceProvider -or $SourceProvider -eq "package") {
    Write-Host "packageFile= Find-VstsFiles -Pattern ${SourcePath}"
    $packageFile = Find-VstsFiles -LegacyPattern $SourcePath
    Write-Host "packageFile= ${packageFile}"
    
    #Ensure that at most a single package (.zip) file is found
    $packageFile = Get-SingleFile $packageFile $SourcePath
    
    Write-Host "No source provider specified, using package provider for '${packageFile}'"
    $SourceProvider = "package='${packageFile}'"
} else {
    $SourceProvider = "${SourceProvider}='${SourcePath}'"
}

if ($DestinationPath) {
    $DestinationProvider = "${DestinationProvider}='${DestinationPath}'"
}

Write-Host "Deploying $SourceProvider to $DestinationComputer"

[string[]] $arguments = 
 "-verb:sync",
 "-source:${SourceProvider}",
 "-dest:${DestinationProvider},${remoteArguments}includeAcls='${IncludeACLs}'"
#,"-setParam:name='IIS", "Web", "Application", ("Name',value='" + $webApp + "'")

if ($AllowUntrusted) {
    $arguments += "-allowUntrusted"
}

Invoke-VstsTool -FileName $msdeploy -Arguments "$arguments $AdditionalArguments" -RequireExitCodeZero