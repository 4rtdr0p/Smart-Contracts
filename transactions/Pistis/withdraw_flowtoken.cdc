import "ArtDrop"  
import "FungibleToken"
import "FlowToken"

transaction() {

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController) &Account) { 

        // get the collection reference
        let collectionRef: &ArtDrop.Collection = signer.storage.borrow<&ArtDrop.Collection>(from: ArtDrop.CollectionStoragePath)!
        // get the first ID
        let id = collectionRef.getIDs()[0]
        
        collectionRef.withdrawFromVault(id: id, vaultType: Type<@FlowToken.Vault>())
    }
} 
  