import "ArtDrop"

// This transaction is for the admin to create a new artist struct
// and store it in the ArtDrop smart contract

transaction(
    name: String,
    biography: String,
    nationality: String,
    preferredMedium: String,
    socials: {String: String},
    representation: String?,
    accountAddress: Address) {

    let Administrator: &ArtDrop.Administrator

    prepare(admin: auth(BorrowValue) &Account) {
        self.Administrator = admin.storage.borrow<&ArtDrop.Administrator>(from: ArtDrop.AdministratorStoragePath)!
    }
    execute {
        let newCardID = self.Administrator.createArtist(
            name: name,
            biography: biography,
            nationality: nationality,
            preferredMedium: preferredMedium,
            socials: socials,
            representation: representation,
            accountAddress: accountAddress)
    }
}