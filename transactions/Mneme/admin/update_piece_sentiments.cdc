import "Mneme"

// This transaction is for the admin to create a new artist struct
// and store it in the Mneme smart contract

transaction(
    pieceID: UInt64,
    artistName: String,
    newViewsCount: Int64,
    newLikesCount: Int64,
    newSharesCount: Int64,
    newPurchasesCount: Int64
) {

    let Administrator: auth(Mneme.UpdateSentiment) &Mneme.Administrator

    prepare(admin: auth(BorrowValue) &Account) {
        self.Administrator = admin.storage.borrow<auth(Mneme.UpdateSentiment) &Mneme.Administrator>(from: Mneme.AdministratorStoragePath)!
    }
    execute {
        let newCardID = self.Administrator.updateSentiment(pieceID: pieceID, artistName: artistName, newViewsCount: newViewsCount, newLikesCount: newLikesCount, newSharesCount: newSharesCount, newPurchasesCount: newPurchasesCount)
    }
}