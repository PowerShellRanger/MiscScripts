### Example configuration referencing the new composite resource
Configuration aaaaaa {
    
    Import-DscResource -ModuleName tf_RemoteDesktopServices

    Node localhost {

        tf_RemoteDesktopServicesSessionHost bbbbbb {
            property = value
        }

    }
}