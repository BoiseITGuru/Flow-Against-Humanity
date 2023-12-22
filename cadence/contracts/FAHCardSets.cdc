/*
*
*  
*
*/
import Crypto
import FungibleToken from "./utility/FungibleToken.cdc"
import NonFungibleToken from "./utility/NonFungibleToken.cdc"
import MetadataViews from "./utility/MetadataViews.cdc"
import ViewResolver from "./utility/ViewResolver.cdc"
import FAHCards from "./FAHCards.cdc"
import FAHRoyalties from "./FAHRoyalties.cdc"
import Profile from "./find/Profile.cdc"

pub contract FAHCardSets: NonFungibleToken, ViewResolver {
    // Total supply of FAHCardSets in existence
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

    // Maps the owner of a CardSet to the hash of CardSetMetadatas name then
    // to each individual CardSetMetadatas struct.
    access(account) let cardSetOwners: {Address: [String]}
	access(account) let cardSets: {String: Address}

    // Metadata struct for defining CardSets
    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64
        pub let metadataId: String

        pub fun getMetadata(): &FAHCards.CardSetMetadata{FAHCards.CardSetMetadataPublic}? {
			return FAHCards.getCardSetMetadata(self.metadataId)
		}

        pub fun createCardMetadata(_text: String, _type: FAHCards.CardType, _image: MetadataViews.IPFSFile, _thumbnail: MetadataViews.IPFSFile, _maxSupply: UInt64) {
            let setMetadata = FAHCards.getCardSetMetadataAdmin(self.metadataId) ?? panic("Could not get Card Set Metadata")
            let hashArray = HashAlgorithm.SHA3_256.hash(_text.utf8.concat(_type.rawValue.toString().utf8))
            let cardMetadataId = ""
            for hash in hashArray {
                cardMetadataId.concat(hash.toString())
            }

            // Check if a card set with this same name already exists
            if FAHCards.cardMetadatas[cardMetadataId] != nil {
                panic("A Card with this text and type already exists.")
            }

            let cardMetadata = FAHCards.CardMetadata(_cardSetId: self.metadataId, _cardSetAuthor: self.owner!.address, _text: _text, _type: _type, _image: _image, _thumbnail: _thumbnail, _maxSupply: _maxSupply, _extra: {})
            setMetadata.appendCardMetadataId(_metadataId: cardMetadataId, _type: cardMetadata.getCardType())
            setMetadata.incrementMaxSupply()
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
            let metadata = FAHCards.cardSetMetadatas[self.metadataId] ?? panic("couldn't find Card Set Metadata")
            switch view {
                case Type<MetadataViews.Display>():
					return MetadataViews.Display(
						name: "FAH Card Set: ".concat(metadata.name),
						description: metadata.description,
						thumbnail: metadata.thumbnail
					)
                case Type<MetadataViews.ExternalURL>():
                    return MetadataViews.ExternalURL("https://fah.boiseitguru.dev/sets/".concat(self.metadataId))
                case Type<MetadataViews.NFTCollectionData>():
                    return MetadataViews.NFTCollectionData(
						storagePath: FAHCardSets.CollectionStoragePath,
						publicPath: FAHCardSets.CollectionPublicPath,
						providerPath: FAHCardSets.CollectionPrivatePath,
						publicCollection: Type<&Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(),
						publicLinkedType: Type<&Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(),
						providerLinkedType: Type<&Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection, NonFungibleToken.Provider}>(),
						createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
								return <- FAHCardSets.createEmptyCollection()
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
                        cut: FAHRoyalties.authorCardSet,
                        description: authorName.concat(" receives a ").concat((FAHRoyalties.authorCardSet * 100.0).toString()).concat("% royalty from secondary sales for authoring this FAH Card Set")
                    )]
                    
                    for royalty in FAHRoyalties.globalCardSet {
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
    pub resource interface FAHCardSetCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun getMetadataIds(): [String]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowCardSet(metadataId: String): &FAHCardSets.NFT? {
            post {
                (result == nil) || (result?.metadataId == metadataId):
                    "Cannot borrow FAHCards reference: the ID of the returned reference is incorrect"
            }
        }
    }

    pub resource Collection: FAHCardSetCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        // dictionary of authored CardSets
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

        // TODO: Implement borrowCardSet()
        pub fun borrowCardSet(metadataId: String): &FAHCardSets.NFT? {
            panic("TODO")
        }

        // TODO: Implement borrowViewResolver()
        pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            panic("TODO")
        }

        pub fun createEmptyCardSet(_name: String, _description: String, _image: MetadataViews.IPFSFile, _thumbnail: MetadataViews.IPFSFile) {
            let author = self.owner!.address
            
            let metadataId = FAHCards.createCardSetMetadata(_name: _name, _description: _description, _image: _image, _thumbnail: _thumbnail, _extra: {})

            let cardSet <- create NFT(_metadataId: metadataId)
            self.authoredSets[metadataId] = cardSet.uuid
            self.ownedNFTs[cardSet.uuid] <-! cardSet

            // Map author to CardSet
            FAHCardSets.cardSets[metadataId] = author
            if let cardSets = &FAHCardSets.cardSetOwners[author] as &[String]? {
                cardSets.append(metadataId)
            } else {
                FAHCardSets.cardSetOwners[author] = [metadataId]
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

    // Allows anyone to create a new empty CardSetCollection
    //
    // @return a new CardSetCollection resource
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
        self.cardSetOwners = {}
        self.cardSets = {}

        // Set the named paths
        self.CollectionStoragePath = /storage/FAHCardSetCollection
        self.CollectionPublicPath = /public/FAHCardSetCollection
        self.CollectionPrivatePath = /private/FAHCardSetCollection
    }
}