/*
*
*  
*
*/
import "NonFungibleToken"
import "MetadataViews"
import "ViewResolver"
import "FlowAgainstHumanity"

pub contract FAHGames: NonFungibleToken, ViewResolver {
    // Total supply of FAHGames in existence
    pub var totalSupply: UInt64

    // The event that is emitted when the contract is created
    pub event ContractInitialized()

    // The event that is emitted when an NFT is withdrawn from a Collection
    pub event Withdraw(id: UInt64, from: Address?)

    // The event that is emitted when an NFT is deposited to a Collection
    pub event Deposit(id: UInt64, to: Address?)

    // Storage and Public Paths
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath

    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64

        pub fun getViews(): [Type] {
            panic("TODO")
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            panic("TODO")
        }

        init() {
            self.id = self.uuid
        }
    }

    pub resource interface FAHGamesCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    }

    // The resource that will be holding the NFTs inside any account.
    // In order to be able to manage NFTs any account will need to create
    // an empty collection first
    //
    pub resource Collection: FAHGamesCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            panic("TODO")
        }

        pub fun deposit(token: @NonFungibleToken.NFT) {
            panic("TODO")
        }

        pub fun getIDs(): [UInt64] {
            panic("TODO")
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            panic("TODO")
        }

        pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            panic("TODO")
        }

        init() {
            self.ownedNFTs <- {}
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        panic("TODO")
    }

    init() {
        self.totalSupply = 0

        // Set the named paths
        self.CollectionStoragePath = /storage/FAHGamesCollection
        self.CollectionPublicPath = /public/FAHGamesCollection
    }
}