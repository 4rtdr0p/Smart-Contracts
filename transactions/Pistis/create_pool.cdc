import "Pistis"
import "MetadataViews"

// This transaction is for any user to create a new Project 
// on the proof-of-support platform 

transaction(newPoolName: String, category: String, metadata: {String: AnyStruct}) {

    prepare(signer: &Account) {

    }
    execute {
        let metadataStruct = Pistis.MetadataStruct(newPoolName, category, metadata)
        Pistis.createPool(poolName: newPoolName, metadataStruct: metadataStruct)
    }
}