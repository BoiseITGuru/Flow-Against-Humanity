/*
*
*  
*
*/
import FungibleToken from "./utility/FungibleToken.cdc"
import MetadataViews from "./utility/MetadataViews.cdc"
import Profile from "./find/Profile.cdc"

pub contract FAHRoyalties {
    pub var globalCard: [MetadataViews.Royalty]
    pub var globalCardDeck: [MetadataViews.Royalty]
    pub var authorCard: UFix64
    pub var authorCardDeck: UFix64

    pub fun updateGlobalCard(_ _royalties:[MetadataViews.Royalty]) {
        self.globalCard = _royalties
    }

    pub fun updateGlobalGlobalCardDeck(_ _royalties:[MetadataViews.Royalty]) {
        self.globalCardDeck = _royalties
    }

    init(_initialGlobalCard: [MetadataViews.Royalty], _initialGlobalCardDeck: [MetadataViews.Royalty], _initialAuthorCard: UFix64, _initialAuthorCardDeck: UFix64) {
        self.globalCard = _initialGlobalCard
        self.globalCardDeck = _initialGlobalCardDeck
        self.authorCard = _initialAuthorCard
        self.authorCardDeck = _initialAuthorCardDeck
    }
}