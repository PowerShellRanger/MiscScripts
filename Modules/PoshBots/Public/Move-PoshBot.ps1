function Move-PoshBot
{
     <#
    .Synopsis
       Move PoshBot bots
    .DESCRIPTION
       Use this function to Move PoshBot bots up, down, right, or left.
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding()]
    Param
    (
        # PlayerName
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string]$PlayerName,

        # GameName
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string]$GameName,

        # Direction
        [Parameter()]
        [ValidateSet('Up','Down','Left','Right')]
        [string]$Direction

    )
    begin
    {        
    }
    process
    {
        $baseUri = "http://powershell-rangers.azurewebsites.net/"   
        if ($PSBoundParameters.ContainsKey('Direction')) {     
            switch ($Direction) {
                'Up' {
                    Write-Verbose "$PlayerName moves up"
                    Invoke-RestMethod -Method Get -Uri "$baseUri/api/MoveUp/$GameName/?playerName=$PlayerName"
                }
                'Down' {
                    Write-Verbose "$PlayerName moves down"
                    Invoke-RestMethod -Method Get -Uri "$baseUri/api/MoveDown/$GameName/?playerName=$PlayerName"
                }
                'Left' {
                    Write-Verbose "$PlayerName moves left"
                    Invoke-RestMethod -Method Get -Uri "$baseUri/api/MoveLeft/$GameName/?playerName=$PlayerName"
                }
                'Right' {
                    Write-Verbose "$PlayerName moves right"
                    Invoke-RestMethod -Method Get -Uri "$baseUri/api/MoveRight/$GameName/?playerName=$PlayerName"
                }
            }
        }
    }
    end
    {
    }
}