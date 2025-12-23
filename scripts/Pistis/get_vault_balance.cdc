import "FlowToken"
import "NonFungibleToken"
import "Mneme"


access(all)
fun main(address: Address, certificateID: UInt64): {String: AnyStruct} {
let metadata: {String: AnyStruct} = {}


    let account = getAccount(address)
    let collectionRef = account.capabilities.borrow<&Mneme.Collection>(Mneme.CollectionPublicPath)!
    let nftRef = collectionRef.borrowNFT(certificateID)! as! &Mneme.CertificateNFT
    metadata["balance"] = nftRef.vaultsDict[Type<@FlowToken.Vault>()]!.balance

    return metadata
}