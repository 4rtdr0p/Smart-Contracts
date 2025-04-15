import "Pistis"
import "MetadataViews"
import "Mneme"

// This transaction is for any user to create a new Project 
// on the proof-of-support platform 

transaction(newProjectName: String) {

    prepare(signer: &Account) {

    }
    execute {
        // let metadata = Mneme.resolveContractView(resourceType: resourceType, viewType: viewType)
        let type = Type<@Mneme.NFT>()
        let cap = 
        Pistis.createProject(projectName: newProjectName, metadata: type, nftCap: )
    }
}