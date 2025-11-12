import "ExampleNFT"
import "FungibleToken"
import "FlowToken"

transaction() {
    prepare(signer: auth(BorrowValue) &Account) { 
        let collectionRef: &ExampleNFT.Collection = signer.storage.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!
        let id = collectionRef.getIDs()[0]
        let newVault <- FlowToken.createEmptyVault(vaultType: Type<@FlowToken.Vault>())
        collectionRef.addVault(vaultType: Type<@FlowToken.Vault>(), vault: <- newVault, id: id) 
    }
    
} 