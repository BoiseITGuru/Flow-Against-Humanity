import "NonFungibleToken"
import "MetadataViews"
import "FAHCard"
import "FAHCardDeck"

transaction() {
  
  prepare(signer: AuthAccount) {
    if signer.borrow<&FAHCard.Collection>(from: FAHCard.CollectionStoragePath) == nil {
      signer.save(<- FAHCard.createEmptyCollection(), to: FAHCard.CollectionStoragePath)
      signer.link<&FAHCard.Collection{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>(FAHCard.CollectionPublicPath, target: FAHCard.CollectionStoragePath)
    }

    if signer.borrow<&FAHCardDeck.Collection>(from: FAHCardDeck.CollectionStoragePath) == nil {
      signer.save(<- FAHCardDeck.createEmptyCollection(), to: FAHCardDeck.CollectionStoragePath)
      signer.link<&FAHCardDeck.Collection{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>(FAHCardDeck.CollectionPublicPath, target: FAHCardDeck.CollectionStoragePath)
    }
  }

  execute {
    
  }
}
 