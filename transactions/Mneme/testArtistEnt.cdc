import "Mneme"

transaction(artistName: String) {
    prepare(signer: auth(BorrowValue) &Account) {
        let artist = Mneme.getArtist(name: artistName)!
        artist.addExtra(key: "2", value: "value")
    }
}