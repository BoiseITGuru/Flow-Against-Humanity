/*
    Flow Against Humanity (FAH)

    Flow Against Humanity is a multi-player NFT card game protocol inspired by games like Apples 
    to Apples and Cards Against Humanity.

    Protocol Design:

        Cards - Cards are defined by a CardMetadata struct and stored centrally in the protocol 
        contract to all for easy moderation. A separate FAHCard contract is used to define the
        actual NFTs minted for each card.

        Card Decks - Card Decks are defined by a CardDeckMetadata struct and stored centrally 
        in the protocol contract to all for easy moderation. A separate FAHCard contract is 
        used to define the actual NFTs minted for each card.

        Games - To Be Defined!

    Creative Commons Notice:

        Cards Against Humanity decks publsihed to the protocal must adhear to the 
        Creative Commons BY-NC-SA 2.0 license (https://creativecommons.org/licenses/by-nc-sa/2.0/)
        and properly tagged as a CAHDeck by setting the _cahDeck boolean to true upon init.
        
        Protocal users are hereby notified the "non-commercial" aspect of that license implies 
        that decks and cards under those terms cannot be sold. CC’s NonCommercial (NC) licenses 
        prohibit uses that are “primarily intended for or directed toward commercial advantage or 
        monetary compensation.”

        Violations can be reported by opening a Github issue at 
        https://github.com/BoiseITGuru/Flow-Against-Humanity.

        
*/
import MetadataViews from "./utility/MetadataViews.cdc"

