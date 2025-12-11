import "Mneme"

transaction(
    artistAddress: Address,
    editionId: UInt64,
    thumbnail: String
) {
    prepare(signer: auth(BorrowValue) &Account) {
        let storageIdentifier = "ArtDrop_Edition_".concat(artistAddress.toString()).concat("_").concat(editionId.toString())
        let editionRef = signer.storage.borrow<auth(Mneme.Editions) &Mneme.Edition>(from: StoragePath(identifier: storageIdentifier)!)!

        editionRef.mintCertificateNFT(thumbnail: thumbnail)
    } 
}