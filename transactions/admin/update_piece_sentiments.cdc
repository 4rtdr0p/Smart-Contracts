import "ArtDrop"

// This transaction is for the admin to create a new artist struct
// and store it in the ArtDrop smart contract

transaction(pieceName: String, newViewsCount: Int64) {

    let Administrator: &ArtDrop.Administrator

    prepare(admin: auth(BorrowValue) &Account) {
        self.Administrator = admin.storage.borrow<&ArtDrop.Administrator>(from: ArtDrop.AdministratorStoragePath)!
    }
    execute {
        let newCardID = self.Administrator.updateViews(pieceName: pieceName, newCount: newViewsCount)
    }
}