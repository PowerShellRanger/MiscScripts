#add powercli module
if ( !(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
. “C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1”
}

$creds = (Get-Credential think\tallen)
$vcenters =  @( "thinkvc.think.local" , "ctxvc.think.local" )
$vsession = Connect-VIServer -Server $vcenters -Credential $creds
$vms = Get-View -ViewType "VirtualMachine" -Property Name, Summary, Runtime, Guest -Filter @{"Runtime.PowerState"="PoweredOn"} | ? {$_.Guest.GuestFullName -like "*Windows Server*"}
$logicMonCreds = (Get-Credential tallen)
$userName = $logicMonCreds.UserName
$pwd = $logicMonCreds.GetNetworkCredential().password
$logicMonAccount = "thinkfinance" 
$logicMonSDTGroup = "349"

foreach ($vm in $vms) {
    $result = ""
    $newDisplayName = ""
    $displayName = $vm.Guest.HostName
    $validate = Invoke-RestMethod -Method Get -Uri "https://$logicMonAccount.logicmonitor.com/santaba/rpc/getHost?c=$logicMonAccount&u=$userName&p=$pwd&displayName=$displayName"
        if($validate.status -eq "1007"){
            Write-Host "$displayName is not in LogicMon!" -ForegroundColor "red"
            $displayName = ($vm.Guest.HostName.Split('.')[0]).ToUpper()
            $displayDomain = ($vm.Guest.HostName.Split('.')[1..2] -join '.').ToLower()
            $newDisplayName = "$displayName.$displayDomain"
            $newHostName = "$displayName.$displayDomain"
                switch ($displayDomain) {
                    {$_ -like "think.local"} {$agentIdNum = $thinkDomainCollector}
                    {$_ -like "cstfe.local"} {$agentIdNum = $cstfeDomainCollector}
                    default {$agentIdNum = $null}
                }
                    if ($agentIdNum) {
                        try{
                        $result = Invoke-RestMethod -Method Post -Uri "https://$logicMonAccount.logicmonitor.com/santaba/rpc/addHost?c=$logicMonAccount&u=$userName&p=$pwd&hostName=$newHostName&displayedAs=$newDisplayName&agentId=$agentIdNum&alertEnable=true&hostGroupIds=$logicMonSDTGroup"
                        $vmsAddedLogicMon.Add($result.data.hostName) | Out-Null
                        Write-Host "Adding $newDisplayName to LogicMon group 'New Deployment - SDT'" -ForegroundColor "yellow"
                        }
                        catch {
                            $errorMessage = $_
                            $vm.Name + " " + $errorMessage | Out-File c:\scripts\errors.txt -Append
                        }
                    }
                    else {
                        Write-Host "$newDisplayName was not added to LogicMon!" -ForegroundColor "red"
                        $vmsNotAddedLogicMon.Add($newDisplayName) | Out-Null
                    }
                }
        }
    }
}