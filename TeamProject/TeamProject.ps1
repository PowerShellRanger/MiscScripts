#add powercli module
if ( !(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
. “C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1”
}

$creds = (Get-Credential think\tallen)
$vcenter = "thinkvc.think.local"
$vsession = Connect-VIServer -Server $vcenter -Credential $creds
$vms = Get-VM -Name *
$tabVMs = New-Object System.Collections.ArrayList
$veeamServer = "veeam.think.local"
$wsusServer = "wsus.think.local"
$veeamSession = New-PSSession -ComputerName $veeamServer -Credential $creds -Authentication Credssp
$wsusSession = New-PSSession -ComputerName $wsusServer -Credential $creds
$date = (Get-Date).AddDays(-60)

$veeamJobObjects = Invoke-Command -Session $veeamSession -ScriptBlock {
    Add-PSSnapin "VeeamPSSNapIn"
    #get veeam jobs that are enabled and the backups objects in each job
    $jobs = Get-VBRJob | ? {$_.IsScheduleEnabled -eq "True" -and $_.jobtype -eq "Replica" -or $_.jobtype -eq "Backup"}
        foreach ($job in $jobs) { 
            Get-VBRJobObject -Job $job.name | select Name, @{N="JobName";E={@($job.name)}}, @{N="JobType";E={$job.JobType}} | sort JobName
        }
} | select @{N="Name";E={$_.Name.split('_')[0]}} , JobType -Unique | sort Name

$veeamBackupJobObjects = $veeamJobObjects | Where-Object {$_.JobType -like "Backup"}
$veeamReplicaJobObjects = $veeamJobObjects | Where-Object {$_.JobType -like "Replica"} 

$wsusObjects = Invoke-Command -Session $wsusSession -ScriptBlock {
    Import-Module UpdateServices
    Get-WsusComputer -FromLastReportedStatusTime $using:date | select FullDomainName
} | select FullDomainName


function Get-VMPoweredOnAndWindows { 
  <# 
  .SYNOPSIS 
  
  .DESCRIPTION 
  
  .EXAMPLE 
  
  .EXAMPLE
     
  #> 
  [CmdletBinding()] 
  param 
  ( 
    #computer variable
    [Parameter(Mandatory=$True, 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True)] 
    [string]$Name
  ) 
 
  begin {

  } 
 
  process {
    Get-View -ViewType "VirtualMachine" -Property Name, Runtime, Guest -Filter @{"Name"=$Name} | Where-Object {$_.Runtime.PowerState -eq "PoweredOn" -and $_.Guest.GuestFullName -like "*Windows Server*"}
  } 
} 
function Get-VMPoweredOnAndNotNutanix { 
  <# 
  .SYNOPSIS 
  
  .DESCRIPTION 
  
  .EXAMPLE 
  
  .EXAMPLE
     
  #> 
  [CmdletBinding()] 
  param 
  ( 
    #computer variable
    [Parameter(Mandatory=$True, 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True)] 
    [string]$Name
  ) 
 
  begin {

  } 
 
  process {
    Get-View -ViewType "VirtualMachine" -Property Name, Runtime, Guest -Filter @{"Name"=$Name} | Where-Object {$_.Runtime.PowerState -eq "PoweredOn" -and $_.Name -notlike "*NTNX*"}
  } 
} 


foreach ($vm in $vms) {
    $result = [PsCustomObject] @{
         "vCenter" = $vm.ExtensionData.Client.ServiceUrl.Split('.')[0].Split('/')[2]
         "Cluster" = (Get-Cluster -VM $vm).Name 
         "VMHost" = $vm.VMHost.Name.Split(".")[0]
         "Name" = $vm.Name
         "FQDN" = $vm.Guest.HostName
         "PowerState" = $vm.PowerState
         #"NumCPU" = $vm.NumCpu
         #"MemoryGB" = $vm.MemoryGB
         "ProvisionedGB" = [math]::Round($vm.ProvisionedSpaceGB,0)
         "UsedGB" = [math]::Round($vm.UsedSpaceGB,0)
         "Category" = ((Get-TagAssignment -Entity $vm).Tag | ? {$_.Category -eq "Category"}).Name -join ","
         "Lifecycle" = ((Get-TagAssignment -Entity $vm).Tag | ? {$_.Category -eq "Lifecycle"}).Name -join ","
         "Function" = ((Get-TagAssignment -Entity $vm).Tag | ? {$_.Category -eq "Function"}).Name -join ","
         "Platform" = ((Get-TagAssignment -Entity $vm).Tag | ? {$_.Category -eq "Platform"}).Name -join ","
         "Application" = ((Get-TagAssignment -Entity $vm).Tag | ? {$_.Category -eq "Application"}).Name -join ","
         "Owner" = ((Get-TagAssignment -Entity $vm).Tag | ? {$_.Category -eq "Owner"}).Name -join ","
         "Customer" = ((Get-TagAssignment -Entity $vm).Tag | ? {$_.Category -eq "Customer"}).Name -join ","
         "BackedUp" = if(Get-VMPoweredOnAndNotNutanix -Name $vm.Name) {if($veeamBackupJobObjects.Name -contains $vm.Name){"True"} else{"False"} } else{$null}
         "Replica" = if(Get-VMPoweredOnAndNotNutanix -Name $vm.Name) {if($veeamReplicaJobObjects.Name -contains $vm.Name){"True"} else{"False"} } else{$null}
         "VM in WSUS" = if(Get-VMPoweredOnAndWindows -Name $vm.Name) {if($wsusObjects.FullDomainName -contains $vm.Name){"True"} else{"False"} } else{$null}
                
    }
    $tabVMs.Add($result) | Out-Null
}
$tabVMs |select Name, BackedUp, Replica, 'VM in Wsus'

$tabVMs | ft -autosize 
