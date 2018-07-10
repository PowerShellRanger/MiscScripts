
$domain = ''

$creds = Get-AutomationPSCredential -Name ''

$domainControllers = Get-ADDomainController -Filter * -Server $domain -Credential $creds | select Name

$disabledUsers = New-Object 'System.Collections.Generic.List[PSCustomObject]'

foreach ($dc in $domainControllers)
{    
    $session = New-PSSession -ComputerName $dc.Name -Credential $creds -ErrorAction Stop
    
    $results = Invoke-Command -Session $session -ScriptBlock {
        try
        {
            Write-Warning "Getting security events with ID: 4725 on Domain Controller: $($using:dc.Name)"

            $splatGetWinEvent = @{
                FilterHashtable = @{ logname = 'security'; id = 4725; starttime = (Get-Date).AddDays(-1) }
                ComputerName    = "$($using:dc.Name).$using:domain"            
                Credential      = $using:creds
                ErrorAction     = 'Stop'
            }        
            $events = Get-WinEvent @splatGetWinEvent
        }
        catch
        {
            Write-Error $_
            continue
        }

        foreach ($event in $events)
        {
            $eventXML = [xml]$event.ToXml()

            [PSCustomObject] @{
                DisabledUser = @($eventXML.Event.EventData.Data).Where( { $_.Name -eq 'TargetUserName' }).'#text'
                ChangedBy    = @($eventXML.Event.EventData.Data).Where( { $_.Name -eq 'SubjectUserName' }).'#text'
                Date         = $event.TimeCreated
            }
        }
    } -HideComputerName

    [void](Remove-PSSession -Session $session -Confirm:$false)

    $results | ForEach-Object { [void]$disabledUsers.Add($_) }
}

$disabledOU = "OU=Users,OU=Disabled Accounts,DC=$($domain.Split('.')[0]),DC=COM"
$logPath = ''

$disabledUsersGroup = Get-ADGroup -Identity 'Disabled Users Group' -Server $domain -Properties PrimaryGroupToken -ErrorAction Stop

foreach ($account in $disabledUsers)
{
    $adUser = ''
    
    $samAccountName = "$($account.DisabledUser)"
    $splatGetAdUser = @{
        Filter     = {SamAccountName -like $samAccountName}
        Server     = $domain
        SearchBase = $disabledOU
        Properties = 'ShowInAddressBook', 'PrimaryGroup'
        Credential = $creds
    }
    $adUser = Get-ADUser @splatGetAdUser

    if (-not $adUser)
    {
        Write-Warning "User: $($account.DisabledUser) was not found in OU: $disabledOU."
        continue
    }
    
    if ($adUser.Enabled)
    {
        Write-Warning "$($adUser.SamAccountName) is still Enabled in domain: $domain. Disabling user."
        Disable-ADAccount -Identity $adUser -Credential $creds -Confirm:$false -ErrorAction Stop
    }

    if ($adUser.ShowInAddressBook)
    {
        Write-Warning "Removing user: $($adUser.SamAccountName) from Global Address List."

        $splatSetAdObject = @{
            Identity   = $adUser
            Clear      = 'ShowInAddressBook'
            Credential = $creds
            Server     = $domain
            Confirm    = $false
        }
        Set-ADObject @splatSetAdObject
    }    
    
    $groupMembership = Get-ADPrincipalGroupMembership -Identity $adUser -Server $domain -Credential $creds | sort Name
    
    if (@($groupMembership).Count -eq 1 -and $groupMembership.Name -eq $disabledUsersGroup.Name)
    {
        Write-Warning "Nothing else to do for user: $($adUser.SamAccountName). Removed from all groups and primary group already set to $($disabledUsersGroup.Name)."
        continue
    }

    if ($groupMembership.Name -notcontains $disabledUsersGroup.Name)
    {
        Write-Warning "Adding user: $($adUser.SamAccountName) to the group: $($disabledUsersGroup.Name)."

        $splatAddAdGroupMember = @{
            Identity   = $disabledUsersGroup
            Members    = $adUser
            Server     = $domain
            Credential = $creds
            Confirm    = $false
        }
        Add-ADGroupMember @splatAddAdGroupMember
    }

    if ($adUser.PrimaryGroup -notlike "*$($disabledUsersGroup.Name)*")
    {
        Write-Warning "Setting user: $($adUser.SamAccountName)'s primary group to '$($disabledUsersGroup.Name).'"

        $splatSetAdUser = @{
            Identity   = $adUser
            Replace    = @{primarygroupid = $disabledUsersGroup.PrimaryGroupToken}
            Server     = $domain
            Credential = $creds
            Confirm    = $false
        }
        Set-ADUser @splatSetAdUser
    }

    $membershipObject = @()
    foreach ($group in @($groupMembership).Where( { $_.Name -notlike $disabledUsersGroup.Name }))
    {
        $membershipObject += [PSCustomObject] @{
            Name              = $($group.Name)
            SamAccountName    = $($group.SamAccountName)
            DistinguishedName = $($group.DistinguishedName)
            Date              = Get-Date -Format MM/dd/yyyy
        }

        Write-Warning "Removing user: $($adUser.SamAccountName) from group: $($group.SamAccountName)."

        $splatRemoveAdGroupMember = @{
            Identity = $group.SamAccountName
            Members = $adUser.SamAccountName
            Server = $domain
            Credential = $creds
            Confirm = $false
        }
        Remove-ADGroupMember @splatRemoveAdGroupMember
    }

    $fileName = "$($adUser.SamAccountName.ToLower())_$($domain.ToLower()).csv"
    $fullLogPath = Join-Path -Path $logPath -ChildPath $fileName

    Write-Warning "Adding group membership info to logfile at $fullLogPath"
    $membershipObject | Export-Csv -Path $fullLogPath -Append -NoTypeInformation    
}


