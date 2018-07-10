### Example configuration referencing the new composite resource
Configuration aaaaaa {
    
    Import-DscResource -ModuleName tf_Chocolatey

    Node localhost {

        tf_ChocoPackageInstaller bbbbbb {
            property = value
        }

    }
}