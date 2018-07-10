### Example configuration referencing the new composite resource
Configuration aaaaaa {
    
    Import-DscResource -ModuleName tf_FileServer

    Node localhost {

        tf_FileServerDFSN bbbbbb {
            property = value
        }

    }
}