pub contract FlowAgainstHumanity {
    /* 
    ################################
    ||                            ||
    ||        FAH - Cards         ||
    ||                            ||
    ################################
    */

    // Map of card metadataIds to the corresponding CardMetadata struct
    access(self) let cardMetadatas: {String: CardMetadata}
    // Map of the oringal owners/minters of a FAHCard
    access(self) let orginalCardOwner: {Address: {UInt64: [UInt64]}}

    // FAHCard Types
    pub enum CardType: UInt8 {
        pub case QUESTION
        pub case QUESTION2
        pub case QUESTION3
        pub case ANSWER
    }

    // Public CardMetaData Interface
    pub struct interface CardMetadataPublic {
        pub fun getCardDeckId(): String
        pub fun getCardDeckAuthor(): Address
        pub fun getText(): String
        pub fun getCardType(): CardType
        pub fun getImage(): MetadataViews.IPFSFile
        pub fun getThumbnail(): MetadataViews.IPFSFile
        pub fun getMaxSupply(): UInt64
        pub fun getOwners(): {UInt64: Address}
        pub fun getExtraMetadata(): {String: AnyStruct}
        pub fun getInCirculation(): UInt64
    }

    // Admin CardMetaData Interface
    pub struct interface CardMetadataAdmin {
        pub fun incrementInCirculation()
        pub fun purchased(serial: UInt64, buyer: Address)
    }

    // Metadata struct for defining FlowAgainstHumanity
    pub struct CardMetadata: CardMetadataPublic, CardMetadataAdmin {
        access(self) let metadataId: String
        access(self) let cardDeckId: String
        access(self) let cardDeckAuthor: Address
		access(self) let text: String
        access(self) let type: CardType
		access(self) let image: MetadataViews.IPFSFile
		access(self) let thumbnail: MetadataViews.IPFSFile
		access(self) let maxSupply: UInt64
		access(self) let owners: {UInt64: Address}
        access(self) let extra: {String: AnyStruct}
        access(self) var inCirculation: UInt64

        // GETTERS
        pub fun getCardDeckId(): String {
            return self.cardDeckId
        }

        pub fun getCardDeckAuthor(): Address {
            return self.cardDeckAuthor
        }

        pub fun getText(): String {
            return self.text
        }

        pub fun getCardType(): CardType {
            return self.type
        }

        pub fun getImage(): MetadataViews.IPFSFile {
            return self.image
        }

        pub fun getThumbnail(): MetadataViews.IPFSFile {
            return self.thumbnail
        }

        pub fun getMaxSupply(): UInt64 {
            return self.maxSupply
        }

        pub fun getOwners(): {UInt64: Address} {
            return self.owners
        }

        pub fun getExtraMetadata(): {String: AnyStruct} {
            return self.extra
        }

        pub fun getInCirculation(): UInt64 {
            return self.inCirculation
        }

        // SETTERS
        pub fun incrementInCirculation() {
            self.inCirculation = self.inCirculation + 1
        }

		pub fun purchased(serial: UInt64, buyer: Address) {
			self.owners[serial] = buyer
		}

		init(_cardDeckId: String, _cardDeckAuthor: Address, _text: String, _type: CardType, _image: MetadataViews.IPFSFile, _thumbnail: MetadataViews.IPFSFile, _maxSupply: UInt64, _extra: {String: AnyStruct}) {
			let hashArray = HashAlgorithm.SHA3_256.hash(_text.utf8.concat(_type.rawValue.toString().utf8))
            let _metadataId = ""
            for hash in hashArray {
                _metadataId.concat(hash.toString())
            }

            // Check if a card with this same name and type already exists
            if FlowAgainstHumanity.cardMetadatas[_metadataId] != nil {
                panic("A Card with this text and type already exists.")
            }

            self.metadataId = _metadataId
            self.cardDeckId = _cardDeckId
            self.cardDeckAuthor = _cardDeckAuthor
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

    pub fun getCardMetadata(_ metadataId: String): &FlowAgainstHumanity.CardMetadata{FlowAgainstHumanity.CardMetadataPublic}? {
		return &(self.cardMetadatas[metadataId]! as  &FlowAgainstHumanity.CardMetadata{FlowAgainstHumanity.CardMetadataPublic})
	}

    // Get Admin interface to CardMetadata
    access(account) fun getCardMetadataAdmin(_ metadataId: String): &FlowAgainstHumanity.CardMetadata{FlowAgainstHumanity.CardMetadataAdmin}? {
        return &(self.cardMetadatas[metadataId]! as  &FlowAgainstHumanity.CardMetadata{FlowAgainstHumanity.CardMetadataAdmin})
    }




    /*
    ################################
    ||                            ||
    ||      FAH - Card Decks      ||
    ||                            ||
    ################################
    */

    // Map of card deck metadataIds to the corresponding CardDeckMetadata struct
    access(self) let cardDeckMetadatas: {String: CardDeckMetadata}
    // Map of the oringal owners/minters of a FAHCard
    access(self) let orginalCardDeckOwner: {Address: {UInt64: [UInt64]}}
    // Maps the owner of a CardDeck to the hash of CardDeckMetadatas name then
    // to each individual CardDeckMetadatas struct.
    access(account) let cardDeckOwners: {Address: [String]}
	access(account) let cardDecks: {String: Address}

    // Public CardDeckMetaData Interface
    pub struct interface CardDeckMetadataPublic {
        pub fun getMetadataId(): String
        pub fun getName(): String
        pub fun getDescription(): String
        pub fun getQuestionCards(): [String]
        pub fun getResponseCards(): [String]
        pub fun getImage(): MetadataViews.IPFSFile
        pub fun getThumbnail(): MetadataViews.IPFSFile
        pub fun getMaxSupply(): UInt64
        pub fun getInCiculation(): UInt64
    }

    // Admin CardDeckMetaData Interface
    pub struct interface CardDeckMetadataAdmin {
        pub fun createCardMetadata(_cardAuthor: Address, _text: String, _type: CardType, _image: MetadataViews.IPFSFile, _thumbnail: MetadataViews.IPFSFile, _maxSupply: UInt64, _extra: {String: AnyStruct})
        pub fun incrementInCirculation()
        pub fun purchased(serial: UInt64, buyer: Address)
    }

    // Metadata struct for defining CardDecks
    pub struct CardDeckMetadata: CardDeckMetadataPublic, CardDeckMetadataAdmin {
        access(self) let metadataId: String
		access(self) let name: String
        access(self) let description: String
        access(self) let questionCards: [String]
        access(self) let responseCards: [String]
        
		access(self) var image: MetadataViews.IPFSFile
		access(self) var thumbnail: MetadataViews.IPFSFile
        access(self) var maxSupply: UInt64
        access(self) var inCirculation: UInt64
        access(self) let owners: {UInt64: Address}

        // Holder for extra/future metadata
        pub var extra: {String: AnyStruct}

        // GETTERS
        pub fun getMetadataId(): String {
            return self.metadataId
        }

        pub fun getName(): String {
            return self.name
        }

        pub fun getDescription(): String {
            return self.description
        }

        pub fun getQuestionCards(): [String] {
            return self.questionCards
        }

        pub fun getResponseCards(): [String] {
            return self.responseCards
        }

        pub fun getImage(): MetadataViews.IPFSFile {
            return self.image
        }

        pub fun getThumbnail(): MetadataViews.IPFSFile {
            return self.thumbnail
        }

        pub fun getMaxSupply(): UInt64 {
            return self.maxSupply
        }

        pub fun getInCiculation(): UInt64 {
            return self.inCirculation
        }

        // SETTERS
        pub fun createCardMetadata(_cardAuthor: Address, _text: String, _type: CardType, _image: MetadataViews.IPFSFile, _thumbnail: MetadataViews.IPFSFile, _maxSupply: UInt64, _extra: {String: AnyStruct}) {
            let metadata = CardMetadata(_cardDeckId: self.metadataId, _cardDeckAuthor: _cardAuthor, _text: _text, _type: _type, _image: _image, _thumbnail: _thumbnail, _maxSupply: _maxSupply, _extra: _extra)
            FlowAgainstHumanity.cardMetadatas[metadata.metadataId] = metadata

            self.appendCardMetadataId(metadata.metadataId)
            self.incrementMaxSupply(metadata.metadataId)
        }

        access(self) fun appendCardMetadataId(_ _metadataId: String) {
            pre {
                FlowAgainstHumanity.cardMetadatas[_metadataId] != nil : "Invalid Card Metadata Id"
            }

            let _type = FlowAgainstHumanity.cardMetadatas[_metadataId]!.getCardType()
            if _type == FlowAgainstHumanity.CardType.ANSWER {
                self.responseCards.append(_metadataId)
            } else {
                self.questionCards.append(_metadataId)
            }
        }

        access(self) fun incrementMaxSupply(_ _metadataId: String) {
            pre {
                FlowAgainstHumanity.cardMetadatas[_metadataId] != nil : "Invalid Card Metadata Id"
            }
            let _maxSupply = FlowAgainstHumanity.cardMetadatas[_metadataId]!.getMaxSupply()
            self.maxSupply = self.maxSupply + _maxSupply
        }

        pub fun incrementInCirculation() {
            self.inCirculation = self.inCirculation + 1
        }

		pub fun purchased(serial: UInt64, buyer: Address) {
			self.owners[serial] = buyer
		}

		init(_name: String, _description: String, _image: MetadataViews.IPFSFile, _thumbnail: MetadataViews.IPFSFile, _extra: {String: AnyStruct}) {
            let hashArray = HashAlgorithm.SHA3_256.hash(_name.utf8)
            let _metadataId = ""
            for hash in hashArray {
                _metadataId.concat(hash.toString())
            }

            // Check if a card set with this same name already exists
            if FlowAgainstHumanity.cardDeckMetadatas[_metadataId] != nil {
                panic("A CardDeck with this name already exists.")
            }


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
            self.owners = {}
		}
    }

    pub fun getCardDeckMetadata(_ metadataId: String): &FlowAgainstHumanity.CardDeckMetadata{FlowAgainstHumanity.CardDeckMetadataPublic}? {
		return &(self.cardDeckMetadatas[metadataId]! as  &FlowAgainstHumanity.CardDeckMetadata{FlowAgainstHumanity.CardDeckMetadataPublic})
	}

    // Get Admin interface to CardMetadata
    access(account) fun getCardDeckMetadataAdmin(_ metadataId: String): &FlowAgainstHumanity.CardDeckMetadata{FlowAgainstHumanity.CardDeckMetadataAdmin}? {
        return &(self.cardDeckMetadatas[metadataId]! as  &FlowAgainstHumanity.CardDeckMetadata{FlowAgainstHumanity.CardDeckMetadataAdmin})
    }

    access(account) fun createCardDeckMetadata(_name: String, _description: String, _image: MetadataViews.IPFSFile, _thumbnail: MetadataViews.IPFSFile, _extra: {String: AnyStruct}): String {
        let metadata = CardDeckMetadata(_name: _name, _description: _description, _image: _image, _thumbnail: _thumbnail, _extra: _extra)
        FlowAgainstHumanity.cardDeckMetadatas[metadata.metadataId] = metadata

        return metadata.metadataId
    }

    init() {
        // Set empty dicts/arrays
        self.cardMetadatas = {}
        self.cardDeckMetadatas = {}
        self.orginalCardOwner = {}
        self.orginalCardDeckOwner = {}
        self.cardDeckOwners = {}
        self.cardDecks = {}
    }
}