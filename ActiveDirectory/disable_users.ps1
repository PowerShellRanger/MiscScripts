$users = Get-Content C:\Scripts\usersList.txt
$adUsers = New-Object System.Collections.ArrayList
$creds = Get-Credential
$domain = ''

foreach ($user in $users) {
    $adUser = Get-ADUser -Filter {DisplayName -like $user} -Server $domain -Properties Enabled
    if (-not $adUser) {
        Write-Warning "Could not find $user!"
        continue
    }
    ## Check for admin accounts
    $e_Account = "e_$($adUser.SamAccountName)"
    $a_Account = "a_$($adUser.SamAccountName)"
    $adminAccount = Get-ADUser -Filter {SamAccountName -like $e_Account -or SamAccountName -like $a_Account} -Server $domain
    if ($adminAccount) {
        [void] $adUsers.Add($adminAccount)            
    }
    [void] $adUsers.Add($adUser)    
}

foreach ($adUser in $adUsers) {
    if ($adUser.Enabled -eq 'True') {
        Disable-ADAccount -Identity $($adUser.SamAccountName) -Server $domain -Credential $creds
    }
    try {
        $adUser | Move-ADObject -TargetPath "" -Server $domain -Credential $creds -ErrorAction Stop
    }
    catch {
        throw $_
    }
}

$users.Count
$adUsers.SamAccountName

$emailcreds = Get-Credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $emailcreds -Authentication Basic -AllowRedirection -ErrorAction Stop
[void](Import-PSSession $exchangeSession -AllowClobber -DisableNameChecking)

foreach ($user in $users[0]) {
    $adUser = Get-ADUser -Filter {DisplayName -like $user} -Server $domain -Properties mail | where {$_.Mail}
    $mailbox = Get-Mailbox -Identity $adUser.Mail
    if (-not $mailbox) {
        Write-Warning "Could not find mailbox for $($aduser.Name)"
        continue
    }
    $mailbox | Set-Mailbox -Type Shared
}
