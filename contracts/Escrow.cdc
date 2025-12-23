import "NonFungibleToken"
import "FungibleToken"
import "FlowToken"
import "FlowTransactionScheduler"


access(all) 
contract Escrow {

    access(self) var handlerId: UInt64

    access(all) entitlement Owner
    

    // -----------------------------------------------------------------------
    /// Handler resource that implements the Scheduled Transaction interface
    access(all) resource Handler: FlowTransactionScheduler.TransactionHandler {

        // RECEIPTS 
        ///./////.////
        access(self) let handlerId: UInt64
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
            // increment the handler id
            Escrow.handlerId = Escrow.handlerId + 1
            // set the handler id
            self.handlerId = Escrow.handlerId 
            self.offerVault <- offerVault
            self.receipts <- []
            let inboxIdentifier = "\(Escrow.account.address)_Escrow_Handler_\(self.handlerId)"
            // Get a cap to this handler resource
            let handlerCap = Escrow.account.capabilities.storage.issue<auth(Owner) &Handler>(Escrow.getHandlerStoragePath(self.handlerId))
            // Pubish an authorized capability to the inbox
            Escrow.account.inbox.publish(handlerCap, name: inboxIdentifier, recipient: receiver)

        }
    }

    //  Public helper functions 
    // function to get storage path for a handler
    // based on the handler id
    access(all) view fun getHandlerStoragePath(_ handlerId: UInt64): StoragePath {
        return StoragePath(identifier: "\(Escrow.account.address)_Escrow_Handler_\(handlerId)")!
    }

    init() {
        self.handlerId = 0
    } 
}