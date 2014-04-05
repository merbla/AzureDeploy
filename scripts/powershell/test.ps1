$serviceName ="bneazuredemo2"
 
$vmName = "bneazurevm01" 
         
$adminUser = "bneazuredemo1" 
$adminPassword = "2gMPkgRnwb7Perbrl1X5"
 
 
$subscription = Get-AzureSubscription -Current
if (!$subscription) {throw "Cannot get Windows Azure subscription. Failure in Get-AzureSubscription check publish setttings file"}

.\InstallWinRMCertAzureVM.ps1 -SubscriptionName $subscription.SubscriptionName -ServiceName $serviceName -Name $vmName 
 
  
$uri = Get-AzureWinRMUri -ServiceName $serviceName -Name $vmName 
 
$secPassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($adminUser, $adminPassword)
 
  
Enter-PSSession -ConnectionUri $uri -Credential $credential 