configuration tf_RemoteDesktopServicesSessionHost
{
    param 
    (        
        # Ensure feautures are present
        [parameter()]        
        [string]$Ensure = 'Present'
    )    

    $features = @('RDS-RD-Server' , 'MSMQ-Server' , 'RSAT-AD-PowerShell' , 'RSAT-RDS-Licensing-Diagnosis-UI' , 'Telnet-Client')
    
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