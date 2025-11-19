import "ArtDrop" 
import "NonFungibleToken"
import "MetadataViews"

// This transaction is for any user to create a new Project 
// on the proof-of-support platform 

access(all) fun main(address: Address): [Type] {
    let account = getAccount(address)
    let collectionRef = account.capabilities.borrow<&ArtDrop.Collection>(ArtDrop.CollectionPublicPath)!
    let id = collectionRef.getIDs()[0]
    let nftRef = collectionRef.borrowNFT(id)! as! &ArtDrop.NFT

    return nftRef.getVaultTypes()

}