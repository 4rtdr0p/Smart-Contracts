import "Mneme"  
import "FungibleToken"
import "FlowToken"

transaction() {

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController) &Account) { 

        // get the collection reference
        let collectionRef: &Mneme.Collection = signer.storage.borrow<&Mneme.Collection>(from: Mneme.CollectionStoragePath)!
        // get the first ID
        let id = collectionRef.getIDs()[0]
        
        collectionRef.withdrawFromVault(id: id, vaultType: Type<@FlowToken.Vault>())
    }
} 