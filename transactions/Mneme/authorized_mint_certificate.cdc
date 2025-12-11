import "Mneme"

transaction(
    artistAddress: Address,
    editionId: UInt64,
    thumbnail: String
) {
    let capRef: &Capability<auth(Mneme.Editions) &Mneme.Edition>
    prepare(signer: auth(BorrowValue) &Account) {
        let storageIdentifier = "ArtDrop_Edition_".concat(artistAddress.toString()).concat("_").concat(editionId.toString())
        self.capRef = signer.storage.borrow<&Capability<auth(Mneme.Editions) &Mneme.Edition>>(from:StoragePath(identifier: storageIdentifier)!)!

       let allowed = self.capRef.borrow()!
       allowed.mintCertificateNFT(thumbnail: thumbnail)
    }


       
}


