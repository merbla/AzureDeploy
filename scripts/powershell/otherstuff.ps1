. .\Helpers.ps1
cls

#Closures
function doIt([ScriptBlock] $block){
    &$block
}

$myName = "Matt"

$sb = { Write-Host -ForegroundColor Yellow $myName }
doIt $sb

doIt (. => { 
    Write-Host -ForegroundColor Red $myName
}) 

#Invoke-Command –ConnectionUri $uri –Credential $credential –ScriptBlock { Install-WindowsFeature -Name Application-Server -Verbose   }


