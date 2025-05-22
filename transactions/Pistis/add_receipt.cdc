import "Pistis"

// This transaction is for any user to create a new Project 
// on the proof-of-support platform 

transaction(
    poolName: String,
    receiptName: String,
    receiptDescription: String,
    receiptImage: String,
    receiptMetadata: {String: AnyStruct},
    earlyAdopter: {UInt64: UFix64},
    stakingWeight: {UInt64: UFix64},
    loyaltyWeight: {UInt64: UFix64},
) {

    prepare(signer:auth(BorrowValue) &Account) {

        let receiptCreator = signer.storage.borrow<&Pistis.ReceiptCreator>(from: Pistis.ReceiptCreatorStoragePath)!
        let multiplier = Pistis.MultiplierStruct(poolName, earlyAdopter, stakingWeight, loyaltyWeight)
        let receipt = Pistis.ReceiptStruct(poolName, receiptName, receiptDescription, receiptImage, receiptMetadata, multiplier)  
        receiptCreator.createReceipt(receipt: receipt)
    }
    execute {   


    }
}