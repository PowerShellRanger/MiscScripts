### Example configuration referencing the new composite resource
Configuration aaaaaa {
    
    Import-DscResource -ModuleName tf_FileServer

    Node localhost {

        cFileServerShare bbbbbb {
            property = value
        }

    }
}