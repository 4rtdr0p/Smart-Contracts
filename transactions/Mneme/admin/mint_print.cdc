import "Mneme"

// This transaction is for the admin to create a new artist struct
// and store it in the Mneme smart contract

    transaction(
        XUID: String,
        pieceName: String,
        artistAddress: Address,
        description: String,
        image: String,
        paidPrice: UFix64,
        recipient: Address) {

    let Administrator: auth(Mneme.MintPrint) &Mneme.Administrator

    prepare(admin: auth(BorrowValue) &Account) {
        self.Administrator = admin.storage.borrow<auth(Mneme.MintPrint) &Mneme.Administrator>(from: Mneme.AdministratorStoragePath)!
    }
    execute {
        let newCardID = self.Administrator.mintPrint(
            XUID: XUID,
            pieceName: pieceName,
            artistAddress: artistAddress, 
            paidPrice: paidPrice,
            description: description,
            image: image,
            toBeClaimedBy: recipient)   
    }
}