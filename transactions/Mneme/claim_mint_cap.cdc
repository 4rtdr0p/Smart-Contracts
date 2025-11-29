import "Mneme"

transaction(editionId: UInt64) {
    prepare(signer: auth(ClaimInboxCapability, Storage) &Account) {
        let inboxIdentifier = "ArtDrop/\(signer.address)/\(editionId)"
        let storagePath = StoragePath(identifier: inboxIdentifier)!

        let cap: Capability<auth(Mneme.MintCertificateNFT) &Mneme.Edition> = signer.inbox.claim<auth(Mneme.MintCertificateNFT) &Mneme.Edition>(inboxIdentifier, provider: Mneme.address)!
    //    let address = Mneme.address 
    //    let artDropInbox = getAccount(Mneme.address).inbox
        // let mintCapability = signer.inbox.claim<&Capability>(name, provider: provider)
        signer.storage.save(cap, to: storagePath)
    }
}(t, "A card with this name already exists")