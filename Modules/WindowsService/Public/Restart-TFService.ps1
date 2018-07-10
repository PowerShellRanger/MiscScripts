function Restart-TFService
{
    <#
    .Synopsis
        Restart a service on Think Finance servers.
    .DESCRIPTION
        Restart a service on Think Finance servers.
    .EXAMPLE
        glados Restart-Service --ComputerName crpwacitsdsc01 --Name WinRM
    .EXAMPLE
        !Restart-Service-Service --ComputerName crpwacitsdsc01 --Name *WinR*
    #>
    [PoshBot.BotCommand(CommandName = 'Restart-Service',
                        Permissions = 'Write'
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
        $session = New-TFPSSession -ComputerName $ComputerName
        if ($session.State -eq 'Opened') {
            try {
                $result = Invoke-Command -Session $session -ScriptBlock {
                    Restart-Service -Name $using:name -Force -Confirm:$false
                } -ErrorAction Stop
                New-PoshBotCardResponse -Type Normal -Text "[$Name] was successfully restarted on [$ComputerName]." -ThumbnailUrl $thumb.success                
            }
            catch {                
                New-PoshBotCardResponse -Type Error -Text $_.Exception.Message -Title 'Rut row' -ThumbnailUrl $thumb.rutrow                               
            }
            Disconnect-PSSession -Session $session -Confirm:$false | Out-Null
        }        
    }
    end
    {
    }
}