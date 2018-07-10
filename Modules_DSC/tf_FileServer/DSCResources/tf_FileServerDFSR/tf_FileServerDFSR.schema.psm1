configuration tf_FileServerDFSR
{
    param 
    (
        # NameSpace to create
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$NameSpace,

        # ComputerName
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,

        # ShareName
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ShareName,

        # DomainName
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainName,

        # ContentPath of Share
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ContentPath,

        # Credential 
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential,

        # MaxEnvelopeSizeKb
        [parameter()]
        [int]$MaxEnvelopeSizeKb = 10240
    )

    Import-DscResource -ModuleName xDFS    
    
    # Configure the NameSpace Folders
    foreach ($share in $ShareName) {
        foreach ($computer in $ComputerName) {
            xDFSNamespaceFolder "$computer\$share" {
                Path                 = "$NameSpace\$share"
                TargetPath           = "\\$computer\$share"
                Ensure               = 'Present'            
                TimeToLiveSec        = 300
                PsDscRunAsCredential = $Credential                
            }
        }
    }
    
    # Configure the Replication Group
    foreach ($share in $ShareName) {
        xDFSReplicationGroup "$($share)_group" {
            GroupName            = $share
            DomainName           = $DomainName
            Description          = $share
            Ensure               = 'Present'
            Members              = $ComputerName
            Folders              = $share
            Topology             = 'Fullmesh'
            PSDSCRunAsCredential = $Credential            
        }
    }

    # Configure the Replication Group Folder
    foreach ($share in $ShareName) {
        xDFSReplicationGroupFolder "$($share)_folder" {
            GroupName            = $share
            DomainName           = $DomainName
            FolderName           = $share
            Description          = "DFS Share for $share."
            PSDSCRunAsCredential = $Credential            
            DependsOn            = "[xDFSReplicationGroup]$($share)_group"
        }
    }
    
    # Configure the Replication Group Membership
    foreach ($share in $ShareName) {
        $primaryMemberCounter = 0
        foreach ($computer in $ComputerName) {
            if ($primaryMemberCounter -eq 0) {
                $primaryMember = $true
            }
            else {
                $primaryMember = $false
            }
            xDFSReplicationGroupMembership "$($share)_member_$($computer)" {
                GroupName            = $share
                DomainName           = $DomainName
                FolderName           = $share
                ComputerName         = $computer
                ContentPath          = "$ContentPath\$share"
                PrimaryMember        = $primaryMember 
                PSDSCRunAsCredential = $Credential            
                DependsOn            = "[xDFSReplicationGroupFolder]$($share)_folder"
            }
            $primaryMemberCounter ++
        }        
    }

    # Set MaxEnvelopeSizekb    
    Script "MaxEnvelopeSizeKb" 
    {
        GetScript = 
        {
            $currentValue = Get-Item WSMan:\localhost\MaxEnvelopeSizekb | Select Value
            return @{ Result = [string]$currentValue.Value }                
        }
        TestScript = 
        {
            $state = $GetScript
            if ($state['Result'] -eq $using:MaxEnvelopeSizeKb) {
                Write-Verbose -Message ('{0} -eq {1}' -f $state['Result'], $using:MaxEnvelopeSizeKb)
                return $true
            }
            else {
                Write-Verbose -Message ('MaxEnvelopeSizeKb set to: {0}' -f $using:MaxEnvelopeSizeKb)
                return $false
            }                
        }
        SetScript =
        {
            Set-Item WSMan:\localhost\MaxEnvelopeSizekb -Value $using:MaxEnvelopeSizeKb -Credential $using:Credential
        }
    }    
}