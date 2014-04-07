#Closures
function =>([scriptblock]$_sb_){
    $_sb_.GetNewClosure()
}

function doIt([ScriptBlock] $block){
    &$block
}

$myName = "Matt"

doIt (. => { 
    Write-Host -ForegroundColor Red $myName
    #Install-WindowsFeature -Name Application-Server -Verbose $myName
})

Invoke-Command –ConnectionUri $uri `
    –Credential $credential `
    –ScriptBlock { 
        Install-WindowsFeature -Name Application-Server -Verbose $myName
    }


