
import "FlowToken"
// get flow token balance of an account
access(all)
fun main(address: Address): UFix64 {
  let account = getAccount(address)
  let balance = account.balance
  return balance
} 