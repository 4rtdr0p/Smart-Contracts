import "FlowToken"
import "NonFungibleToken"
import "ArtDrop"


access(all)
fun main(address: Address): {String: AnyStruct} {
let metadata: {String: AnyStruct} = {}


    let account = getAccount(address)
    let collectionRef = account.capabilities.borrow<&ArtDrop.Collection>(ArtDrop.CollectionPublicPath)!
    let id = collectionRef.getIDs()[0]
    let nftRef = collectionRef.borrowNFT(id)! as! &ArtDrop.NFT
    metadata["balance"] = nftRef.vaultsDict[Type<@FlowToken.Vault>()]!.balance

    return metadata
}