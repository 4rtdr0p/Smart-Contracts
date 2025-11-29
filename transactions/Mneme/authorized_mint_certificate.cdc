import "Mneme"

transaction(
    artistAddress: Address,
    editionId: UInt64,
    thumbnail: String
) {
    let capRef: &Capability<auth(Mneme.MintCertificateNFT) &Mneme.Edition>
    prepare(signer: auth(BorrowValue) &Account) {
        let storageIdentifier = "ArtDrop/\(artistAddress)/\(editionId)"
        self.capRef = signer.storage.borrow<&Capability<auth(Mneme.MintCertificateNFT) &Mneme.Edition>>(from:StoragePath(identifier: storageIdentifier)!)!

       let allowed = self.capRef.borrow()!
       allowed.mintCertificateNFT(thumbnail: thumbnail)
    }


       
}


