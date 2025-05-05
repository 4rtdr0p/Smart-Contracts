import "Mneme"
import "NonFungibleToken"
import "MetadataViews"
// This transaction is for the admin to create a new artist struct
// and store it in the Mneme smart contract

transaction() {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {
        
        let collectionData = Mneme.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("ViewResolver does not resolve NFTCollectionData view")

        // Create a new empty collection
        let collection <- Mneme.createEmptyCollection(nftType: Type<@Mneme.NFT>())
        // save it to the account
        signer.storage.save(<-collection, to: collectionData.storagePath)
        // the old "unlink"
        let oldLink = signer.capabilities.unpublish(collectionData.publicPath)
        // create a public capability for the collection
        let collectionCap = signer.capabilities.storage.issue<&Mneme.Collection>(collectionData.storagePath)
        signer.capabilities.publish(collectionCap, at: collectionData.publicPath)
        // Setup the storage
        let pistis <- Mneme.createEmptyPistis(colletor: signer.address)
        signer.storage.save(<- pistis, to: Mneme.PistisStoragePath)
        // create a public capability for the storage
        let pistisCap = signer.capabilities.storage.issue<&Mneme.Pistis>(Mneme.PistisStoragePath)
        signer.capabilities.publish(pistisCap, at: Mneme.PistisPublicPath)

    }
}