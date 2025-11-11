import "Pistis"
import "ExampleNFT"

// This transaction is for any user to create a new Project 
// on the proof-of-support platform 

transaction(

    newNFTName: String,
    newNFTDescription: String,
    newNFTPreview: String,

) {

    prepare(signer:auth(BorrowValue) &Account) {


    }
    execute {   

        let newNFT <- ExampleNFT.mintNFT()
        destroy newNFT
    }
}