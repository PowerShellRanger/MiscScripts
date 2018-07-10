function Start-Terraform
{
    <#
    .Synopsis
        Get a service on Think Finance servers.
    .DESCRIPTION
        Get a service on Think Finance servers.
    .EXAMPLE
        glados Get-Service --ComputerName crpwacitsdsc01 --Name WinRM
    .EXAMPLE
        !Get-Service --ComputerName crpwacitsdsc01 --Name *WinR*
    #>
    [PoshBot.BotCommand(CommandName = 'terraform',
                        Permissions = 'Write'
                        )]  
    [CmdletBinding()]
    param
    (
        # ComputerName
        [Parameter(Mandatory)]
        [ValidateSet("apply","plan","destroy")]
        [string]$Action,

        # Service
        [Parameter(Mandatory)]
        [string]$ResurceGroup
    )
    begin
    {
    }
    process
    {
        $respParams = @{
            Type = 'Normal'
        }
        cd D:\Terraform\$ResurceGroup
        .\New-EnvVars.ps1
        $terraformResult = (& terraform.exe $Action)
        #$respParams.text = ($terraformResult | Out-String)
        New-PoshBotCardResponse -Type Normal -Text ($terraformResult | Out-String)
        #New-PoshBotTextResponse -Text $respParams.text -AsCode
    }
    end
    {
    }
}
