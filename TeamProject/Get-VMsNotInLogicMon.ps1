#add powercli module
if ( !(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
. “C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1”
}

$creds = (Get-Credential think\tallen)
$vcenters =  @( "thinkvc.think.local" , "ctxvc.think.local" )
$vsession = Connect-VIServer -Server $vcenters -Credential $creds
$vms = Get-View -ViewType "VirtualMachine" -Property Name, Summary, Runtime, Guest -Filter @{"Runtime.PowerState"="poweredOn"} | ? {$_.Guest.GuestFullName -like "*Windows Server*"}
$logicMonCreds = (Get-Credential tallen)
$userName = $logicMonCreds.UserName
$pwd = $logicMonCreds.GetNetworkCredential().password
$logicMonAccount = "thinkfinance" 
$vmsNotInLogicMon = New-Object System.Collections.ArrayList


foreach ($vm in $vms) {
    $result = ""
    try {
        $displayName = $vm.Guest.HostName
        $validate = Invoke-RestMethod -Method Get -Uri "https://$logicMonAccount.logicmonitor.com/santaba/rpc/getHost?c=$logicMonAccount&u=$userName&p=$pwd&displayName=$displayName"
        if($validate.status -eq "1007"){
            $displayName = $vm.Guest.Hostname.Split('.')[0]
            $validate = Invoke-RestMethod -Method Get -Uri "https://$logicMonAccount.logicmonitor.com/santaba/rpc/getHost?c=$logicMonAccount&u=$userName&p=$pwd&displayName=$displayName"
            if($validate.status -eq "1007"){
                $displayName = $vm.Name
                $validate = Invoke-RestMethod -Method Get -Uri "https://$logicMonAccount.logicmonitor.com/santaba/rpc/getHost?c=$logicMonAccount&u=$userName&p=$pwd&displayName=$displayName"
                if($validate.status -eq "1007"){
                    $result = $vm.Name
                    $vmsNotInLogicMon.Add($result) | Out-Null
                }
            }
        }
    }
    catch {
        $errorMessage = $_
        $vm.Name + " " + $errorMessage
    }
}
$vmsNotInLogicMon | sort

Disconnect-VIServer -Server $vcenters -Confirm:$false