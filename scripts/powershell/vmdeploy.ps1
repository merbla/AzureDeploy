param( 

        [Parameter(Mandatory=$False)]
        [string]$pathToPublishSettings = "MySettings.publishsettings",

        [Parameter(Mandatory=$False,Position=9)]
        [string]$location = "West US"

	 )
cls

#Include the helpers
. .\Helpers.ps1

#Add the required modules
ImportIfNotExists "WebAdministration"
ImportIfNotExists "Azure"

cls

$startTime = Get-Date
Write-Host -ForegroundColor Yellow "Starting $startTime"

try{
    $thisIp = Detect-IPAddress
}
catch{
    Write-Error "Cannot determine public IP of this machine"
 
 exit
}

Write-Host -ForegroundColor Yellow "Public IP is $thisIp"

Import-AzurePublishSettingsFile -PublishSettingsFile $pathToPublishSettings

$azureImages = Get-AzureVMImage -Verbose







