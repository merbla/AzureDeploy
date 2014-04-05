<#
http://gallery.technet.microsoft.com/scriptcenter/Deploy-a-Windows-Azure-Web-81629e04
http://code.msdn.microsoft.com/windowsazure/Fix-It-app-for-Building-cdd80df4
http://www.windowsazure.com/en-us/develop/net/building-real-world-cloud-apps/

.\deploy.ps1 -pathToAzureConfig "C:\AzureDeploy\scripts\powershell\ServiceConfiguration.Cloud.cscfg" -pathToAzurePackage "C:\AzureDeploy\scripts\powershell\Sample.Cloud.cspkg" -Verbose

#>
param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$pathToAzureConfig ,

        [Parameter(Mandatory=$True,Position=2)]
        [string]$pathToAzurePackage ,

        [Parameter(Mandatory=$False,Position=3)]
        [string]$pathToPublishSettings = "MySettings.publishsettings",

        [Parameter(Mandatory=$False,Position=4)]
        [string]$serviceName = "bneazuredemodeploy",

        [Parameter(Mandatory=$False,Position=6)]
        [string]$sqlAdminUser = "bneazuredemo1",
                
        [Parameter(Mandatory=$False,Position=7)]
        [string]$sqlAdminPassword = "2gMPkgRnwb7Perbrl1X5",

        [Parameter(Mandatory=$False,Position=8)]
        [string]$pathToDacPac = "Sample.Cloud.Database.dacpac",

        [Parameter(Mandatory=$False,Position=9)]
        [string]$location = "West US",

        [Parameter(Mandatory=$False,Position=10)]
        [bool]$removeServices = $False


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
    $ipRange = Detect-IPAddress
}
catch{
    Write-Error "Cannot determine public IP of this machine"
 
 exit
}

 
Write-Host -ForegroundColor Yellow "Public IP of this machine: $ipRange"

if($removeServices -eq $True){
    
    $servers = Get-AzureSqlDatabaseServer
    Foreach ($s in $servers){
        if($s.Location -eq $location){
            $databaseServer = $s;

        }    
    }
    Remove-AzureSqlDatabaseServer -ServerName $databaseServer.ServerName -Force -WarningAction SilentlyContinue
    Remove-AzureDeployment -ServiceName $serviceName -Slot Production -DeleteVHD -Force -WarningAction SilentlyContinue
    Remove-AzureStorageAccount -StorageAccountName $storageAccountName -WarningAction SilentlyContinue 
    Remove-AzureService -Confirm -DeleteAll -Force -PassThru -ServiceName $serviceName -WarningAction SilentlyContinue 
 }


$affinityGroupName = $serviceName
$databaseName = $serviceName
$storageAccountName = $serviceName
$firewallRuleName = $serviceName

#Add the MSDN publish settings
Import-AzurePublishSettingsFile -PublishSettingsFile $pathToPublishSettings

$subscription = Get-AzureSubscription -Current
if (!$subscription) {throw "Cannot get Windows Azure subscription. Failure in Get-AzureSubscription check publish setttings file"}

CreateSqlServer -firewallRuleName $serviceName  -sqlAdminUser  $sqlAdminUser -sqlAdminPassword $sqlAdminPassword -location $location -ipAddress $ipRange

#Get the server
$servers = Get-AzureSqlDatabaseServer
Foreach ($s in $servers){
    if($s.Location -eq $location){
        $sqlServerName = $s.ServerName;
        break
    }    
}



CreateAffinityGroup $affinityGroupName $location

CreateCloudService $serviceName $affinityGroupName

CreateCloudStorage $storageAccountName $affinityGroupName

#Set the Default Storage Account & get the access key of the storage account
Set-AzureSubscription $subscription.SubscriptionName -CurrentStorageAccountName $storageAccountName 


$storagekey = Get-AzureStorageKey -StorageAccountName $storageAccountName
$defaultStorageEndpoint ="DefaultEndpointsProtocol=https;AccountName={0};AccountKey={1}" -f $storageAccountName, $storagekey.Primary


#Update the config
Write-Host -ForegroundColor Yellow "Updating storage config to use $defaultStorageEndpoint"

Update-CscfgSetting -configurationFilePath $pathToAzureConfig -settingName "Microsoft.WindowsAzure.Plugins.Caching.ConfigStoreConnectionString" -settingValue $defaultStorageEndpoint
Update-CscfgSetting -configurationFilePath $pathToAzureConfig -settingName "Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" -settingValue $defaultStorageEndpoint

$deployment = DeployPackage -serviceName $serviceName -pathToAzureConfig $pathToAzureConfig -pathToAzurePackage $pathToAzurePackage

WaitRoleInstanceReady $serviceName

$database = CreateDatabase -databaseServerName $sqlServerName -databaseName $databaseName
$databaseConnectionString = Get-SQLAzureDatabaseConnectionString -serverName $sqlServerName  -databaseName $databaseName -sqlUser  $sqlAdminUser -sqlPassword $sqlAdminPassword 

Write-Host -ForegroundColor Yellow "Deploying using $databaseConnectionString"

$sqlPackageExe = 'C:\Program Files (x86)\Microsoft SQL Server\110\DAC\bin\SqlPackage.exe'
&$sqlPackageExe /a:Publish /sf:$pathToDacPac /tcs:$databaseConnectionString 

$finishTime = Get-Date

Write-Host -ForegroundColor Yellow "Started $startTime"
Write-Host -ForegroundColor Yellow "Finished $finishTime"

if($openBrowserWhenComplete -eq $True){
    Start-Process -FilePath ("http://{0}.cloudapp.net" -f $ServiceName)
}

