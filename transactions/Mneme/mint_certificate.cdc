import "Mneme"

transaction(
    artistAddress: Address,
    editionId: UInt64,
    thumbnail: String
) {
    prepare(signer: auth(BorrowValue) &Account) {
        let storageIdentifier = "ArtDrop/\(artistAddress)/\(editionId)"
        let editionRef = signer.storage.borrow<auth(Mneme.MintCertificateNFT) &Mneme.Edition>(from: StoragePath(identifier: storageIdentifier)!)!

        editionRef.mintCertificateNFT(thumbnail: thumbnail)
    }
}