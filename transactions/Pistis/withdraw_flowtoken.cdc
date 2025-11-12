import "ExampleNFT"  
import "FungibleToken"
import "FlowToken"

transaction() {
    let vaultReceiverRef: Capability<&{FungibleToken.Receiver}>

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController) &Account) { 
        // get the FlowToken Receiver reference Capability
        self.vaultReceiverRef = signer.capabilities.storage.issue<&{FungibleToken.Receiver}>(StoragePath(identifier: "/public/flowTokenReceiver")!)

        // get the collection reference
        let collectionRef: &ExampleNFT.Collection = signer.storage.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!
        // get the first ID
        let id = collectionRef.getIDs()[0]
        
        collectionRef.withdrawFromVault(id: id, vaultType: Type<@FlowToken.Vault>())
    }
} 
  