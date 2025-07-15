import "Mneme"

// This transaction is for the admin to create a new artist struct
// and store it in the Mneme smart contract

    transaction(pieceName: String, artistName: String, description: String, image: String, piecePrice: UFix64,   recipient: Address) {

    let Administrator: auth(Mneme.MintPiece) &Mneme.Administrator

    prepare(admin: auth(BorrowValue) &Account) {
        self.Administrator = admin.storage.borrow<auth(Mneme.MintPiece) &Mneme.Administrator>(from: Mneme.AdministratorStoragePath)!
    }
    execute {
        let newCardID = self.Administrator.mintPiece(
            pieceName: pieceName,
            artistName: artistName,
            piecePrice: piecePrice,
            description: description,
            image: image,
            recipient: recipient)
    }
}