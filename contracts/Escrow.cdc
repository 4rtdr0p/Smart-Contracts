import "NonFungibleToken"
import "FungibleToken"
import "FlowToken"
import "FlowTransactionScheduler"


access(all) 
contract Escrow {

    access(all) let handlerStoragePath: StoragePath

    access(all) entitlement Owner
    

    // -----------------------------------------------------------------------
    /// Handler resource that implements the Scheduled Transaction interface
    access(all) resource Handler: FlowTransactionScheduler.TransactionHandler {

        access(self) var offerVault: @FlowToken.Vault
        access(self) var receipts: @[FlowTransactionScheduler.ScheduledTransaction]

        access(FlowTransactionScheduler.Execute) fun executeTransaction(id: UInt64, data: AnyStruct?) {
            pre {
                self.offerVault.balance > 0.0: "Offer vault is empty"
            }
            let balance <- self.offerVault.withdraw(amount: self.offerVault.balance) as! @FlowToken.Vault 
            let owner = getAccount(self.owner!.address)
            let vault = owner.capabilities.borrow<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)!.deposit(from: <- balance.withdraw(amount: balance.balance))
            destroy balance

        }

        // Function to withdraw funds from the offer vault
        // this is called when the offer is accepted
        access(Owner) fun withdrawFunds(): @FlowToken.Vault {
            pre {
                self.offerVault.balance > 0.0: "Offer vault is empty"
            }
            let balance <- self.offerVault.withdraw(amount: self.offerVault.balance) as! @FlowToken.Vault  
            return <- balance
        }

        init(
            offerVault: @FlowToken.Vault,
            receiver: Address,
            ) {
            self.offerVault <- offerVault
            self.receipts <- []
            let storageIdentifier = "\(Escrow.account.address)_Escrow_Handler_\(receiver)"
            // Get a cap to this handler resource
            let handlerCap = Escrow.account.capabilities.storage.issue<auth(Owner) &Handler>(Escrow.handlerStoragePath)
            // Pubish an authorized capability to the inbox
            Escrow.account.inbox.publish(handlerCap, name: storageIdentifier, recipient: receiver)

        }
    }

    init() {
        let storageIdentifier = "\(Escrow.account.address)_Escrow_Handler"
        self.handlerStoragePath = StoragePath(identifier: storageIdentifier)!
    } 
}