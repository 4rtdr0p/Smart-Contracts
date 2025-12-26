import "Escrow"
import "FlowToken"
import "FungibleToken"
import "FlowTransactionScheduler" 

transaction(amount: UFix64, receiver: Address) {
 

    prepare(signer:auth(Storage, Capabilities, Inbox) &Account) {
        // Delay for 7 days
        let future = getCurrentBlock().timestamp + UFix64(7 * 24 * 60 * 60)
        let priority = FlowTransactionScheduler.Priority.High
        // Estimate fees
        let est = FlowTransactionScheduler.estimate(
            data: "",
            timestamp: future,
            priority: priority,
            executionEffort: 1000
        )

        assert(
            est.timestamp != nil || priority == FlowTransactionScheduler.Priority.High,
            message: est.error ?? "estimation failed"
        )
        // get ref to Flow vault
        let vaultRef = signer.storage
            .borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("missing FlowToken vault")
        // Withdraw fees and offer amount
        let fees <- vaultRef.withdraw(amount: est.flowFee ?? 0.0) as! @FlowToken.Vault
        let offer <- vaultRef.withdraw(amount: amount) as! @FlowToken.Vault
        // Create handler inside account
        let handler <- Escrow.createHandler(offerVault: <- offer, receiver: receiver)
        // get storage path for handler
        let handlerStoragePath = Escrow.getHandlerStoragePath(handler.handlerId) 
        // issue a capability to the handler
        signer.storage.save(<-handler, to: handlerStoragePath)
        let handlerCap = signer.capabilities.storage
            .issue<auth(FlowTransactionScheduler.Execute) &{FlowTransactionScheduler.TransactionHandler}>(handlerStoragePath)

        let receipt <- FlowTransactionScheduler.schedule(
            handlerCap: handlerCap,
            data: nil,
            timestamp: future,
            priority: priority    ,
            executionEffort: 1000,
            fees: <-fees
        )

        // deposit the receipt to the handler
        let handlerRef = signer.storage.borrow< &Escrow.Handler>(from: handlerStoragePath)!
        handlerRef.depositReceipt(receipt: <-receipt)


        // Inbox identifier
        let inboxIdentifier = "\(receiver)_Escrow_Handler_\(handlerRef.handlerId)"  
        // Get a cap to this handler resource
        let handlerInbox = signer.capabilities.storage.issue<auth(Escrow.Owner) &Escrow.Handler>(Escrow.getHandlerStoragePath(handlerRef.handlerId))
        // Pubish an authorized capability to the inbox
        signer.inbox.publish(handlerInbox, name: inboxIdentifier, recipient: receiver)
    }

    execute {

    }
}