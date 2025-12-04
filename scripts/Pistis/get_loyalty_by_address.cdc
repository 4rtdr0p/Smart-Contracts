
import "Mneme" 



access(all)
fun main(address: Address): UFix64 {
    let account = getAccount(address)
    let collectionRef = account.capabilities.borrow<&Mneme.Collection>(Mneme.CollectionPublicPath)!
    let loyaltyPoints = collectionRef.loyaltyPoints[address]!

    return loyaltyPoints
}