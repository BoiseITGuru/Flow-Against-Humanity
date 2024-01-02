/*
*
*  
*
*/
import "FungibleToken"
import "NonFungibleToken"
import "MetadataViews"
import "ViewResolver"
import "FlowAgainstHumanity"
import "Profile"

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

    // The core resource that represents a Non Fungible Token.
    // New instances will be created using the NFTMinter resource
    // and stored in the Collection resource
    //
    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        // The unique ID that each FAHCard has
        pub let id: UInt64

        // FAHCard fields
        pub let text: String
        pub let type: FlowAgainstHumanity.CardType
        pub let metadataId: String

        pub fun getMetadata(): &FlowAgainstHumanity.CardMetadata{FlowAgainstHumanity.CardMetadataPublic}? {
			return FAHCards.getCardMetadata(self.metadataId)
		}

        init(_ cardMetadataId: String) {
            let metadata = FAHCards.getCardMetadata(cardMetadataId) ?? panic("NFT metadata not found")

            self.id = metadata.getInCirculation()
            self.text = metadata.getText()
            self.type = metadata.getCardType()
            self.metadataId = cardMetadataId
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
            let metadata = self.getMetadata() ?? panic("NFT metadata not found")
            var name: String = ""
            var description: String = ""
            switch self.type {
                case FlowAgainstHumanity.CardType.QUESTION:
                    name = "FAH Question Card"
                    description = "A standard question card for the card game Flow Against Humanity"
                case FlowAgainstHumanity.CardType.QUESTION2:
                    name = "FAH Pick 2 Question Card"
                    description = "A pick 2 question card for the card game Flow Against Humanity"
                case FlowAgainstHumanity.CardType.QUESTION3:
                    name = "FAH Pick 3 Question Card"
                    description = "A pick 3 question card for the card game Flow Against Humanity"
                case FlowAgainstHumanity.CardType.ANSWER:
                    name = "FAH Response Card"
                    description = "A standard response card for the card game Flow Against Humanity"
            }
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: name,
                        description: description,
                        thumbnail: metadata.getThumbnail()
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
                    let author = metadata.getCardDeckAuthor()
                    let profile = Profile.find(author)
                    let findName = profile.getFindName()
                    let authorName = profile.getName().concat(" (").concat(findName == "" ? author.toString() : findName).concat(")")
                    let authorVault = getAccount(author).getCapability<&{FungibleToken.Receiver}>(Profile.publicReceiverPath)

                    let royalties: [MetadataViews.Royalty] = []

                    royalties.append(MetadataViews.Royalty(
                        receiver: authorVault,
                        cut: FlowAgainstHumanity.authorCardDeckRoyalties,
                        description: authorName.concat(" receives a ").concat((FlowAgainstHumanity.authorCardDeckRoyalties * 100.0).toString()).concat("% royalty from secondary sales for authoring this FAH Card Set")
                    ))

                    for royalty in FlowAgainstHumanity.globalCardRoyalties {
                        royalties.append(royalty)
                    }

                    return MetadataViews.Royalties(royalties)
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
                // case Type<MetadataViews.Traits>():
                //     // exclude mintedTime and foo to show other uses of Traits
                //     let excludedTraits = ["mintedTime", "foo"]
                //     let traitsView = MetadataViews.dictToTraits(dict: self.metadata, excludedNames: excludedTraits)

                //     // mintedTime is a unix timestamp, we should mark it with a displayType so platforms know how to show it.
                //     let mintedTimeTrait = MetadataViews.Trait(name: "mintedTime", value: self.metadata["mintedTime"]!, displayType: "Date", rarity: nil)
                //     traitsView.addTrait(mintedTimeTrait)

                //     // foo is a trait with its own rarity
                //     let fooTraitRarity = MetadataViews.Rarity(score: 10.0, max: 100.0, description: "Common")
                //     let fooTrait = MetadataViews.Trait(name: "foo", value: self.metadata["foo"], displayType: nil, rarity: fooTraitRarity)
                //     traitsView.addTrait(fooTrait)

                //     return traitsView

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

    pub fun getCardMetadata(_ metadataId: String): &FlowAgainstHumanity.CardMetadata{FlowAgainstHumanity.CardMetadataPublic}? {
		return FlowAgainstHumanity.getCardMetadata(metadataId)
	}

    // Get Admin interface to CardMetadata
    access(contract) fun getCardMetadataAdmin(_ metadataId: String): &FlowAgainstHumanity.CardMetadata{FlowAgainstHumanity.CardMetadataAdmin}? {
        return FlowAgainstHumanity.getCardMetadataAdmin(metadataId)
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

        // create a public capability for the collection
        self.account.link<&FAHCards.Collection{NonFungibleToken.CollectionPublic, FAHCards.FAHCardsCollectionPublic, MetadataViews.ResolverCollection}>(
            self.CollectionPublicPath,
            target: self.CollectionStoragePath
        )

        emit ContractInitialized()
    }
}