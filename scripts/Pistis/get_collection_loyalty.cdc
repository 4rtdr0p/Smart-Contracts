import "ArtDrop" 
import "NonFungibleToken"
import "MetadataViews"

// This transaction is for any user to create a new Project 
// on the proof-of-support platform 

access(all) fun main(address: Address): &{Address: UFix64} {
    let account = getAccount(address)
    let collectionRef = account.capabilities.borrow<&ArtDrop.Collection>(ArtDrop.CollectionPublicPath)!
    let loyaltyPoints = collectionRef.loyaltyPoints

    return loyaltyPoints

}