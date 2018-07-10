configuration tf_BaseInstallChocolatey 
{
    param 
    (
        # Install directory for Choco
        [parameter()]        
        [string]$InstallDirectory = "$env:SystemDrive\ProgramData\Chocolatey",

        # Name for source location choco will install packages from
        [parameter()]        
        [string]$PackageSourceName = 'ThinkChoco',

        # Source location for choco to install packages
        [parameter()]        
        [string]$PackageSource = 'https://chocolatey.think.local:443/chocolatey',

        # Present or Absent - defualt is present
        [parameter()]
        [ValidateSet('Present', 'Absent')]
        [string]$Ensure = 'Present',

        # Source location for offline install of Chocolatey
        [parameter()]        
        [ValidateScript( {
            if (Test-Path $_) 
            {
                Write-Verbose "Validating $_ is a valid path."
                $true
            }
            else 
            {
                throw "$_ is not a valid path. Please provide a valid path."
            }
        })]
        [string]$LocalChocolateyPackageFilePath = '\\chocolatey.think.local\Repo\Chocolatey\chocolatey.0.10.8.nupkg'
    )

    Import-DscResource -ModuleName cChoco

    # Install Chocolatey
    Script "Install_Chocolatey" 
    {
        GetScript  = 
        {
            $env:ChocolateyInstall = [Environment]::GetEnvironmentVariable('ChocolateyInstall', 'Machine')
            return @{ Result = [string]$env:ChocolateyInstall }                
        }
        TestScript = 
        {
            function Test-Command
            {
                param 
                (
                    [string]$Command = 'choco'
                )
                Write-Verbose "Test-Command $Command"
                if (Get-Command -Name $Command -ErrorAction SilentlyContinue) 
                {
                    Write-Verbose "$Command exists"
                    return $true
                } 
                else 
                {
                    Write-Verbose "$Command does NOT exist"
                    return $false
                }
            }
            function Test-ChocoInstalled
            {
                Write-Verbose 'Test-ChocoInstalled'
                $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
            
                Write-Verbose "Env:Path contains: $env:Path"
                if (Test-Command -Command choco)
                {
                    Write-Verbose 'YES - Choco is Installed'
                    return $true
                }
                else
                {
                    Write-Verbose "NO - Choco is not Installed"
                    return $false
                }                        
            } 
            Write-Verbose 'Test-TargetResource'
            if (-not (Test-ChocoInstalled))
            {
                Write-Verbose 'Choco is not installed, calling set'
                return $false
            }
        
            ##Test to see if the Install Directory is correct.
            $env:ChocolateyInstall = [Environment]::GetEnvironmentVariable('ChocolateyInstall', 'Machine')
            if (-not ($InstallDirectory -eq $env:ChocolateyInstall))
            {
                Write-Verbose "Choco should be installed in $using:InstallDirectory, but is installed to $env:ChocolateyInstall. Calling SetScript"
                return $false
            }        
            return $true               
        }
        SetScript  =
        {
            #$env:ChocolateyInstall = "$($env:SystemDrive)\ProgramData\Chocolatey"
            #$env:Path += ";$ChocoInstallPath"
            
            function Install-LocalChocolateyPackage 
            {
                [CmdletBinding()]
                param 
                (
                    # Path to Choco package
                    [parameter(Mandatory)]
                    [ValidateNotNullOrEmpty()]
                    [ValidateScript( {
                        if (Test-Path $_) 
                        {
                            Write-Verbose "Validating $_ is a valid path."
                            $true
                        }
                        else 
                        {
                            throw "$_ is not a valid path. Please provide a valid path."
                        }
                    })]
                    [string]$ChocolateyPackageFilePath
                )
                
                if ($env:TEMP -eq $null) 
                {
                    $env:TEMP = Join-Path $env:SystemDrive 'temp'
                }
                $chocoTempDir = Join-Path $env:TEMP "chocolatey"
                $tempDir = Join-Path $chocoTempDir "chocInstall"

                if (-not [System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir)}
                
                $file = Join-Path $tempDir "chocolatey.zip"
                Copy-Item $ChocolateyPackageFilePath $file -Force
                
                # unzip the package
                Write-Verbose "Extracting $file to $tempDir..."                
                if ($PSVersionTable.PSVersion.Major -lt 5) 
                {
                    try 
                    {
                        $shellApplication = new-object -com shell.application
                        $zipPackage = $shellApplication.NameSpace($file)
                        $destinationFolder = $shellApplication.NameSpace($tempDir)
                        $destinationFolder.CopyHere($zipPackage.Items(), 0x10)
                    } 
                    catch 
                    {
                        throw "Unable to unzip package using built-in compression. Set `$env:chocolateyUseWindowsCompression = 'false' and call install again to use 7zip to unzip. Error: `n $_"
                    }
                } 
                else 
                {
                    Expand-Archive -Path "$file" -DestinationPath "$tempDir" -Force
                }                  
                
                # Call chocolatey install
                Write-Verbose "Installing chocolatey on this machine"
                $toolsFolder = Join-Path $tempDir "tools"
                $chocoInstallPS1 = Join-Path $toolsFolder "chocolateyInstall.ps1"
                
                & $chocoInstallPS1
                
                Write-Verbose 'Ensuring chocolatey commands are on the path'
                $chocoInstallVariableName = "ChocolateyInstall"
                $chocoPath = [Environment]::GetEnvironmentVariable($chocoInstallVariableName)
                
                if ($chocoPath -eq $null -or $chocoPath -eq '') 
                {
                    $chocoPath = 'C:\ProgramData\Chocolatey'
                }
                
                $chocoExePath = Join-Path $chocoPath 'bin'
                
                if ($($env:Path).ToLower().Contains($($chocoExePath).ToLower()) -eq $false) 
                {
                    $env:Path = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine);
                }
            }
                                        
            # Install Chocolatey
            Install-LocalChocolateyPackage -ChocolateyPackageFilePath $using:LocalChocolateyPackageFilePath                
        }
    }    

    cChocoSource 'add_$PackageSource' 
    {
        Name      = $PackageSourceName
        Source    = $PackageSource
        Ensure    = $Ensure
        DependsOn = "[Script]Install_Chocolatey"
    }
    cChocoSource 'remove_DefaultPackageSource' 
    {
        Name      = 'chocolatey'
        Source    = 'https://chocolatey.org/api/v2/'
        Ensure    = 'Absent'
        DependsOn = "[Script]Install_Chocolatey"
    }
}
