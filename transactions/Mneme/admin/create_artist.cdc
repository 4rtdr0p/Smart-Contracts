import "Mneme" 

// This transaction is for the admin to create a new artist struct
// and store it in the Mneme smart contract

transaction(
    name: String,
    biography: String,
    nationality: String,
    preferredMedium: String,
    socials: {String: String},
    representation: String?,
    accountAddress: Address,
    communityRoyalties: UFix64) {

    let Administrator: &Mneme.Administrator

    prepare(admin: auth(BorrowValue) &Account) {
        self.Administrator = admin.storage.borrow<&Mneme.Administrator>(from: Mneme.AdministratorStoragePath)!
    }
    execute {
        let newCardID = self.Administrator.createArtist(
            name: name,
            biography: biography,
            nationality: nationality,
            preferredMedium: preferredMedium,
            socials: socials,
            representation: representation,
            accountAddress: accountAddress,
            communityRoyalties: communityRoyalties)
    }
}