### Example configuration referencing the new composite resource
Configuration aaaaaa {
    
    Import-DscResource -ModuleName tf_BaseInstall

    Node localhost {

        tf_BaseInstallWindowsFeature bbbbbb {
            property = value
        }

    }
}