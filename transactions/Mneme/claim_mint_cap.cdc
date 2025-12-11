import "Mneme"

transaction(editionId: UInt64) {
    prepare(signer: auth(ClaimInboxCapability, Storage) &Account) {
        let inboxIdentifier = "ArtDrop_Edition_".concat(signer.address.toString()).concat("_").concat(editionId.toString())
        let storagePath = StoragePath(identifier: inboxIdentifier)!

        let cap: Capability<auth(Mneme.Editions) &Mneme.Edition> = signer.inbox.claim<auth(Mneme.Editions) &Mneme.Edition>(inboxIdentifier, provider: Mneme.address)!
    //    let address = Mneme.address 
    //    let artDropInbox = getAccount(Mneme.address).inbox
        // let mintCapability = signer.inbox.claim<&Capability>(name, provider: provider)
        signer.storage.save(cap, to: storagePath)
    }
}