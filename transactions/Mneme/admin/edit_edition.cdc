import "Mneme"

// This transaction is for the admin to edit an edition resource
// from the Mneme smart contract storage

transaction(
    editionID: UInt64,
    artistAddress: Address,
    name: String?,
    price: UFix64?,
    type: String?,
    story: String?,
    dimensions: {String: String}?,
    reprintLimit: Int64?) {

    prepare(admin: auth(BorrowValue) &Account) {
        let storageIdentifier = "ArtDrop_Edition_".concat(artistAddress.toString()).concat("_").concat(editionID.toString())
        let storagePath = StoragePath(identifier: storageIdentifier)!
        let editionRef = admin.storage.borrow<auth(Mneme.Editions) &Mneme.Edition>(from: storagePath)!

        editionRef.editEdition(name: name, price: price, type: type, story: story, dimensions: dimensions, reprintLimit: reprintLimit)
    }
            
}