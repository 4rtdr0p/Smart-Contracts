import "Mneme"

// This transaction is for the admin to create a new artist struct
// and store it in the Mneme smart contract

transaction(
    pieceName: String,
    newViewsCount: Int64,
    newLikesCount: Int64,
    newSharesCount: Int64,
    newPurchasesCount: Int64
) {

    let Administrator: &Mneme.Administrator

    prepare(admin: auth(BorrowValue) &Account) {
        self.Administrator = admin.storage.borrow<&Mneme.Administrator>(from: Mneme.AdministratorStoragePath)!
    }
    execute {
        let newCardID = self.Administrator.updateSentiment(pieceName: pieceName, newViewsCount: newViewsCount, newLikesCount: newLikesCount, newSharesCount: newSharesCount, newPurchasesCount: newPurchasesCount)
    }
}