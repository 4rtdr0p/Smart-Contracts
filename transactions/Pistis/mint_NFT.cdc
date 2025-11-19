import "Pistis"
import "ArtDrop"
import "NonFungibleToken"
import "MetadataViews"

// This transaction is for any user to create a new Project 
// on the proof-of-support platform 

transaction(

    newNFTName: String,
    newNFTDescription: String,
    newNFTPreview: String,

) {

    /// Reference to the receiver's collection
    let recipientCollectionRef: &{NonFungibleToken.Receiver}

    prepare(signer:auth(BorrowValue) &Account) {
        let collectionData = ArtDrop.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("Could not resolve NFTCollectionData view. The ArtDrop contract needs to implement the NFTCollectionData Metadata view in order to execute this transaction")

        // Borrow the recipient's public NFT collection reference
        self.recipientCollectionRef = getAccount(signer.address).capabilities.borrow<&{NonFungibleToken.Receiver}>(collectionData.publicPath)
            ?? panic("The recipient does not have a NonFungibleToken Receiver at "
                    .concat(collectionData.publicPath.toString())
                    .concat(" that is capable of receiving an NFT.")
                    .concat("The recipient must initialize their account with this collection and receiver first!"))

    }
    execute {   

        let newNFT <- ArtDrop.mintNFT(name: newNFTName, description: newNFTDescription, thumbnail: newNFTPreview)
        self.recipientCollectionRef.deposit(token: <- newNFT)

    }
}