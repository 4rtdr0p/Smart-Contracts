import "Mneme"

// This transaction is for the admin to create a new artist struct
// and store it in the Mneme smart contract

transaction(recipient: Address) {

    let Administrator: &Mneme.Administrator

    prepare(admin: auth(BorrowValue) &Account) {
        self.Administrator = admin.storage.borrow<&Mneme.Administrator>(from: Mneme.AdministratorStoragePath)!
    }
    execute {
        let newCardID = self.Administrator.mintPiece(pieceName: "", recipient: recipient)
    }
}