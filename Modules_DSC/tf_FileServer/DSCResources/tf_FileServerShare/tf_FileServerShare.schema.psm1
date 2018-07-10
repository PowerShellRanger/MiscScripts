configuration tf_FileServerShare
{
    param 
    (
        # Name of Directory or Directories
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Directory,

        # Path of Directory or Directories
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,
        
        # FullAccess
        [parameter()]        
        [string]$FullAccess = 'Authenticated Users',
        
        # FolderEnumerationMode
        [parameter()]
        [ValidateSet('AccessBased','Unrestricted')]      
        [string]$FolderEnumerationMode = 'AccessBased'
    )

    Import-DscResource -ModuleName xSmbShare

    # Create directories passed in as params
    foreach ($dir in $Directory) {
        File "$($dir)_folder" {
            Ensure          = 'Present'
            Type            = 'Directory'
            DestinationPath = "$Path\$dir"
        }
    }
    
    # Share directories
    foreach ($dir in $Directory) {
        xSmbShare "$($dir)_share" {
            Ensure                = 'Present'
            Name                  = $dir
            Path                  = "$Path\$dir"
            FullAccess            = $FullAccess
            FolderEnumerationMode = $FolderEnumerationMode
            DependsOn             = "[File]$($dir)_folder"
        }
    }
}