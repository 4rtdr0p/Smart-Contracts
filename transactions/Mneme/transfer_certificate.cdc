import "NonFungibleToken"
import "MetadataViews"
import "Mneme"

/// Can pass in any contract address and name and NFT type name
/// This lets you choose the token you want to send because
/// the transaction gets the metadata from the provided contract.
///
/// @param to: The address to transfer the token to
/// @param id: The id of token to transfer
/// @param nftTypeIdentifier: The type identifier name of the NFT type you want to transfer
            /// Ex: "A.0b2a3299cc857e29.TopShot.NFT"
///
transaction(to: Address, id: UInt64) {

    // The NFT resource to be transferred
    let tempNFT: @{NonFungibleToken.NFT}


    prepare(signer: auth(BorrowValue) &Account) {

        // borrow a reference to the signer's NFT collection
        let withdrawRef = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>(
                from: Mneme.CollectionStoragePath
            ) ?? panic("The signer does not store a NFT Collection object at the path \(Mneme.CollectionStoragePath)"
                        .concat("The signer must initialize their account with this collection first!"))

        self.tempNFT <- withdrawRef.withdraw(withdrawID: id)
    }

    execute {
        // get the recipients public account object
        let recipient = getAccount(to)

        // borrow a public reference to the receivers collection
        let receiverRef = recipient.capabilities.borrow<&{NonFungibleToken.Receiver}>(Mneme.CollectionPublicPath)
            ?? panic("The recipient does not have a NonFungibleToken Receiver at \(Mneme.CollectionPublicPath)")

        // Deposit the NFT to the receiver
        receiverRef.deposit(token: <-self.tempNFT)
    }
}