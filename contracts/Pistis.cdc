// MADE BY: Noah Naizir

// This contract is for Pistis, a proof of support platform
// built on Flow. 

// Pistis (Πίστις) is not a goddess in the traditional Olympian sense
// but rather a personified spirit (daimona) representing:
// Good Faith, Trust, Loyalty and Reliability

// She is the embodiment of belief between people 
// the social and moral glue of contracts, pacts, and promises. 
// In early Greek society, Pistis wasn't just religious faith — 
// it was interpersonal and civic trust.

// Pistis is a proof-of-support protocol where:

// Collectors pledge soulbound tokens as a form of trust in creators. (Pledged trust/faith)
// Artists distribute rewards in return, honoring loyalty. (Proof of loyalty & belief)
// Multipliers reflect belief over time, rewarding early conviction. (Honoring those who believed)
// It's a trust economy based on On—chain Provenance and that's exactly what Pistis governs.

import "FungibleToken"
import "FlowToken"
import "NonFungibleToken"
import "ViewResolver"
import "MetadataViews" 
import "ExampleToken" 
// import "FindViews"


// Right now, I just need this interface to manage an NFT as a pool

// For that, I need the resource to hold a Token Vault (as the pool)
access(all) 
contract interface Pistis {

    access(all) event LoyaltyAdded(address: Address, loyaltyPoints: UFix64)

  //  access(all) entitlement Withdraw

    /**
     * The Pool is a resource that holds a dictionary of vaults
     * and a dictionary of vault receiver paths
     * it also has a function to add a vault to the dictionary
     * and a function to deposit to a vault
     * and a function to withdraw from a vault
     */

    access(all) resource interface Loyalty {
        access(all) var loyaltyPoints: {Address: UFix64}
        
        access(all) fun addLoyalty(address: Address, loyaltyPoints: UFix64) {
            if self.loyaltyPoints[address] == nil {
                self.loyaltyPoints[address] = 0.0
            }
            self.loyaltyPoints[address] = self.loyaltyPoints[address]! + loyaltyPoints
            emit LoyaltyAdded(address: address, loyaltyPoints: loyaltyPoints)
        }

        access(all) fun substractLoyalty(address: Address, loyaltyPoints: UFix64) {
            self.loyaltyPoints[address] = self.loyaltyPoints[address]! - loyaltyPoints
        }

        access(all) fun getLoyalty(address: Address): UFix64 {
            return self.loyaltyPoints[address]!
        }
        
        access(all) fun getLoyaltyPoints(): {Address: UFix64} {
            return self.loyaltyPoints
        }

        access(all) fun getLoyaltyPointsByAddress(address: Address): UFix64 {
            return self.loyaltyPoints[address]!
        }
        

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

}