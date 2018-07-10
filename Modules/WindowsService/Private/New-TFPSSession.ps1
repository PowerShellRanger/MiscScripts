function New-TFPSSession
{
    <#
    .Synopsis
        Create a new PSSession to the list of computer names provide
    .DESCRIPTION
        Use this function to create a new PSSession to the list of computer names provide.
    .EXAMPLE

    .EXAMPLE
       
    #>
    [CmdletBinding()]
    Param
    (
        # ComputerName
        [Parameter(Mandatory)]
        [string[]]$ComputerName#,

        # Credential variable
        #[Parameter(Mandatory)]
        #[PSCredential]$Credential
    )
    begin
    {
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
        foreach ($computer in $ComputerName) {
            if(-not (Test-Connection -ComputerName $computer -Count 3 -Quiet -ErrorAction SilentlyContinue)) {
                Write-Warning "$($computer) is offline." 
                New-PoshBotCardResponse -Type Warning -Text "[$computer] is offline. :(" -Title 'Rut row' -ThumbnailUrl $thumb.rutrow               
                continue
            }
            try {
                Write-Verbose "Establishing a new session to $($computer)."
                $session = New-PSSession -ComputerName $computer <#-Credential $Credential#> -ErrorAction Stop
                Write-Output $session
            }
            catch {
                Write-Verbose "Failed to establish a new session to $($computer)."                                
                New-PoshBotCardResponse -Type Error -Text $_.Exception.Message -Title 'Rut row' -ThumbnailUrl $thumb.rutrow
            }
        }                          
    }
    end
    {
    }
}