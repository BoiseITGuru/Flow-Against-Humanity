/*
*
*  
*
*/
import MetadataViews from "./utility/MetadataViews.cdc"

pub contract FAHRoyalties {
    pub var globalCard: [MetadataViews.Royalty]
    pub var globalCardSet: [MetadataViews.Royalty]
    pub var authorCard: UFix64
    pub var authorCardSet: UFix64

    pub fun updateGlobalCard(_ _royalties:[MetadataViews.Royalty]) {
        self.globalCard = _royalties
    }

    pub fun updateGlobalGlobalCardSet(_ _royalties:[MetadataViews.Royalty]) {
        self.globalCardSet = _royalties
    }

    init(_initialGlobalCard: [MetadataViews.Royalty], _initialGlobalCardSet: [MetadataViews.Royalty], _initialAuthorCard: UFix64, _initialAuthorCardSet: UFix64) {
        self.globalCard = _initialGlobalCard
        self.globalCardSet = _initialGlobalCardSet
        self.authorCard = _initialAuthorCard
        self.authorCardSet = _initialAuthorCardSet
    }
}