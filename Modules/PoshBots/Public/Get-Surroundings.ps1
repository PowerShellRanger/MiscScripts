function Get-Surroundings 
{
     <#
    .Synopsis
       Get PoshBot's surroundings
    .DESCRIPTION
       Use this function to get PoshBot's surroundings.
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
        [string]$GameName
    )
    begin
    {        
    }
    process
    {
        $baseUri = "http://powershell-rangers.azurewebsites.net/" 
        Invoke-RestMethod -Method Get -Uri "$baseUri/api/GetSurroundings/$GameName/?playerName=$PlayerName"
    }
    end
    {
    }
}