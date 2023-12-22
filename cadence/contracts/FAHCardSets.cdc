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
    access(contract) let cardSetOwners: {Address: [String]}
	access(contract) let cardSets: {String: Address}

    // Metadata struct for defining CardSets
    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64
        pub let metadataId: String
		pub let name: String
        pub let description: String
		pub let image: MetadataViews.IPFSFile
		pub let thumbnail: MetadataViews.IPFSFile
        pub let maxSupply: UInt64
        pub let inCirculation: UInt64
		pub let questionCards: [String]
        pub let responseCards: [String]

        // Holder for extra/future metadata
        pub var extra: {String: AnyStruct}

		init(_metadataId: String, _name: String, _description: String, _image: MetadataViews.IPFSFile, _thumbnail: MetadataViews.IPFSFile, _extra: {String: AnyStruct}) {
            self.id = self.uuid
            self.metadataId = _metadataId
            self.name = _name
			self.description = _description
            self.image = _image
			self.thumbnail = _thumbnail
            self.extra = _extra

            self.maxSupply = 0
            self.inCirculation = 0
            self.questionCards = []
            self.responseCards = []
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
            switch view {
                case Type<MetadataViews.Display>():
					return MetadataViews.Display(
						name: "FAH Card Set: ".concat(self.name),
						description: self.description,
						thumbnail: self.thumbnail
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
                    var authorName: String = self.owner!.address.toString()
                    if let profile = getAccount(self.owner!.address).getCapability(Profile.publicPath)
								.borrow<&Profile.User{Profile.Public}>() {
                                    let findName = profile.getFindName()
                                    authorName = profile.getName().concat(" (").concat(findName == "" ? self.owner!.address.toString() : findName).concat(")")
                                }

                    let royalties: [MetadataViews.Royalty] = [
                        MetadataViews.Royalty(
							receiver: getAccount(self.owner!.address).getCapability<&FungibleToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver),
							cut: FAHRoyalties.authorCardSet,
							description: authorName.concat(" receives a ").concat((FAHRoyalties.authorCardSet * 100.0).toString()).concat("% royalty from secondary sales for authroing this FAH Card Set")
						)
                    ]
                    
                    for royalty in FAHRoyalties.globalCardSet {
                        royalties.append(royalty)
                    }
                case Type<MetadataViews.Serial>():
                    return MetadataViews.Serial(
                        self.id
                    )
                case Type<MetadataViews.Traits>():
					let traits = MetadataViews.Traits([
                        MetadataViews.Trait(name: "Number Questions", value: self.questionCards.length, displayType: nil, rarity: nil),
                        MetadataViews.Trait(name: "Number Responses", value: self.responseCards.length, displayType: nil, rarity: nil),
                        MetadataViews.Trait(name: "Max Supply", value: self.maxSupply, displayType: nil, rarity: nil),
                        MetadataViews.Trait(name: "In Circulation", value: self.inCirculation, displayType: nil, rarity: nil)
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
            let hashArray = HashAlgorithm.SHA3_256.hash(_name.utf8)
            let metadataId = ""
            for hash in hashArray {
                metadataId.concat(hash.toString())
            }

            // Check if a card set with this same name already exists
            if FAHCardSets.cardSets[metadataId] != nil {
                panic("A CardSet with this name already exists.")
            }

            let cardSet <- create NFT(_metadataId: metadataId, _name: _name, _description: _description, _image: _image, _thumbnail: _thumbnail, _extra: {})
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