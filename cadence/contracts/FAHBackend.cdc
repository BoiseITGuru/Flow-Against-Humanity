/*
*
*  
*
*/
import "MetadataViews"
import "ViewResolver"
import "FlowAgainstHumanity"

pub contract FAHBackend: ViewResolver {
    // Paths
    pub let BackendStoragePath: StoragePath

    // Events
    pub event BackendCreated(addr: Address)

    pub resource Backend {
        pub fun getCardMetadataAdmin(_ metadataId: String): &FlowAgainstHumanity.CardMetadata{FlowAgainstHumanity.CardMetadataAdmin}? {
            return FlowAgainstHumanity.getCardMetadataAdmin(metadataId)
        }

        pub fun getCardDeckMetadataAdmin(_ metadataId: String): &FlowAgainstHumanity.CardDeckMetadata{FlowAgainstHumanity.CardDeckMetadataAdmin}? {
            return FlowAgainstHumanity.getCardDeckMetadataAdmin(metadataId)
        }
        
        init() {

        }
    }

    access(account) fun createBackend(): @Backend {
        return <- create Backend()
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
        self.BackendStoragePath = /storage/FAHBackend
    }
}