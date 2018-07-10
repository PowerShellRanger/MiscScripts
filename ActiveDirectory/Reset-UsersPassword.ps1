function Reset-UsersPassword
{
     <#
    .Synopsis
       Reset user's password and unlock account
    .DESCRIPTION
       Use this function to reset and unlock a user's AD account
    .EXAMPLE
       Reset-UsersPassword -Users tallen -Domain domain
    .EXAMPLE
       $users = Get-Aduser -filter {Name -like "s_test_account*"} -server domain.dev
       Reset-UsersPassword -Users $users -Domain domain.dev
    #>
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    Param
    (
        # Usernames
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string[]]$SamAccountName,

        # Domain
        [Parameter(Mandatory=$true)]
        [string]$Domain
    )

    Begin
    {
        [Reflection.Assembly]::LoadWithPartialName(“System.Web”) | Out-Null
        #add active directory module
        if (!(Get-Module -Name ActiveDirectory -ErrorAction SilentlyContinue)) {
            try {
                Import-Module -Name ActiveDirectory -ErrorAction Stop
            }
            catch {
                $errorMessage = $_.Exception.Message
            }
        }
    }
    Process
    {
        if($PSCmdlet.ShouldProcess($samAccountName)) {
            if ($errorMessage) {
                $output = [PSCustomObject] @{
                        Output = $errorMessage
                        Success = $false
                }
                Write-Output $output | ConvertTo-Json
                continue
            }
            foreach ($user in $samAccountName) {
                $adUser = Get-ADUser -Filter {SamAccountName -like $user} -Server $domain
                if (!($adUser)) {
                    $output =  [PSCustomObject] @{
                            Output = "Error: Could not find user (*$($user)*) in $($domain)."
                            Success = $false
                    }
                    Write-Output $output | ConvertTo-Json
                    continue
                }
                $password = [System.Web.Security.Membership]::GeneratePassword(20, 4)
                $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
                switch ($domain) {
                    ".dev" {$credential = (Get-Credential)}
                    ".local" {$credential = (Get-Credential)}
                    ".com" {$credential = (Get-Credential)}
                        default {$credential = (Get-Credential)}
                }
                try {
                    $adUser | Set-ADAccountPassword -NewPassword $securePassword -Reset -Credential $credential -Server $domain -ErrorAction Stop
                    $adUser | Unlock-ADAccount -Credential $credential -Server $domain -ErrorAction Stop
                    $output = [PSCustomObject] @{
                            Output = "Password for (*$($adUser.Name)*) in $($domain) was successfully reset to $($password)"
                            Success = $true
                    }
                }
                catch {
                    $output = [PSCustomObject] @{
                            Output = "Password was not reset for user: (*$($adUser.Name)*)."
                            Success = $false
                    }
                }
                Write-Output $output | ConvertTo-Json
            }
        }
    }
    End
    {        
    }
}
