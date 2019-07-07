param (

    [string]$siteName = "Survey",

    [string]$sitePort = 8100,

    [string]$appName = "Survey.Web",
    [string]$appPoolName = $siteName
)
    

import-module WebAdministration

$siteDir = "$env:systemdrive\inetpub\$siteName"
$appDir = $siteDir + "\" + $appName

Write-Host "Removing Port rule: " $sitePort
Remove-NetFirewallRule -displayName "IIS-WebApp: "+$appName

Write-Host "Removing WebApp: " $appName
Remove-WebApplication -Name $appName

Write-Host "Removing Files from: " $appDir
rm $appDir

Write-Host "Done"


