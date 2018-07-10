configuration tf_RemoteDesktopServicesLicense
{
    param 
    (        
        # Ensure feautures are present
        [parameter()]        
        [string]$Ensure = 'Present'
    )    

    $features = @('RDS-Licensing' , 'RDS-Licensing-UI' , 'Telnet-Client')
    
    foreach ($feature in $features)
    {
        WindowsFeature $feature
        {            
            Ensure               = $Ensure
            Name                 = $feature
            IncludeAllSubFeature = $true
        }
    }
}
    