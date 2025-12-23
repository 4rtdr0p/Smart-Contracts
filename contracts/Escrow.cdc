import "NonFungibleToken"
import "FungibleToken"
import "FlowToken"
import "FlowTransactionScheduler"


access(all) 
contract Escrow {
    

        // -----------------------------------------------------------------------
    /// Handler resource that implements the Scheduled Transaction interface
    access(all) resource Handler: FlowTransactionScheduler.TransactionHandler {

        access(self) var offerVault: @FlowToken.Vault
        access(self) var receipts: @[FlowTransactionScheduler.ScheduledTransaction]

        access(FlowTransactionScheduler.Execute) fun executeTransaction(id: UInt64, data: AnyStruct?) {

            // Determine delay for the next transaction (default 3 seconds if none provided)
            var delay: UFix64 = 60.0
            if data != nil {
                let t = data!.getType()
                if t.isSubtype(of: Type<UFix64>()) {
                    delay = data as! UFix64
                }
            }
            let future = getCurrentBlock().timestamp + delay
            let priority = FlowTransactionScheduler.Priority.Medium
            let executionEffort: UInt64 = 1000

            let estimate = FlowTransactionScheduler.estimate(
                data: data,
                timestamp: future,
                priority: priority,
                executionEffort: executionEffort
            )       

            assert(
                estimate.timestamp != nil || priority == FlowTransactionScheduler.Priority.Low,
                message: estimate.error ?? "estimation failed"
            )   

            // Withdraw FLOW fees from this resource's ownner account vault
            let fees <- self.offerVault.withdraw(amount: estimate.flowFee ?? 0.0) as! @FlowToken.Vault   

            // Issue a capability to the handler stored in this contract account
            let handlerCap = Escrow.account.capabilities.storage
                .issue<auth(FlowTransactionScheduler.Execute) &{FlowTransactionScheduler.TransactionHandler}>(/storage/Escrow)

            let receipt: @FlowTransactionScheduler.ScheduledTransaction <- FlowTransactionScheduler.schedule(
                handlerCap: handlerCap,
                data: data,
                timestamp: future,
                priority: priority,
                executionEffort: executionEffort,
                fees: <-fees
            )
            log("Loop transaction id: ".concat(receipt.id.toString()).concat(" at ").concat(receipt.timestamp.toString()))
            
            self.receipts.append(<- receipt)
        }

        init(offerVault: @FlowToken.Vault) {
            self.offerVault <- offerVault
            self.receipts <- []
        }
    }
}