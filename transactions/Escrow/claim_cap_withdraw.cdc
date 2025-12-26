import "Escrow"

transaction(handlerId: UInt64, provider: Address) {
    prepare(signer: auth(ClaimInboxCapability, Storage) &Account) {
        let inboxIdentifier = "\(signer.address)_Escrow_Handler_\(handlerId)"
        let storagePath = Escrow.getHandlerStoragePath(handlerId)


        let cap: Capability<auth(Escrow.Owner) &Escrow.Handler> = signer.inbox.claim<auth(Escrow.Owner) &Escrow.Handler>(inboxIdentifier, provider: provider)!
        signer.storage.save(cap, to: storagePath)
    //    let capRef =  cap.borrow()!
    //    let vault <- capRef.withdrawFunds()
        // deposit the vault to the signer's storage
     //   signer.storage.save(<- vault, to: /storage/flowTokenVault)
    }
       // let handlerRef : &Capability<auth(Escrow.Owner) &Escrow.Handler> = signer.storage.borrow<&Capability<auth(Escrow.Owner) &Escrow.Handler>>(from: storagePath)!

    execute {

    }
}