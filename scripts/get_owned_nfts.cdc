import "Mneme"
import "MetadataViews"

access(all) fun main(account: Address): [AnyStruct]?  {
 
    let account = getAccount(account)
    let answer: [AnyStruct]  = [] 
    var nft: AnyStruct = nil

        
    let cap = account.capabilities.borrow<&Mneme.Collection>(Mneme.CollectionPublicPath)!
    log(cap)

    let ids = cap.getIDs()


    for id in ids {
        // Ref to the Mneme to get the Card's metadata
        let nftRef = cap.borrowNFT(id)!
        let resolver = cap.borrowViewResolver(id: id)!
        let displayView: MetadataViews.Display = MetadataViews.getDisplay(resolver)!
        let serialView = MetadataViews.getSerial(resolver)!
        let traits = MetadataViews.getTraits(resolver)!



        

        nft = {
        "display": displayView,
        "nftID": nftRef.id,
        "serial": serialView,
        "traits": traits
        }
        
        answer.append(nft
        )
    }
    return answer 
}