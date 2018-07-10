function Get-Score
{
     <#
    .Synopsis
       Get PoshBots game score
    .DESCRIPTION
       Use this function to get PoshBots game score.
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding()]
    Param
    (
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
        Invoke-RestMethod -Method Get -Uri "$BaseUri/api/GetScore/$GameName"
    }
    end
    {
    }
}