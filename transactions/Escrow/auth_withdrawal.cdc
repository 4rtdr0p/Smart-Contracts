import "Escrow"
import "FlowToken"
import "FungibleToken"

transaction(handlerId: UInt64) {
    let capRef: &Capability<auth(Escrow.Owner) &Escrow.Handler>

    prepare(signer: auth(ClaimInboxCapability, Storage) &Account) {
        let storagePath = StoragePath(identifier: "\(Escrow.getAddress())_Escrow_Handler_\(handlerId)")!


       // let handlerRef: &Capability<auth(Escrow.Owner) &Escrow.Handler> = signer.storage.borrow<&Capability<auth(Escrow.Owner) &Escrow.Handler>>(from: storagePath)!
        self.capRef =  signer.storage.borrow<&Capability<auth(Escrow.Owner) &Escrow.Handler>>(from: storagePath)!
        let allowed =  self.capRef.borrow()!
        let vault <- allowed.withdrawFunds()
        let receiverRef = signer.capabilities.borrow<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)!
        receiverRef.deposit(from: <- vault.withdraw(amount: vault.balance))
        destroy vault

    }

    execute {

    }
}