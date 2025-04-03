import "ArtStudio"

// This transaction is for the admin to create a new artist struct
// and store it in the ArtStudio smart contract

transaction(
    name: String,
    description: String,
    artistName: String,
    creationDate: String,
    creationLocation: String,
    artType: String,
    medium: String,
    subjectMatter: String,
    provenanceNotes: String,
    collection: String?,
    acquisitionDetails: String?
    ) {

    let Administrator: &ArtStudio.Administrator
    let artistAccount: Address?
    let productionDetails: ArtStudio.ProductionDetails

    prepare(admin: auth(BorrowValue) &Account) {
        self.Administrator = admin.storage.borrow<&ArtStudio.Administrator>(from: ArtStudio.AdministratorStoragePath)!
        self.artistAccount = ArtStudio.getArtist(name: artistName)?.accountAddress ?? panic("No artist found by this name: ".concat(artistName))

        self.productionDetails = ArtStudio.ProductionDetails(
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
            "Elevated by ArtStudio",
            )
    }
    execute {
        let newCardID = self.Administrator.createPiece(
            name: name,
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
            productionDetails: self.productionDetails)
    }
}