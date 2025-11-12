import "ExampleNFT" 
import "NonFungibleToken"
import "MetadataViews"

// This transaction is for any user to create a new Project 
// on the proof-of-support platform 

access(all) fun main(address: Address): [Type] {
    let account = getAccount(address)
    let collectionRef = account.capabilities.borrow<&ExampleNFT.Collection>(ExampleNFT.CollectionPublicPath)!
    let id = collectionRef.getIDs()[0]
    let nftRef = collectionRef.borrowNFT(id)! as! &ExampleNFT.NFT

    return nftRef.getVaultTypes()

}