import "Mneme"

// This transaction is for the admin to create a new Piece resource
// and store it in the Mneme smart contract

transaction(
    title: String,
    description: String,
    artistID: UInt64,
    artistName: String,
    creationDate: String,
    creationLocation: String,
    artType: String,
    medium: String,
    subjectMatter: String,
    provenanceNotes: String,
    collection: String?,
    acquisitionDetails: String?,
    price: UFix64,
    encodedImg: String,
    ) {

    let Administrator: &Mneme.Administrator
    let artistAccount: Address?
    let productionDetails: Mneme.ProductionDetails

    prepare(admin: auth(BorrowValue) &Account) {
        self.Administrator = admin.storage.borrow<&Mneme.Administrator>(from: Mneme.AdministratorStoragePath)!
        self.artistAccount = Mneme.getArtistAccountAddress(id: artistID)

        self.productionDetails = Mneme.ProductionDetails(
            "Near Mint",
            "Bamboo",
            10.0,
            5.5,
            "Texture Printing",
            "Glossy",
            "Gold",
            100.0,
            "100",
            "Big and Huge",
            "Printing Types",
            "Many substrates",
            "Block wood frame",
            "Unmounted at combat",
            "Packed",
            "No Signature",
            "No Certification",
            "No numbering",
            "Almost completed",
            "Elevated by Mneme",
            )
    }
    execute {
        let newPieceID = self.Administrator.createPiece(
            title: title,
            description: description,
            artistName: artistName,
            artistAccount: self.artistAccount!,
            creationDate: creationDate,
            creationLocation: creationLocation,
            artType: artType,
            medium: medium,
            subjectMatter: subjectMatter,
            provenanceNotes: provenanceNotes,
            acquisitionDetails: acquisitionDetails,
            productionDetails: self.productionDetails,
            price: price,
            image: encodedImg)
    }
}