configuration tf_FileServerDFSN
{
    param 
    (
        # NameSpace to create
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Namespace,

        # ComputerName
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName,

        # ShareName
        #[parameter(Mandatory)]
        #[ValidateNotNullOrEmpty()]
        #[string[]]$ShareName,

        # Credential 
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential
    )

    Import-DscResource -ModuleName xDFS
    Import-DscResource -ModuleName xSmbShare
    
    # Create directories in C:\DFSRoots of Namespace
    foreach ($name in $Namespace) 
    {
        $dir = $name.Split('\')[-1]
        File "$($dir)_folder" 
        {
            Ensure          = 'Present'
            Type            = 'Directory'
            DestinationPath = "C:\DFSRoots\$dir"
        }
    }
    
    # Share directories
    foreach ($name in $Namespace) 
    {
        $dir = $name.Split('\')[-1]
        xSmbShare "$($dir)_share" 
        {
            Ensure                = 'Present'
            Name                  = $dir
            Path                  = "C:\DFSRoots\$dir"
            DependsOn             = "[File]$($dir)_folder"
        }
    }
    # Configure the NameSpace roots
    foreach ($name in $Namespace)
    {
        $targetPath = $name.Split('\')[-1]
        xDFSNamespaceRoot "$($name)_namespaceroot" 
        {
            Path                         = $name
            TargetPath                   = "\\$ComputerName\$targetPath"
            Ensure                       = 'Present'
            Type                         = 'DomainV2'
            EnableTargetFailback	     = $true
            EnableAccessBasedEnumeration = $true
            PsDscRunAsCredential         = $Credential
            DependsOn                    = "[xSmbShare]$($dir)_share"
        }
    }
    <#
    # Configure the NameSpace Folders
    foreach ($share in $ShareName) {        
        xDFSNamespaceFolder "$computer\$share" {
            Path                 = "$NameSpace\$share"
            TargetPath           = "\\$ComputerName\$share"
            Ensure               = 'Present'            
            TimeToLiveSec        = 300
            PsDscRunAsCredential = $Credential
            DependsOn            = '[WindowsFeature]FS-DFS-Namespace'
        }        
    } 
    #>       
}