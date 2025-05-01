import "Mneme"
import "FindViews"
import "MetadataViews"

access(all) fun main(address: Address): FindViews.ViewReadPointer {
    let collection = Mneme.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
        ?? panic("ViewResolver does not resolve NFTCollectionData view")

    let test = FindViews.createViewReadPointer(address: address, path: Mneme.CollectionPublicPath, id: 1)

    return test
}