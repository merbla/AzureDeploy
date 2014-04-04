
function ImportIfNotExists
{
 Param([string] $moduleName)

    if (Get-Module | ?{ $_.Name -eq $moduleName }){
        Remove-Module WebAdministration
    }
    Import-Module $moduleName
}

function CreateAffinityGroup 
{
 Param(
   [Parameter(Mandatory = $true)]
    [String]$affinityGroupName ,    
     
    [Parameter(Mandatory = $true)]
    [String]$serviceLocation
 
    )
 
    $affinityGroup = Get-AzureAffinityGroup -Name $affinityGroupName -ErrorAction Ignore

    if($affinityGroup -eq $null){
       Write-Verbose "Creating AffinityGroup"
       New-AzureAffinityGroup -Location $location -Name $affinityGroupName 

       $affinityGroup = Get-AzureAffinityGroup -Name $affinityGroupName -ErrorAction Ignore
    }
    else{
        Write-Verbose "Found AffinityGroup $affinityGroupName"
    }

    return $affinityGroup
} 

function CreateCloudService 
{
 Param(
    [Parameter(Mandatory = $true)]
    [String]$serviceName, 

    [Parameter(Mandatory = $true)]
    [String]$affinityGroupName      
    )  

    $service = Get-AzureService -ServiceName $serviceName  -ErrorAction Ignore

    if($service -eq $null){
        Write-Verbose "Creating Service $serviceName"
        New-AzureService -AffinityGroup $affinityGroupName  -ServiceName $serviceName
    }
    else{
        Write-Verbose "Found Service $serviceName"
    }
}

function CreateCloudStorage
{
 Param(
    [Parameter(Mandatory = $true)]
    [String]$storageAccountName, 

    [Parameter(Mandatory = $true)]
    [String]$affinityGroupName      
    )  
     
    $storageAccount =  Get-AzureStorageAccount -StorageAccountName $storageAccountName -ErrorAction Ignore

    if($storageAccount -eq $null){
        Write-Verbose "Creating Storage Account $storageAccountName"
        New-AzureStorageAccount -AffinityGroup $affinityGroupName -StorageAccountName $storageAccountName
        $storageAccount =  Get-AzureStorageAccount -StorageAccountName $storageAccountName -ErrorAction Ignore
    }
    else{
        Write-Verbose "Found storage account $storageAccountName"
    }
    
    return $storageAccount
}

function Update-CscfgSetting {
    Param (
        [Parameter(Mandatory = $true)]
        [String]$configurationFilePath,

        [Parameter(Mandatory = $true)]
        [String]$settingName, 

        [Parameter(Mandatory = $true)]
        [String]$settingValue
    )
    
    [Xml]$cscfgXml = Get-Content $configurationFilePath 
        
    Foreach ($role in $cscfgXml.ServiceConfiguration.Role)
    {
        Write-Verbose "Checking $role.name"
        Foreach ($setting in $role.ConfigurationSettings.Setting)
        {             
            Write-Verbose "Checking $setting.name "
            if($setting.name -eq $settingName){
                $setting.value =$settingValue
                Write-Verbose "Updated Value $settingName"
            }
        }
    }
         
    $cscfgXml.Save($configurationFilePath)
}

function DeployPackage 
{
Param(
    
    [Parameter(Mandatory = $true)]
    [String]$serviceName,
    
    [Parameter(Mandatory = $true)]
    [String]$pathToAzureConfig,
    
    [Parameter(Mandatory = $true)]
    [String]$pathToAzurePackage
)
       
        Write-Verbose "[Start] Deploy Service $serviceName"

        $deployment = Get-AzureDeployment -ServiceName $serviceName -Slot Production -ErrorAction Ignore
        
        if($deployment -eq $null){
            Write-Verbose "Deployment does not exist, creating new deployment"
            New-AzureDeployment `
                -ServiceName $serviceName `
                -Slot Production `
                -Configuration $pathToAzureConfig `
                -Package $pathToAzurePackage ` 
        }
        else{
            Write-Verbose "Deployment exists, updating deployment"
            Set-AzureDeployment `
                -ServiceName $serviceName `
                -Slot Production `
                -Configuration $pathToAzureConfig `
                -Package $pathToAzurePackage `
                -Mode Simultaneous -Upgrade
        }
        
        $deployment = Get-AzureDeployment -ServiceName $serviceName -Slot Production -ErrorAction Ignore

        Write-Verbose "[Finish] Deploy Service $serviceName"
        return $deployment
     
}
 
function WaitRoleInstanceReady 
{
Param(
   
    [Parameter(Mandatory = $true)]
    [String]$MyServiceName
)
    Write-Verbose ("[Start] Waiting for Instance Ready")
    do
    {
        $MyDeploy = Get-AzureDeployment -ServiceName $MyServiceName  
        foreach ($instance in $MyDeploy.RoleInstanceList)
        {
            $switch=$true
            Write-Verbose ("Instance {0} is in state {1}" -f $instance.InstanceName, $instance.InstanceStatus )
            if ($instance.InstanceStatus -ne "ReadyRole")
            {
                $switch=$false
            }
        }
        if (-Not($switch))
        {
            Write-Verbose ("Waiting Azure Deploy running, it status is {0}" -f $MyDeploy.Status)
            Start-Sleep -s 10
        }
        else
        {
            Write-Verbose ("[Finish] Waiting for Instance Ready")
        }
    }
    until ($switch)
}

