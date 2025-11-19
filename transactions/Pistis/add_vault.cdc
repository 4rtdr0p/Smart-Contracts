import "ArtDrop" 
import "FungibleToken"
import "FlowToken"

transaction() {
    let vaultReceiverRef: Capability<&{FungibleToken.Receiver}>

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController) &Account) { 
        // get the FlowToken Receiver reference Capability
        self.vaultReceiverRef = signer.capabilities.storage.issue<&{FungibleToken.Receiver}>(StoragePath(identifier: "/public/flowTokenReceiver")!)

        // get the collection reference
        let collectionRef: &ArtDrop.Collection = signer.storage.borrow<&ArtDrop.Collection>(from: ArtDrop.CollectionStoragePath)!
        // get the first ID
        let id = collectionRef.getIDs()[0]
        // create a new FlowToken Vault
        let newVault <- FlowToken.createEmptyVault(vaultType: Type<@FlowToken.Vault>())
        collectionRef.addVault(vaultType: Type<@FlowToken.Vault>(), vault: <- newVault, id: id, vaultReceiverPath: /public/flowTokenReceiver)  
    }
} 
  