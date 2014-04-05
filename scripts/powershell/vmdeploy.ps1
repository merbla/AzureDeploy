#.\vmdeploy.ps1 -serviceName "bneazuredemo2"

param( 

        [Parameter(Mandatory=$False)]
        [string]$pathToPublishSettings = "MySettings.publishsettings",

        [Parameter(Mandatory=$False)]        
        [string]$location = "West US",

        [Parameter(Mandatory=$False)]
        [string]$serviceName = "bneazuredemodeploy",

        [Parameter(Mandatory=$False)]
        [string]$vmName = "bneazurevm01",

        [Parameter(Mandatory=$False)]
        [string]$adminUser = "bneazuredemo1",
                
        [Parameter(Mandatory=$False)]
        [string]$adminPassword = "2gMPkgRnwb7Perbrl1X5"
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

$affinityGroupName = $serviceName

try{
    $thisIp = Detect-IPAddress
}
catch{
    Write-Error "Cannot determine public IP of this machine"
 
 exit
}

Write-Host -ForegroundColor Yellow "Public IP is $thisIp"
Import-AzurePublishSettingsFile -PublishSettingsFile $pathToPublishSettings

CreateAffinityGroup $affinityGroupName $location
CreateCloudService $serviceName $affinityGroupName
CreateCloudStorage $serviceName $affinityGroupName

$subscription = Get-AzureSubscription -Current
if (!$subscription) {throw "Cannot get Windows Azure subscription. Failure in Get-AzureSubscription check publish setttings file"}

Set-AzureSubscription $subscription.SubscriptionName -CurrentStorageAccountName $serviceName 

$azureImages = Get-AzureVMImage | where {$_.PublisherName -eq “Microsoft Windows Server Group”} | where {$_.Label -eq “Windows Server 2012 R2 Datacenter, March 2014”} 
$image = $azureImages[0]
$vmImageName = $image.imagename

$doesTheVMExist = Test-AzureName -Service $serviceName
Write-Host -ForegroundColor Yellow "Does the service exist ??? $doesTheVMExist"

#if($doesTheVMExist -eq $false){
    $awesomeVM = New-AzureVMConfig –ImageName $vmImageName –Name $vmName –InstanceSize "Small" –HostCaching "ReadWrite" –DiskLabel "System"
    $awesomeVM = Add-AzureProvisioningConfig –Windows –VM $awesomeVM –Password $adminPassword -AdminUsername $adminUser -EnableWinRMHttp
    New-AzureVM –VM $awesomeVM –ServiceName $serviceName -Verbose -WaitForBoot
#}

.\InstallWinRMCertAzureVM.ps1 -SubscriptionName $subscription.SubscriptionName -ServiceName $serviceName -Name $vmName 
   
$uri = Get-AzureWinRMUri -ServiceName $serviceName -Name $vmName 
 
$secPassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($adminUser, $secPassword)
 
  
Enter-PSSession -ConnectionUri $uri -Credential $credential 

