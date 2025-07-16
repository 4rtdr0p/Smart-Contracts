import "Mneme"
import "NonFungibleToken"

transaction(id: UInt64) {

    let collectionRef: auth(Mneme.ClaimPrint) &Mneme.Collection
    prepare(signer: auth(BorrowValue) &Account) {
        self.collectionRef = signer.storage.borrow<auth(Mneme.ClaimPrint) &Mneme.Collection>(from: Mneme.CollectionStoragePath)!
    }

    execute {
        self.collectionRef.claimPrint(id: id)
    }   
}