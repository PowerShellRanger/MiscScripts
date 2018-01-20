function Get-Win10ProvisionedBloatware
{
     <#
    .Synopsis
        Get Bloatware from Windows 10
    .DESCRIPTION
        Use this function to get bloatware from a Windows 10 workstation.
    .EXAMPLE    
        Get-Win10ProvisionedBloatware -ApplicationToExclude store, calc, paint | select DisplayName
        
        Description
        -----------
        Get all Windows 10 Bloatware and exclude anything like store, calc, or .net. 
        The ApplicationToExclude parameter has an implied wildcard; therefore, adding a wildcard to your search string is not required.        

    .EXAMPLE
        $excludeApps = @('store' , 'calc')
        $excludeApps | Get-Win10ProvisionedBloatware | select DisplayName

        Description
        -----------
        Set $excludeApps to the applications you want to exclude for the cmdlet.

    .EXAMPLE
        Get-Win10ProvisionedBloatware -ApplicationToExclude store, calc | Remove-AppxProvisionedPackage -WhatIf        
    #>
    [CmdletBinding()]
    param
    (
        # Applications to Exclude
        [parameter(ValueFromPipeline)]        
        [string[]]$ApplicationToExclude
    )
    begin
    {   
        $appsToExclude = New-Object System.Collections.ArrayList
        $appxPackages = Get-AppxProvisionedPackage -Online -ErrorAction Stop
    }
    process
    {
        foreach ($excludeApp in $ApplicationToExclude) 
        {
            $appExists = ($appxPackages).where({ $_.DisplayName -like "*$excludeApp*" })
            
            if (-not $appExists) 
            {
                Write-Verbose "$excludeApp was not found."
                continue
            }
            Write-Verbose "$($appExists.DisplayName) was found. Adding to the list of apps to exclude."
            [void]$appsToExclude.Add($appExists)
        }
    }
    end
    {
        Write-Verbose "Return a list of apps that do not match the exclusions provided."
        ($appxPackages).where({ $appsToExclude.DisplayName -notcontains $_.DisplayName })
    }
}

function Get-Win10Bloatware
{
     <#
    .Synopsis
        Get Bloatware from Windows 10
    .DESCRIPTION
        Use this function to get bloatware from a Windows 10 workstation.
    .EXAMPLE    
        Get-Win10Bloatware -ApplicationToExclude store, calc, .net. | select Name
        
        Description
        -----------
        Get all Windows 10 Bloatware and exclude anything like store, calc, or .net. 
        The ApplicationToExclude parameter has an implied wildcard; therefore, adding a wildcard to your search string is not required.        

    .EXAMPLE
        $excludeApps = @('store' , 'calc')
        $excludeApps | Get-Win10Bloatware | select Name

        Description
        -----------
        Set $excludeApps to the applications you want to exclude for the cmdlet.

    .EXAMPLE
        Get-Win10Bloatware -ApplicationToExclude store, calc | Remove-AppxPackage -AllUsers -WhatIf        
    #>
    [CmdletBinding()]
    param
    (
        # Applications to Exclude
        [parameter(ValueFromPipeline)]        
        [string[]]$ApplicationToExclude
    )
    begin
    {   
        $appsToExclude = New-Object System.Collections.ArrayList
        $appxPackages = Get-AppxPackage -ErrorAction Stop
    }
    process
    {
        foreach ($excludeApp in $ApplicationToExclude) 
        {
            $appExists = ($appxPackages).where({ $_.Name -like "*$excludeApp*" })
            
            if (-not $appExists) 
            {
                Write-Verbose "$excludeApp was not found."
                continue
            }
            Write-Verbose "$($appExists.Name) was found. Adding $($appExists.Name) to the list of apps to exclude."
            [void]$appsToExclude.Add($appExists)
        }
    }
    end
    {
        Write-Verbose "Return a list of apps that do not match the exclusions provided."
        ($appxPackages).where({ $appsToExclude.Name -notcontains $_.Name })
    }
}

$excludeItems = 'Microsoft.Windows.CloudExperienceHost',
'Microsoft.AAD.BrokerPlugin',
'Microsoft.Windows.ShellExperienceHost',
'windows.immersivecontrolpanel',
'Microsoft.Windows.ContentDeliveryManager',
'Microsoft.VCLibs.140.00',
'Microsoft.VCLibs.140.00',
'Microsoft.XboxGameCallableUI',
'Windows.ContactSupport',
'Windows.MiracastView',
'EnvironmentsApp',
'HoloCamera',
'HoloItemPlayerApp',
'HoloShell',
'Microsoft.AccountsControl',
'Microsoft.BioEnrollment',
'Microsoft.CredDialogHost',
'E2A4F912-2574-4A75-9BB0-0D023378592B',
'Microsoft.LockApp',
'Microsoft.PPIProjection',
'Microsoft.Windows.Apprep.ChxApp',
'Microsoft.Windows.AssignedAccessLockApp',
'Microsoft.Windows.HolographicFirstRun',
'1527c705-839a-4832-9118-54d4Bd6a0c89',
'c5e2524a-ea46-4f67-841f-6a9465d9d515',
'CortanaListenUIApp',
'DesktopLearning',
'DesktopView',
'Microsoft.Windows.ModalSharePickerHost',
'Microsoft.Windows.OOBENetworkCaptivePortal',
'Microsoft.Windows.OOBENetworkConnectionFlow',
'Microsoft.Windows.ParentalControls',
'Windows.PrintDialog',
'Microsoft.Windows.WindowPicker',
'Microsoft.Windows.SecureAssessmentBrowser',
'Microsoft.Windows.SecondaryTileExperience',
'Microsoft.Windows.SecHealthUI',
'Microsoft.Windows.Cortana',
'store',
'calc',
'.net.',
'paint',
'edge'

$bloatwareApps = Get-Win10Bloatware -ApplicationToExclude $excludeItems -Verbose #store, calc, .net., paint, edge
$provisionedApps = Get-Win10ProvisionedBloatware -ApplicationToExclude store, calc, paint -Verbose

if ($bloatwareApps) 
{
    foreach ($app in $bloatwareApps) 
    {
        try 
        {
            Remove-AppxPackage -AllUsers -Package $app.PackageFullName -Confirm:$false -ErrorAction Stop
        }
        catch
        {
            Write-Warning "Could not remove $app.Name because Microsoft prevents you from removing this app."
        }
    }
}

if ($provisionedApps) 
{
    foreach ($provisionedApp in $provisionedApps) 
    {
        Remove-AppxProvisionedPackage -PackageName $provisionedApp.PackageName -Online
    }
}