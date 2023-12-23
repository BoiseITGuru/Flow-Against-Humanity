/*
*
*  
*
*/
import FungibleToken from "./utility/FungibleToken.cdc"
import NonFungibleToken from "./utility/NonFungibleToken.cdc"
import MetadataViews from "./utility/MetadataViews.cdc"
import ViewResolver from "./utility/ViewResolver.cdc"
import FAHCards from "./FAHCards.cdc"
import FAHRoyalties from "./FAHRoyalties.cdc"
import Profile from "./find/Profile.cdc"

pub contract FAHCardDecks: NonFungibleToken, ViewResolver {
    // Total supply of FAHCardDecks in existence
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

    // Maps the owner of a CardDeck to the hash of CardDeckMetadatas name then
    // to each individual CardDeckMetadatas struct.
    access(account) let cardDeckOwners: {Address: [String]}
	access(account) let cardDecks: {String: Address}

    // Metadata struct for defining CardDecks
    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64
        pub let metadataId: String

        pub fun getMetadata(): &FAHCards.CardDeckMetadata{FAHCards.CardDeckMetadataPublic}? {
			return FAHCards.getCardDeckMetadata(self.metadataId)
		}

        pub fun createCardMetadata(_text: String, _type: FAHCards.CardType, _image: MetadataViews.IPFSFile, _thumbnail: MetadataViews.IPFSFile, _maxSupply: UInt64) {
            let setMetadata = FAHCards.getCardDeckMetadataAdmin(self.metadataId) ?? panic("Could not get Card Deck Metadata")
            let cardMetadataId = FAHCards.createCardMetadata(_cardDeckId: self.metadataId, _cardDeckAuthor: self.owner!.address, _text: _text, _type: _type, _image: _image, _thumbnail: _thumbnail, _maxSupply: _maxSupply, _extra: {})
            setMetadata.appendCardMetadataId(cardMetadataId)
            setMetadata.incrementMaxSupply(cardMetadataId)
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
            let metadata = FAHCards.cardDeckMetadatas[self.metadataId] ?? panic("couldn't find Card Deck Metadata")
            switch view {
                case Type<MetadataViews.Display>():
					return MetadataViews.Display(
						name: "FAH Card Deck: ".concat(metadata.name),
						description: metadata.description,
						thumbnail: metadata.thumbnail
					)
                case Type<MetadataViews.ExternalURL>():
                    return MetadataViews.ExternalURL("https://fah.boiseitguru.dev/sets/".concat(self.metadataId))
                case Type<MetadataViews.NFTCollectionData>():
                    return MetadataViews.NFTCollectionData(
						storagePath: FAHCardDecks.CollectionStoragePath,
						publicPath: FAHCardDecks.CollectionPublicPath,
						providerPath: FAHCardDecks.CollectionPrivatePath,
						publicCollection: Type<&Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(),
						publicLinkedType: Type<&Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(),
						providerLinkedType: Type<&Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection, NonFungibleToken.Provider}>(),
						createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
								return <- FAHCardDecks.createEmptyCollection()
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
                        cut: FAHRoyalties.authorCardDeck,
                        description: authorName.concat(" receives a ").concat((FAHRoyalties.authorCardDeck * 100.0).toString()).concat("% royalty from secondary sales for authoring this FAH Card Deck")
                    )]
                    
                    for royalty in FAHRoyalties.globalCardDeck {
                        royalties.append(royalty)
                    }
                case Type<MetadataViews.Serial>():
                    return MetadataViews.Serial(
                        self.id
                    )
                case Type<MetadataViews.Traits>():
					let traits = MetadataViews.Traits([
                        MetadataViews.Trait(name: "Number Questions", value: metadata.questionCards.length, displayType: nil, rarity: nil),
                        MetadataViews.Trait(name: "Number Responses", value: metadata.responseCards.length, displayType: nil, rarity: nil),
                        MetadataViews.Trait(name: "Max Supply", value: metadata.maxSupply, displayType: nil, rarity: nil),
                        MetadataViews.Trait(name: "In Circulation", value: metadata.inCirculation, displayType: nil, rarity: nil)
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
        pub fun borrowCardDeck(metadataId: String): &FAHCardDecks.NFT? {
            post {
                (result == nil) || (result?.metadataId == metadataId):
                    "Cannot borrow FAHCards reference: the ID of the returned reference is incorrect"
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
            panic("TODO")
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
        pub fun borrowCardDeck(metadataId: String): &FAHCardDecks.NFT? {
            panic("TODO")
        }

        // TODO: Implement borrowViewResolver()
        pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            panic("TODO")
        }

        pub fun createEmptyCardDeck(_name: String, _description: String, _image: MetadataViews.IPFSFile, _thumbnail: MetadataViews.IPFSFile) {
            let author = self.owner!.address
            
            let metadataId = FAHCards.createCardDeckMetadata(_name: _name, _description: _description, _image: _image, _thumbnail: _thumbnail, _extra: {})

            let cardDeck <- create NFT(_metadataId: metadataId)
            self.authoredSets[metadataId] = cardDeck.uuid
            self.ownedNFTs[cardDeck.uuid] <-! cardDeck

            // Map author to CardDeck
            FAHCardDecks.cardDecks[metadataId] = author
            if let cardDecks = &FAHCardDecks.cardDeckOwners[author] as &[String]? {
                cardDecks.append(metadataId)
            } else {
                FAHCardDecks.cardDeckOwners[author] = [metadataId]
            }
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

        // Set empty dicts/arrays
        self.cardDeckOwners = {}
        self.cardDecks = {}

        // Set the named paths
        self.CollectionStoragePath = /storage/FAHCardDeckCollection
        self.CollectionPublicPath = /public/FAHCardDeckCollection
        self.CollectionPrivatePath = /private/FAHCardDeckCollection
    }
}