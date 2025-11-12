import "ExampleNFT" 
import "FungibleToken"
import "FlowToken"

transaction(account: Address, amount: UFix64, id: UInt64) {

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController) &Account) {
         // Get a reference to the signer's stored vault
        let vaultRef = signer.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("The signer does not store an ExampleToken.Vault object at the path "
                    .concat(/storage/flowTokenVault.toString())
                    .concat(". The signer must initialize their account with this vault first!"))


        let collectionRef: &ExampleNFT.Collection = getAccount(account).capabilities.borrow<&ExampleNFT.Collection>(ExampleNFT.CollectionPublicPath)!
        
        
        collectionRef.depositToVault(id: id, vaultType: Type<@FlowToken.Vault>(), vaultDeposit: <- vaultRef.withdraw(amount: amount))
    }

    execute {

    }
}
