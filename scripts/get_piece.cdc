
import "FlowToken"
// get flow token balance of an account
access(all)
fun main(account: Address): UFix64 {
  let account = getAccount(account)
  let balance = account.balance
  return balance
} 

    access(all) resource interface Pool {
        access(all) var vaultsDict: @{Type: {FungibleToken.Vault}}
        // store the vault receiver reference
        access(all) var vaultReceiverPath: {Type: PublicPath}

        access(all) fun addVault(vaultType: Type, vault: @{FungibleToken.Vault}, vaultReceiverPath: PublicPath) {
            pre {
                vaultType.isSubtype(of: Type<@{FungibleToken.Vault}>()) == true: "Type is not a subtype of FungibleToken.Vault"
            }

            let oldVault <- self.vaultsDict[vaultType] <- vault
            self.vaultReceiverPath[vaultType] = vaultReceiverPath
            destroy oldVault
        }

        access(all) view fun getVaultTypes(): [Type] {  

            return self.vaultsDict.keys
        }

        // function to deposit 
        access(all) fun depositToVault( vaultType: Type, vaultDeposit: @{FungibleToken.Vault}) {
            pre {
                self.vaultsDict[vaultType] != nil: "There's no vault of this type"
            }
            let vault <- self.vaultsDict.remove(key: vaultType)!
            vault.deposit(from: <- vaultDeposit.withdraw(amount: vaultDeposit.balance))
            self.vaultsDict[vaultType] <-! vault 

            destroy vaultDeposit
        }

        access(all) fun withdrawFromVault(id: UInt64, vaultType: Type): @{PublicPath: {FungibleToken.Vault}} {
            pre {
                self.vaultsDict[vaultType] != nil: "There's no vault of this type"
            }

            let oldVault <- self.vaultsDict.remove(key: vaultType)!

            let newVault <- oldVault.withdraw(amount: oldVault.balance)
            // return the old vault to the dictionary
            self.vaultsDict[vaultType] <-! oldVault
            let result: @{PublicPath: {FungibleToken.Vault}} <- {}
            result[self.vaultReceiverPath[vaultType]!] <-! newVault

            return <- result
        } 
    } 