Function Detect-IPAddress
{
   
   <#
			" Satnaam WaheGuru Ji"	
			
			Author  :  Aman Dhally
			E-Mail  :  amandhally@gmail.com
			website :  www.amandhally.net
			twitter : https://twitter.com/#!/AmanDhally
			facebook: http://www.facebook.com/groups/254997707860848/
			Linkedin: http://www.linkedin.com/profile/view?id=23651495

			Date	: 03-Oct-2012
			File	: static-Ip
			Purpose : Get Static Ip adress of the Internet
			
			Version : 1

			my Spider runned Away :( 


#>

#Variables
	# I am defining website url in a variable
	$url = "http://checkip.dyndns.com" 
	# Creating a new .Net Object names a System.Net.Webclient
	$webclient = New-Object System.Net.WebClient
	# In this new webdownlader object we are telling $webclient to download the
	# url $url 
	$Ip = $webclient.DownloadString($url)
	# Just a simple text manuplation to get the ipadress form downloaded URL
    # If you want to know what it contain try to see the variable $Ip
	$Ip2 = $Ip.ToString()
	$ip3 = $Ip2.Split(" ")
	$ip4 = $ip3[5]
	$ip5 = $ip4.replace("</body>","")
	$FinalIPAddress = $ip5.replace("</html>","")

#Write Ip Addres to the console
return	$FinalIPAddress

### end of the script.....
################################|-Aman Dhally - |-#############################


}

Function Get-SQLAzureDatabaseConnectionString
{
    Param(
        
        [String]$serverName,

        [String]$databaseName,

        [String]$sqlUser ,

        [String]$sqlPassword
    )

    Return "Server=tcp:{0}.database.windows.net,1433;Database={1};User ID={2}@{0};Password={3};Trusted_Connection=False;Encrypt=True;Connection Timeout=30;" -f
        $serverName, $databaseName, $sqlUser , $sqlPassword
}


function CreateDatabase{
    Param(
    [string] $databaseServerName,
    [string] $databaseName
    )

    Write-Host "Creating Database $databaseName on $databaseServerName" -ForegroundColor Yellow
    try{
        $database = Get-AzureSqlDatabase -DatabaseName $databaseName -ServerName $databaseServerName -WarningAction Ignore -ErrorAction SilentlyContinue
    }
    catch{}
    

    if($database -eq $null){
        Write-Verbose "Database does not exist on $databaseServerName, creating new $databaseName"
        $database = New-AzureSqlDatabase  -DatabaseName $databaseName -ServerName $databaseServerName -Verbose
    }
    else{
        Write-Verbose "Database already exists for the location "
    }

    return $database

}


function CreateSqlServer{
Param( 
        [string]$firewallRuleName,
       
        [string]$sqlAdminUser,                
       
        [string]$sqlAdminPassword,
       
        [string]$location,

        [string] $ipAddress
    )

    $servers = Get-AzureSqlDatabaseServer

    #if there is a server in the location use that
    Foreach ($s in $servers){
        if($s.Location -eq $location){
            $databaseServer = $s;
            break
        }    
    }

    if($databaseServer -eq $null){
        Write-Host "Database server does not exist for the location, creating new server" -ForegroundColor Yellow
        $databaseServer = New-AzureSqlDatabaseServer -AdministratorLogin $sqlAdminUser  -AdministratorLoginPassword $sqlAdminPassword -Location $location -Verbose
        
        New-AzureSqlDatabaseServerFirewallRule -ServerName $databaseServer.ServerName -RuleName $firewallRuleName -StartIpAddress $ipAddress -EndIpAddress $ipAddress
        #For the purposes of the demo all all :(
        New-AzureSqlDatabaseServerFirewallRule -ServerName $databaseServer.ServerName -RuleName "AllDaThingz" -StartIpAddress "0.0.0.0"  -EndIpAddress "255.255.255.255"

        New-AzureSqlDatabaseServerFirewallRule -ServerName $databaseServer.ServerName -RuleName "AllowAllAzureIP" -StartIpAddress "0.0.0.0" -EndIpAddress "0.0.0.0"
        
        Write-Host -ForegroundColor Yellow "Applied firewall rule for $ipAddress, waiting 120 secs for it to be applied"

        Start-Sleep -s 120
           
        $name =  $databaseServer.ServerName
                 
        Write-Host -ForegroundColor Yellow "SQL Server created: $name"
       
        
        return $name
    }
    else{
      Write-Host -ForegroundColor Yellow "Database server exists for the location, using $databaseServer.ServerName"
      Write-Host $databaseServer
      return $databaseServer.ServerName
    }
    
    
}
