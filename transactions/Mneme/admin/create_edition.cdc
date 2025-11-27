import "ArtDrop"

// This transaction is for the admin to create a new artist struct
// and store it in the Mneme smart contract

transaction(
    name: String,
    price: UFix64,
    type: String,
    story: String,
    dimensions: {String: String},
    reprintLimit: Int64,
    artistAddress: Address) {

    let Administrator: &Mneme.Administrator 

    prepare(admin: auth(BorrowValue) &Account) {
        self.Administrator = admin.storage.borrow<&Mneme.Administrator>(from: Mneme.AdministratorStoragePath)!
    } 
    execute {
        let newCardID = self.Administrator.createEdition(    
            name: name,
            price: price,
            type: type,
            story: story,
            dimensions: dimensions,
            reprintLimit: reprintLimit,
            artistAddress: artistAddress)
    }
}