/*
*
*  
*
*/
import "MetadataViews"
import "ViewResolver"
import "FlowAgainstHumanity"

pub contract FAHAdmin: ViewResolver {
    // Paths
    pub let AdminStoragePath: StoragePath
    pub let AdminPublicPath: PublicPath

    pub resource interface AdminPublic {
        
    }

    pub resource Admin {
        
    }

    access(account) fun createAdmin(): @Admin {
        return <- create Admin()
    }


    // TODO: Implement getViews()
    /// Function that returns all the Metadata Views implemented by the resolving contract
    ///
    /// @return An array of Types defining the implemented views. This value will be used by
    ///         developers to know which parameter to pass to the resolveView() method.
    ///
    pub fun getViews(): [Type] {
        return []
    }

    // TODO: Implement resolveView()
    /// Function that resolves a metadata view for this token.
    ///
    /// @param view: The Type of the desired view.
    /// @return A structure representing the requested view.
    ///
    pub fun resolveView(_ view: Type): AnyStruct? {
        return nil
    }

    init() {
        self.AdminStoragePath = /storage/FAHAdmin
        self.AdminPublicPath = /public/FAHAdmin

        let admin <- create Admin()
        self.account.save(<- admin, to: self.AdminStoragePath)
    }
}