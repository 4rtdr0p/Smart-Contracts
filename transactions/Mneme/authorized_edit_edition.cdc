import "Mneme"

transaction(
    artistAddress: Address,
    editionId: UInt64,
    name: String?,
    price: UFix64?,
    type: String?,
    story: String?,
    dimensions: {String: String}?,
    reprintLimit: Int64?
) {
    let capRef: &Capability<auth(Mneme.Editions) &Mneme.Edition>
    prepare(signer: auth(BorrowValue) &Account) {
        let storageIdentifier = "ArtDrop_Edition_".concat(artistAddress.toString()).concat("_").concat(editionId.toString())
        self.capRef = signer.storage.borrow<&Capability<auth(Mneme.Editions) &Mneme.Edition>>(from:StoragePath(identifier: storageIdentifier)!)!

       let allowed = self.capRef.borrow()!
       allowed.editEdition(name: name, price: price, type: type, story: story, dimensions: dimensions, reprintLimit: reprintLimit)
    }    
}