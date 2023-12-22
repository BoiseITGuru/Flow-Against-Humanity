/*
*
*  
*
*/

import NonFungibleToken from "./utility/NonFungibleToken.cdc"
import MetadataViews from "./utility/MetadataViews.cdc"
import ViewResolver from "./utility/ViewResolver.cdc"

pub contract FAHCards: NonFungibleToken, ViewResolver {
	// Total supply of FAHCards in existence
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
    pub let MinterStoragePath: StoragePath

    // Maps the hash of CardMetadata text & type to each
    // individual CardMetadata struct.
	access(contract) let cardMetadatas: {String: CardMetadata}

    // Map of the oringal owners/minters of a FAHCard
    access(contract) let orginalOwner: {Address: {UInt64: [UInt64]}}

    // FAHCard Types
    pub enum CardType: UInt8 {
        pub case QUESTION
        pub case QUESTION2
        pub case QUESTION3
        pub case ANSWER
    }

    // Metadata struct for defining FAHCards
    pub struct CardMetadata {
		pub let text: String
        pub let type: CardType
		pub let image: MetadataViews.IPFSFile
		pub let thumbnail: MetadataViews.IPFSFile
		pub let maxSupply: UInt64
        pub let inCirculation: UInt64
		pub let owners: {UInt64: Address}

        // Holder for extra/future metadata
        pub var extra: {String: AnyStruct}

		access(account) fun purchased(serial: UInt64, buyer: Address) {
			self.owners[serial] = buyer
		}

		init(_text: String, _type: CardType, _image: MetadataViews.IPFSFile, _thumbnail: MetadataViews.IPFSFile, _maxSupply: UInt64, _extra: {String: AnyStruct}) {
			self.text = _text
			self.type = _type
			self.image = _image
			self.thumbnail = _thumbnail
			self.maxSupply = _maxSupply
            self.extra = _extra

            self.inCirculation = 0
			self.owners = {}
		}
	}

    // The core resource that represents a Non Fungible Token.
    // New instances will be created using the NFTMinter resource
    // and stored in the Collection resource
    //
    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        // The unique ID that each FAHCard has
        pub let id: UInt64

        // FAHCard fields
        pub let text: String
        pub let type: CardType

        // Metadata fields
        pub let name: String
        pub let description: String
        pub let thumbnail: String
        access(self) let royalties: [MetadataViews.Royalty]
        access(self) let metadata: {String: AnyStruct}

        init(
            id: UInt64,
            text: String,
            type: CardType,
            thumbnail: String,
            royalties: [MetadataViews.Royalty],
            metadata: {String: AnyStruct},
        ) {
            self.id = id
            self.text = text
            self.type = type
            self.thumbnail = thumbnail
            self.royalties = royalties
            self.metadata = metadata

            var _name: String = ""
            var _description: String = ""
            switch type {
                case CardType.QUESTION:
                    _name = "FAH Question Card"
                    _description = "A standard question card for the card game Flow Against Humanity"
                case CardType.QUESTION2:
                    _name = "FAH Pick 2 Question Card"
                    _description = "A pick 2 question card for the card game Flow Against Humanity"
                case CardType.QUESTION3:
                    _name = "FAH Pick 3 Question Card"
                   _description = "A pick 3 question card for the card game Flow Against Humanity"
                case CardType.ANSWER:
                    _name = "FAH Response Card"
                    _description = "A standard response card for the card game Flow Against Humanity"
            }

            self.name = _name
            self.description = _description
        }

        // Function that returns all the Metadata Views implemented by a Non Fungible Token
        //
        // @return An array of Types defining the implemented views. This value will be used by
        //         developers to know which parameter to pass to the resolveView() method.
        //
        pub fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Royalties>(),
                Type<MetadataViews.Editions>(),
                Type<MetadataViews.ExternalURL>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>(),
                Type<MetadataViews.Serial>(),
                Type<MetadataViews.Traits>()
            ]
        }

        // Function that resolves a metadata view for this token.
        //
        // @param view: The Type of the desired view.
        // @return A structure representing the requested view.
        //
        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.name,
                        description: self.description,
                        thumbnail: MetadataViews.HTTPFile(
                            url: self.thumbnail
                        )
                    )
                case Type<MetadataViews.Editions>():
                    // There is no max number of NFTs that can be minted from this contract
                    // so the max edition field value is set to nil
                    let editionInfo = MetadataViews.Edition(name: "Example NFT Edition", number: self.id, max: nil)
                    let editionList: [MetadataViews.Edition] = [editionInfo]
                    return MetadataViews.Editions(
                        editionList
                    )
                case Type<MetadataViews.Serial>():
                    return MetadataViews.Serial(
                        self.id
                    )
                case Type<MetadataViews.Royalties>():
                    return MetadataViews.Royalties(
                        self.royalties
                    )
                case Type<MetadataViews.ExternalURL>():
                    return MetadataViews.ExternalURL("https://example-nft.onflow.org/".concat(self.id.toString()))
                case Type<MetadataViews.NFTCollectionData>():
                    return MetadataViews.NFTCollectionData(
                        storagePath: FAHCards.CollectionStoragePath,
                        publicPath: FAHCards.CollectionPublicPath,
                        providerPath: /private/FAHCardsCollection,
                        publicCollection: Type<&FAHCards.Collection{FAHCards.FAHCardsCollectionPublic}>(),
                        publicLinkedType: Type<&FAHCards.Collection{FAHCards.FAHCardsCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(),
                        providerLinkedType: Type<&FAHCards.Collection{FAHCards.FAHCardsCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Provider,MetadataViews.ResolverCollection}>(),
                        createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
                            return <-FAHCards.createEmptyCollection()
                        })
                    )
                case Type<MetadataViews.NFTCollectionDisplay>():
                    let media = MetadataViews.Media(
                        file: MetadataViews.HTTPFile(
                            url: "https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg"
                        ),
                        mediaType: "image/svg+xml"
                    )
                    return MetadataViews.NFTCollectionDisplay(
                        name: "The Example Collection",
                        description: "This collection is used as an example to help you develop your next Flow NFT.",
                        externalURL: MetadataViews.ExternalURL("https://example-nft.onflow.org"),
                        squareImage: media,
                        bannerImage: media,
                        socials: {
                            "twitter": MetadataViews.ExternalURL("https://twitter.com/flow_blockchain")
                        }
                    )
                case Type<MetadataViews.Traits>():
                    // exclude mintedTime and foo to show other uses of Traits
                    let excludedTraits = ["mintedTime", "foo"]
                    let traitsView = MetadataViews.dictToTraits(dict: self.metadata, excludedNames: excludedTraits)

                    // mintedTime is a unix timestamp, we should mark it with a displayType so platforms know how to show it.
                    let mintedTimeTrait = MetadataViews.Trait(name: "mintedTime", value: self.metadata["mintedTime"]!, displayType: "Date", rarity: nil)
                    traitsView.addTrait(mintedTimeTrait)

                    // foo is a trait with its own rarity
                    let fooTraitRarity = MetadataViews.Rarity(score: 10.0, max: 100.0, description: "Common")
                    let fooTrait = MetadataViews.Trait(name: "foo", value: self.metadata["foo"], displayType: nil, rarity: fooTraitRarity)
                    traitsView.addTrait(fooTrait)

                    return traitsView

            }
            return nil
        }
    }

    // Defines the methods that are particular to this NFT contract collection
    //
    pub resource interface FAHCardsCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowFAHCards(id: UInt64): &FAHCards.NFT? {
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow FAHCards reference: the ID of the returned reference is incorrect"
            }
        }
    }

    // The resource that will be holding the NFTs inside any account.
    // In order to be able to manage NFTs any account will need to create
    // an empty collection first
    //
    pub resource Collection: FAHCardsCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }

        // Removes an NFT from the collection and moves it to the caller
        //
        // @param withdrawID: The ID of the NFT that wants to be withdrawn
        // @return The NFT resource that has been taken out of the collection
        //
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // Adds an NFT to the collections dictionary and adds the ID to the id array
        //
        // @param token: The NFT resource to be included in the collection
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @FAHCards.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // Helper method for getting the collection IDs
        //
        // @return An array containing the IDs of the NFTs in the collection
        //
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // Gets a reference to an NFT in the collection so that
        // the caller can read its metadata and call its methods
        //
        // @param id: The ID of the wanted NFT
        // @return A reference to the wanted NFT resource
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        // Gets a reference to an NFT in the collection so that
        // the caller can read its metadata and call its methods
        //
        // @param id: The ID of the wanted NFT
        // @return A reference to the wanted NFT resource
        //
        pub fun borrowFAHCards(id: UInt64): &FAHCards.NFT? {
            if self.ownedNFTs[id] != nil {
                // Create an authorized reference to allow downcasting
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &FAHCards.NFT
            }

            return nil
        }

        // Gets a reference to the NFT only conforming to the `{MetadataViews.Resolver}`
        // interface so that the caller can retrieve the views that the NFT
        // is implementing and resolve them
        //
        // @param id: The ID of the wanted NFT
        // @return The resource reference conforming to the Resolver interface
        //
        pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            let nft = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
            let FAHCards = nft as! &FAHCards.NFT
            return FAHCards
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    // Allows anyone to create a new empty collection
    //
    // @return The new Collection resource
    //
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
    pub resource NFTMinter {

        // Mints a new NFT with a new ID and deposit it in the
        // recipients collection using their collection reference
        //
        // @param recipient: A capability to the collection where the new NFT will be deposited
        // @param name: The name for the NFT metadata
        // @param description: The description for the NFT metadata
        // @param thumbnail: The thumbnail for the NFT metadata
        // @param royalties: An array of Royalty structs, see MetadataViews docs
        //
        pub fun mintNFT(
            recipient: &{NonFungibleToken.CollectionPublic},
            text: String,
            type: CardType,
            thumbnail: String,
            royalties: [MetadataViews.Royalty]
        ) {
            let metadata: {String: AnyStruct} = {}
            let currentBlock = getCurrentBlock()
            metadata["mintedBlock"] = currentBlock.height
            metadata["mintedTime"] = currentBlock.timestamp
            metadata["minter"] = recipient.owner!.address

            // FAHCard Metadata
            metadata["foo"] = "bar"

            // create a new NFT
            var newNFT <- create NFT(
                id: FAHCards.totalSupply,
                text: text,
                type: type,
                thumbnail: thumbnail,
                royalties: royalties,
                metadata: metadata,
            )

            // deposit it in the recipient's account using their reference
            recipient.deposit(token: <-newNFT)

            FAHCards.totalSupply = FAHCards.totalSupply + 1
        }
    }

    // Function that resolves a metadata view for this contract.
    //
    // @param view: The Type of the desired view.
    // @return A structure representing the requested view.
    //
    pub fun resolveView(_ view: Type): AnyStruct? {
        switch view {
            case Type<MetadataViews.NFTCollectionData>():
                return MetadataViews.NFTCollectionData(
                    storagePath: FAHCards.CollectionStoragePath,
                    publicPath: FAHCards.CollectionPublicPath,
                    providerPath: /private/FAHCardsCollection,
                    publicCollection: Type<&FAHCards.Collection{FAHCards.FAHCardsCollectionPublic}>(),
                    publicLinkedType: Type<&FAHCards.Collection{FAHCards.FAHCardsCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(),
                    providerLinkedType: Type<&FAHCards.Collection{FAHCards.FAHCardsCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Provider,MetadataViews.ResolverCollection}>(),
                    createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
                        return <-FAHCards.createEmptyCollection()
                    })
                )
            case Type<MetadataViews.NFTCollectionDisplay>():
                let media = MetadataViews.Media(
                    file: MetadataViews.HTTPFile(
                        url: "https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg"
                    ),
                    mediaType: "image/svg+xml"
                )
                return MetadataViews.NFTCollectionDisplay(
                    name: "The Example Collection",
                    description: "This collection is used as an example to help you develop your next Flow NFT.",
                    externalURL: MetadataViews.ExternalURL("https://example-nft.onflow.org"),
                    squareImage: media,
                    bannerImage: media,
                    socials: {
                        "twitter": MetadataViews.ExternalURL("https://twitter.com/flow_blockchain")
                    }
                )
        }
        return nil
    }

    // Function that returns all the Metadata Views implemented by a Non Fungible Token
    //
    // @return An array of Types defining the implemented views. This value will be used by
    //         developers to know which parameter to pass to the resolveView() method.
    //
    pub fun getViews(): [Type] {
        return [
            Type<MetadataViews.NFTCollectionData>(),
            Type<MetadataViews.NFTCollectionDisplay>()
        ]
    }

    init() {
        // Initialize contract information
        self.totalSupply = 0

        // Set the named paths
        self.CollectionStoragePath = /storage/FAHCardsCollection
        self.CollectionPublicPath = /public/FAHCardsCollection
        self.MinterStoragePath = /storage/FAHCardsMinter

        // Set empty dicts/arrays
        self.cardMetadatas = {}
        self.orginalOwner = {}

        // Create a Collection resource and save it to storage
        let collection <- create Collection()
        self.account.save(<-collection, to: self.CollectionStoragePath)

        // create a public capability for the collection
        self.account.link<&FAHCards.Collection{NonFungibleToken.CollectionPublic, FAHCards.FAHCardsCollectionPublic, MetadataViews.ResolverCollection}>(
            self.CollectionPublicPath,
            target: self.CollectionStoragePath
        )

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
    }
}