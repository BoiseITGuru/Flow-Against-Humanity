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

pub contract FAHCardDeck: NonFungibleToken, ViewResolver {
    // Total supply of FAHCardDeck in existence
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
    pub let CollectionPrivatePath: PrivatePath

    // Metadata struct for defining CardDecks
    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64
        pub let metadataId: String

        pub fun getMetadata(): &FlowAgainstHumanity.CardDeckMetadata{FlowAgainstHumanity.CardDeckMetadataPublic}? {
			return FlowAgainstHumanity.getCardDeckMetadata(self.metadataId)
		}

        pub fun createCardMetadata(_text: String, _type: FlowAgainstHumanity.CardType, _image: MetadataViews.IPFSFile, _thumbnail: MetadataViews.IPFSFile, _maxSupply: UInt64) {
            let metadataAdmin = FAHCardDeck.getCardDeckMetadataAdmin(self.metadataId) ?? panic("Card Deck Admin Not Found")
            metadataAdmin.createCardMetadata(_cardAuthor: self.owner!.address, _text: _text, _type: _type, _image: _image, _thumbnail: _thumbnail, _maxSupply: _maxSupply, _extra: {})
        }

        // mintCard mints a new FAHCard NFT and depsits
        // it in the recipients collection
        pub fun mintCard(metadataId: String, recipient: Address) {
            
        }

		init(_metadataId: String) {
            self.id = self.uuid
            self.metadataId = _metadataId
		}
	
        pub fun getViews(): [Type] {
            return [
				Type<MetadataViews.Display>(),
				Type<MetadataViews.ExternalURL>(),
				Type<MetadataViews.NFTCollectionData>(),
				Type<MetadataViews.Royalties>(),
				Type<MetadataViews.Serial>(),
                Type<MetadataViews.Traits>(),
				Type<MetadataViews.NFTView>()
			]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            let metadata = self.getMetadata() ?? panic("couldn't find Card Deck Metadata")
            switch view {
                case Type<MetadataViews.Display>():
					return MetadataViews.Display(
						name: "FAH Card Deck: ".concat(metadata.getName()),
						description: metadata.getDescription(),
						thumbnail: metadata.getThumbnail()
					)
                case Type<MetadataViews.ExternalURL>():
                    return MetadataViews.ExternalURL("https://fah.boiseitguru.dev/sets/".concat(self.metadataId))
                case Type<MetadataViews.NFTCollectionData>():
                    return MetadataViews.NFTCollectionData(
						storagePath: FAHCardDeck.CollectionStoragePath,
						publicPath: FAHCardDeck.CollectionPublicPath,
						providerPath: FAHCardDeck.CollectionPrivatePath,
						publicCollection: Type<&Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(),
						publicLinkedType: Type<&Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(),
						providerLinkedType: Type<&Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection, NonFungibleToken.Provider}>(),
						createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
								return <- FAHCardDeck.createEmptyCollection()
						})
					)
                case Type<MetadataViews.Royalties>():
                    let author = self.owner!.address
                    let profile = Profile.find(author)
                    let findName = profile.getFindName()
                    let authorName = profile.getName().concat(" (").concat(findName == "" ? author.toString() : findName).concat(")")
                    let authorVault = getAccount(author).getCapability<&{FungibleToken.Receiver}>(Profile.publicReceiverPath)

                    let royalties = [MetadataViews.Royalty(
                        receiver: authorVault,
                        cut: FlowAgainstHumanity.authorCardDeckRoyalties,
                        description: authorName.concat(" receives a ").concat((FlowAgainstHumanity.authorCardDeckRoyalties * 100.0).toString()).concat("% royalty from secondary sales for authoring this FAH Card Deck")
                    )]
                    
                    for royalty in FlowAgainstHumanity.globalCardDeckRoyalties {
                        royalties.append(royalty)
                    }
                case Type<MetadataViews.Serial>():
                    return MetadataViews.Serial(
                        self.id
                    )
                case Type<MetadataViews.Traits>():
					let traits = MetadataViews.Traits([
                        MetadataViews.Trait(name: "Number Questions", value: metadata.getQuestionCards().length, displayType: nil, rarity: nil),
                        MetadataViews.Trait(name: "Number Responses", value: metadata.getResponseCards().length, displayType: nil, rarity: nil),
                        MetadataViews.Trait(name: "Max Supply", value: metadata.getMaxSupply(), displayType: nil, rarity: nil),
                        MetadataViews.Trait(name: "In Circulation", value: metadata.getInCiculation(), displayType: nil, rarity: nil)
                    ])
                case Type<MetadataViews.NFTView>():
					return MetadataViews.NFTView(
						id: self.id,
						uuid: self.uuid,
						display: self.resolveView(Type<MetadataViews.Display>()) as! MetadataViews.Display?,
						externalURL: self.resolveView(Type<MetadataViews.ExternalURL>()) as! MetadataViews.ExternalURL?,
						collectionData: self.resolveView(Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?,
						collectionDisplay: self.resolveView(Type<MetadataViews.NFTCollectionDisplay>()) as! MetadataViews.NFTCollectionDisplay?,
						royalties: self.resolveView(Type<MetadataViews.Royalties>()) as! MetadataViews.Royalties?,
						traits: self.resolveView(Type<MetadataViews.Traits>()) as! MetadataViews.Traits?
					)
            }
            return nil
        }
    }

    // Defines the methods that are particular to this NFT contract collection
    //
    pub resource interface FAHCardDeckCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun getMetadataIds(): [String]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowCardDeck(metadataId: String): &FAHCardDeck.NFT? {
            post {
                (result == nil) || (result?.metadataId == metadataId):
                    "Cannot borrow FlowAgainstHumanity reference: the ID of the returned reference is incorrect"
            }
        }
    }

    pub resource Collection: FAHCardDeckCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        // dictionary of authored CardDecks
        pub let authoredSets: {String: UInt64}
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // TODO: Implement withdraw()
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            panic("TODO")
        }

        // TODO: Implement deposit()
        pub fun deposit(token: @NonFungibleToken.NFT) {
            panic("TODO")
        }

        // TODO: Implement getIDs()
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // TODO: Implement borrowNFT()
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            panic("TODO")
        }

        // TODO: Implement getMetadataIds()
        pub fun getMetadataIds(): [String] {
            panic("TODO")
        }

        // TODO: Implement borrowCardDeck()
        pub fun borrowCardDeck(metadataId: String): &FAHCardDeck.NFT? {
            panic("TODO")
        }

        // TODO: Implement borrowViewResolver()
        pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            panic("TODO")
        }

        pub fun createEmptyCardDeck(_name: String, _description: String, _image: MetadataViews.IPFSFile, _thumbnail: MetadataViews.IPFSFile) {
            let metadataId = FlowAgainstHumanity.createCardDeckMetadata(_name: _name, _description: _description, _image: _image, _thumbnail: _thumbnail, _extra: {})

            let cardDeck <- create NFT(_metadataId: metadataId)
            self.authoredSets[metadataId] = cardDeck.uuid
            self.ownedNFTs[cardDeck.uuid] <-! cardDeck

            FAHCardDeck.mapAuthorToCardDeck(author: self.owner!.address, metadataId: metadataId)
        }

        init () {
			self.authoredSets = {}
            self.ownedNFTs <- {}
		}

		destroy() {
			destroy self.ownedNFTs
		}
    }

    // Allows anyone to create a new empty CardDeckCollection
    //
    // @return a new CardDeckCollection resource
    //
    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    pub fun getCardDeckMetadata(_ metadataId: String): &FlowAgainstHumanity.CardDeckMetadata{FlowAgainstHumanity.CardDeckMetadataPublic}? {
		return FlowAgainstHumanity.getCardDeckMetadata(metadataId)
	}

    // Private function for creating FAHCard Metadata
    //
    // @return a FlowAgainstHumanity.CardDeckMetadataAdmin interface
    //
    access(contract) fun getCardDeckMetadataAdmin(_ metadataId: String): &FlowAgainstHumanity.CardDeckMetadata{FlowAgainstHumanity.CardDeckMetadataAdmin}? {
        return FlowAgainstHumanity.getCardDeckMetadataAdmin(metadataId)
    }

    access(contract) fun createCardDeckMetadata(_name: String, _description: String, _image: MetadataViews.IPFSFile, _thumbnail: MetadataViews.IPFSFile, _extra: {String: AnyStruct}): String {
        return FlowAgainstHumanity.createCardDeckMetadata(_name: _name, _description: _description, _image: _image, _thumbnail: _thumbnail, _extra: _extra)
    }

    access(contract) fun mapAuthorToCardDeck(author: Address, metadataId: String) {
        FlowAgainstHumanity.mapAuthorToCardDeck(author: author, metadataId: metadataId)
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
        self.totalSupply = 0

        // Set the named paths
        self.CollectionStoragePath = /storage/FAHCardDeckCollection
        self.CollectionPublicPath = /public/FAHCardDeckCollection
        self.CollectionPrivatePath = /private/FAHCardDeckCollection
    }
}