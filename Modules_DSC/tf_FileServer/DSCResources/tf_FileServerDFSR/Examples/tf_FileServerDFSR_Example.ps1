### Example configuration referencing the new composite resource
Configuration aaaaaa {
    
    Import-DscResource -ModuleName tf_FileServer

    Node localhost {

        tf_FileServerShare bbbbbb {
            property = value
        }

    }
}