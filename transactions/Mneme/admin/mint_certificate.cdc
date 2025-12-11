import "Mneme"

// This transaction is to mint a new certificate NFT
// 

    transaction(
        artistAddress: Address,
        editionId: UInt64,
        thumbnail: String) {

    let Administrator: &Mneme.Administrator

    prepare(admin: auth(BorrowValue) &Account) {
        self.Administrator = admin.storage.borrow<auth(Mneme.Editions) &Mneme.Administrator>(from: Mneme.AdministratorStoragePath)!
    }
    execute {
        let newCardID = self.Administrator.mintCertificateNFT(
            artistAddress: artistAddress,
            editionId: editionId,
            thumbnail: thumbnail)   
    }
}