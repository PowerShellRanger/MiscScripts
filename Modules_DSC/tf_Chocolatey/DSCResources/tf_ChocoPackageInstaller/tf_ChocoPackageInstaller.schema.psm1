configuration tf_ChocoPackageInstaller 
{
    param 
    (        
        # What packages need to be installed?
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Package,

        # What version packages need to be installed?
        [parameter()]        
        [string]$Version,
        
        # Present or Absent - defualt is present
        [parameter()]
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present',

        # Where would you like the package installed from?
        [parameter()]        
        [string]$Source = 'ThinkChoco'
    )

    Import-DscResource -ModuleName cChoco    
    
    # Install selected Packages from NuGet repo  
    if ([string]::IsNullOrEmpty($PSBoundParameters['Version']))
    {    
        cChocoPackageInstaller "install_$Package"
        {            
            Name      = $Package            
            Ensure    = $Ensure
            Source    = $Source                
        }        
    }    
    else
    {
        cChocoPackageInstaller "install_$Package"
        {            
            Name      = $Package
            Version   = $Version 
            Ensure    = $Ensure
            Source    = $Source                
        }
    }  
}