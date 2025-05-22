import "Pistis"
import "NonFungibleToken"
import "MetadataViews"
import "FlowToken"
import "FungibleToken"
// This transaction is for any user to create a new Project 
// on the proof-of-support platform 

transaction(newPoolName: String, receiptName: String,) {

    prepare(signer:auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        let metadataStruct = Pistis.PoolStruct(newPoolName, signer.address, category)     

        let receiptCreator <- Pistis.createPool(poolName: newPoolName, PoolStruct: metadataStruct) 

        signer.storage.save(<- receiptCreator, to: Pistis.ReceiptCreatorStoragePath)
    }
    execute {


    }
}