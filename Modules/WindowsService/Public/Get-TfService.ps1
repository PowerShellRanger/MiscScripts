function Get-TFService
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
    [PoshBot.BotCommand(CommandName = 'Get-Service',
                        Permissions = 'Read'
                        )]
    [CmdletBinding()]
    param
    (
        # ComputerName
        [Parameter(Mandatory)]
        [string]$ComputerName = $env:COMPUTERNAME,

        # Service
        [Parameter(Mandatory)]
        [string]$Name
    )
    begin
    {
        # Thumbnails for card responses
        $thumb = @{
            rutrow = 'http://images4.fanpop.com/image/photos/17000000/Scooby-Doo-Where-Are-You-The-Original-Intro-scooby-doo-17020515-500-375.jpg'
            don = 'http://p1cdn05.thewrap.com/images/2015/06/don-draper-shrug.jpg'
            warning = 'http://hairmomentum.com/wp-content/uploads/2016/07/warning.png'
            error = 'https://cdn0.iconfinder.com/data/icons/shift-free/32/Error-128.png'
            success = 'https://www.streamsports.com/images/icon_green_check_256.png'
        }
    }
    process
    {
        $serviceInfo = Get-Service -ComputerName $ComputerName | where {$_.Name -like $Name}
        if ($serviceInfo) {
            $output = [PSCustomObject] @{
                Name = $serviceInfo.Name
                DisplayName = $serviceInfo.DisplayName
                Status = $serviceInfo.Status
                StartType = $serviceInfo.StartType
            }
            New-PoshBotCardResponse -Type Normal -Text ($output | Format-List | Out-String) -ThumbnailUrl $thumb.success                
            #Write-Output $output
        }
        else {
            New-PoshBotCardResponse -Type Warning -Text "Something went wrong while checking the [$name] service on [$ComputerName]." -ThumbnailUrl $thumb.warning               
        }
        
    }
    end
    {
    }
}