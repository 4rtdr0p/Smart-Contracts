

access(all)
fun main(account: Address): AnyStruct? {


    let account = getAccount(account)
    let storage = account.storage.storagePaths
    return storage
}