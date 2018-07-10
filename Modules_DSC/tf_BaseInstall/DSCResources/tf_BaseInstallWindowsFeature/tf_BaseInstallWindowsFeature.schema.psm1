configuration tf_BaseInstallWindowsFeature 
{
    param 
    (        
        # Install Windows Features
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Feature,

        # Present or Absent - defualt is present
        [parameter()]
        [ValidateSet('Present', 'Absent')]
        [string]$Ensure = 'Present',

        # Include Sub Features
        [parameter()]        
        [bool]$IncludeAllSubFeature = $false
    )    
        
    WindowsFeature $Feature
    {            
        Ensure               = $Ensure
        Name                 = $Feature
        IncludeAllSubFeature = $IncludeAllSubFeature
    }
}