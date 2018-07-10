#add powercli module
if ( !(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
. “C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1”
}

$creds = (Get-Credential think\tallen)
$vcenter = "thinkvc.think.local"
$vsession = Connect-VIServer -Server $vcenter -Credential $creds
$vmsAll = Import-Excel -Path H:\VMsAll.xlsx
$veeamServer = "veeam.think.local"
$session = New-PSSession -ComputerName $veeamServer -Credential $creds -Authentication Credssp

$veeamJobObjects = Invoke-Command -Session $session -ScriptBlock {
    Add-PSSnapin "VeeamPSSNapIn"
    #get veeam jobs that are enabled and the backups objects in each job
    $jobs = Get-VBRJob | ? {$_.IsScheduleEnabled -eq "True" -and $_.jobtype -eq "Replica" -or $_.jobtype -eq "Backup"}
        foreach ($job in $jobs) { 
            Get-VBRJobObject -Job $job.name | select Name, @{N="JobName";E={@($job.name)}}, @{N="JobType";E={$job.JobType}} | sort JobName
        }
} | select @{N="Name";E={$_.Name.split('_')[0]}} , JobType -Unique | sort Name


$vmsNotBackedUp = Compare-Object -ReferenceObject ($vmsAll | ? {$_.vCenter -eq "ThinkVC" -and $_.PowerState -eq "PoweredOn" -and $_.Name -notlike "NTNX*"}) -DifferenceObject ($veeamJobObjects | ? {$_.JobType -like "Backup"}) -Property Name | ? {$_.SideIndicator -eq "<="} | sort Name | % {[PSCustomObject] @{"VMName" = $_.Name ; "BackedUp" = "False"} }
$vmsNotReplicated = Compare-Object -ReferenceObject ($vmsAll | ? {$_.vCenter -eq "ThinkVC" -and $_.PowerState -eq "PoweredOn" -and $_.Name -notlike "NTNX*"}) -DifferenceObject ($veeamJobObjects | ? {$_.JobType -like "Replica*"}) -Property Name | ? {$_.SideIndicator -eq "<="} | sort Name | % {[PSCustomObject] @{"VMName" = $_.Name ; "Replica" = "False"} }
$nonReplicaAndBackupVMs = $vmsNotBackedUp + $vmsNotReplicated | select -Unique vmname | sort vmname
$output = @()

foreach ($vm in $nonReplicaAndBackupVMs) {
    switch ($vm.VMName) {
        {$vmsNotBackedUp.VMName -and $vmsNotReplicated.VMName -contains $_} {$result = [PsCustomObject] @{"VMName" = $vm.VMName ; "BackedUp" = "False" ;"Replica" = "False"} ; break}
        {$vmsNotBackedUp.VMName -contains $_} {$result = [PsCustomObject] @{"VMName" = $vm.VMName ; "BackedUp" = "False" ;"Replica" = "True"} ; break}
        {$vmsNotReplicated.VMName -contains $_} {$result = [PsCustomObject] @{"VMName" = $vm.VMName ; "BackedUp" = "True" ;"Replica" = "False"} ; break}
        default {$result = [PsCustomObject] @{"VMName" = $vm.VMName ; "BackedUp" = "True" ;"Replica" = "True"}}
    }
    $output += $result
}
$output | Export-Excel -Path C:\users\tallen\Desktop\VMsNotReplicatedORBackedUp.xlsx -BoldTopRow -show -FreezeTopRow -AutoSize


Disconnect-PSSession -Session $session -Confirm:$false
Disconnect-VIServer -Server $vsession -Confirm:$false
