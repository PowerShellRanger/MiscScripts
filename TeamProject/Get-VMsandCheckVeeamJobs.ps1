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

$veeamBackupJobObjects = $veeamJobObjects | ? {$_.JobType -like "Backup"}
$veeamReplicaJobObjects = $veeamJobObjects | ? {$_.JobType -like "Replica"}
$vmsThinkVC = $vmsAll | ? {$_.vCenter -like "ThinkVC*" -and $_.PowerState -eq "PoweredOn" -and $_.Name -notlike "NTNX*"}

$output = @()
foreach ($vm in $vmsThinkVC) {
    switch ($vm.Name) {
        {$veeamBackupJobObjects.Name -contains $_ -and $veeamReplicaJobObjects.Name -contains $_} {$result = [PsCustomObject] @{"VMName" = $vm.Name ; "BackedUp" = "True" ;"Replica" = "True"} ; break}
        {$veeamBackupJobObjects.Name -contains $_} {$result = [PsCustomObject] @{"VMName" = $vm.Name ; "BackedUp" = "True" ;"Replica" = "False"} ; break}
        {$veeamReplicaJobObjects.Name -contains $_} {$result = [PsCustomObject] @{"VMName" = $vm.Name ; "BackedUp" = "False" ;"Replica" = "True"} ; break}
        default {$result = [PsCustomObject] @{"VMName" = $vm.Name ; "BackedUp" = "False" ;"Replica" = "False"}}
    }
    $output += $result
}
$output | Export-Excel -Path C:\users\tallen\Desktop\AllVMsCheckVeeamJobs.xlsx -BoldTopRow -show -FreezeTopRow -AutoSize


Disconnect-PSSession -Session $session -Confirm:$false
Disconnect-VIServer -Server $vsession -Confirm:$false