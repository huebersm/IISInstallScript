param (

    [string]$siteName = "Survey",

    [string]$sitePort = 8100,

    [string]$appName = "Survey.Web",
    [string]$appPoolName = $siteName
)
    

import-module WebAdministration



function CopyAppFiles() {
   # $appPath = $env:ChocolateyInstall + "\lib\" + $env:ChocolateyPackageName + "\app\*"
  
    $appPath = $PSScriptRoot + "/app/*"
    write-host "Copying App now into IIS-App from "  $appPath " into " $appDir 
    copy-item $appPath -destination $appDir -recurse -force
}

$siteDir = "$env:systemdrive\inetpub\$siteName"
$appDir = $siteDir + "\" + $appName



$webAppExists = Get-WebApplication -name $appName
if($webAppExists) { #Just Update
    Write-Host "App already exists, just updating app: " $appName " in site: " + $siteName

    CopyAppFiles
} else {

    if(![System.IO.Directory]::Exists($siteDir)){
        Write-Host $siteDir  " does not exist, creating that dir now"
        mkdir $siteDir
    } else {
        Write-Host "The Dir: " $siteDir " already exists, skip creation of dir for now"
    }

    $appPoolExists = Get-IISAppPool -Name $appPoolName
    if(!$appPoolExists)
    {
        Write-Host "Creating IIS-AppPool with Name: "  $siteName
        new-webapppool -name $siteName -Force
    } else {
        Write-Host "IIS-AppPool with Name: "  $siteName " already exists"
    }

    $webSiteExists = Get-Website -Name $siteName 
    if(!$webSiteExists) {
        Write-Host "Creating IIS-Website with Name: "  $siteName  " and Port: "  $sitePort  " on Path: "  $siteDir
        new-website -name $siteName -applicationpool $siteName -port $sitePort -physicalpath $siteDir
    } else {
        Write-Host "IIS-WebSite with Name: "  $siteName  " already exists"
    }

    $webAppExists = Get-WebApplication -name $appName

    if(!$webAppExists) {
        Write-Host "IIS-App " $siteName  "\" $appName  " does not exist, creating that Folder: " $appDir     
        mkdir $appDir

        Write-Host "Creating IIS-App with Name: "  $appName  " on dir: " $appDir  " for IIS-Site: "  $siteName  
        new-webapplication -name $appName -physicalpath $appDir -site $siteName -Force
    } else {
        Write-Host "IIS-App "  $siteName  "\"  $appName  " already exists"    
    }

    write-host "Setting win-Authentication now for "  $siteName  "/"  $appName 
    Set-WebConfigurationProperty "/system.applicationHost/ApplicationPools/add[@name='$appPoolName']" -PSPath IIS:\ -Name startMode -Value "AlwaysRunning"

    CopyAppFiles

    Write-Host "Opening Port for accessing that application: " $sitePort
    New-NetFirewallRule -displayName "IIS-WebApp: "$appName -direction inbound -action allow -protocol tcp -localport $sitePort

    Write-Host "Done"

}

