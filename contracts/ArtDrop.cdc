/*
*
*  This is an example implementation of a Flow Non-Fungible Token
*  using the V2 standard.
*  It is not part of the official standard but it assumed to be
*  similar to how many NFTs would implement the core functionality.
*
*  This contract does not implement any sophisticated classification
*  system for its NFTs. It defines a simple NFT with minimal metadata.
*
*/

import "NonFungibleToken"
import "FungibleToken"
import "FlowToken"
import "ViewResolver"
import "MetadataViews"
import "Pistis"

// import "CrossVMMetadataViews"
// import "EVM"

access(all) 
contract Mneme: NonFungibleToken {
    // -----------------------------------------------------------------------
    // Mneme contract-level fields.
    // These contain actual values that are stored in the smart contract.
    // -----------------------------------------------------------------------
    // Dictionary to hold general collection information
    access(self) let collectionInfo: {String: AnyStruct}  
    access(self) var artistEditions: {Address: [Int64]}
    access(self) var totalEditions: UInt64
    // -----------------------------------------------------------------------
    // Mneme account paths
    // -----------------------------------------------------------------------
	access(all) let CollectionStoragePath: StoragePath
	access(all) let CollectionPublicPath: PublicPath
    /// Path where the minter should be stored
    /// The standard paths for the collection are stored in the collection resource type
    access(all) let ArtDropStoragePath: StoragePath
    access(all) let ArtDropPublicPath: PublicPath
    access(all) let AdministratorStoragePath: StoragePath
    access(all) let ArtistStoragePath: StoragePath
    // -----------------------------------------------------------------------
    // Mneme Entitlements
    // ----------------------------------------------------------------------- 
    access(all) entitlement Admin
    access(all) entitlement AddArtist
    access(all) entitlement MintCertificateNFT

    /// Event to show when an NFT is minted
    access(all) event Minted(
        type: String,
        id: UInt64,
        uuid: UInt64,
        name: String,
        description: String
    )
    // -----------------------------------------------------------------------
    // Mneme contract-level Composite Type definitions
    // -----------------------------------------------------------------------
    // These are just *definitions* for Types that this contract
    // and other accounts can use. These definitions do not contain
    // actual stored values, but an instance (or object) of one of these Types
    // can be created by this contract that contains stored values.
    // -----------------------------------------------------------------------
    // Edition resource represents the Art's metadata 
    // and its rewards rules
    access(all) resource Edition {
        access(all) let id: UInt64
        access(all) let name: String
        access(all) let price: UFix64
        access(all) let type: String
        access(all) let story: String
        access(all) let dimensions: {String: String}
        access(all) let reprintLimit: Int64
        access(all) let artistAddress: Address
        access(all) var totalMinted: Int64

        access(all) let rewards: {String: AnyStruct}

        init(
            id: UInt64,
            name: String,
            price: UFix64,
            type: String,
            story: String,
            dimensions: {String: String},
            reprintLimit: Int64,
            artistAddress: Address) {

            self.name = name
            self.price = price
            self.id = id
            self.type = type
            self.story = story
            self.dimensions = dimensions
            self.reprintLimit = reprintLimit
            self.artistAddress = artistAddress
            self.rewards = {}
            self.totalMinted = 0
        }

        /// mintNFT mints a new NFT with a new ID
        /// and returns it to the calling context
        access(MintCertificateNFT) 
        fun mintCertificateNFT(thumbnail: String): @Mneme.CertificateNFT {
            pre {
                self.totalMinted < self.reprintLimit && self.reprintLimit != 0: "This edition has reached the reprint limit"
            }

            let metadata: {String: AnyStruct} = {}
            let currentBlock = getCurrentBlock()
            metadata["mintedBlock"] = currentBlock.height
            metadata["mintedTime"] = currentBlock.timestamp

            // this piece of metadata will be used to show embedding rarity into a trait
            metadata["foo"] = "bar"

            // create a new NFT
            var newNFT <- create CertificateNFT(
                id: UInt64(self.totalMinted),
                name: self.name,
                description: self.story,
                thumbnail: thumbnail,
                metadata: metadata
            )
            // increase the total minted count
            self.totalMinted = self.totalMinted + 1
            // emit the Minted event
            emit Minted(type: newNFT.getType().identifier,
                        id: newNFT.id,
                        uuid: newNFT.uuid,
                        name: newNFT.name,
                        description: newNFT.description
                        )
            // return the new NFT
            return <-newNFT
        }
    }
    

    /// We choose the name NFT here, but this type can have any name now
    /// because the interface does not require it to have a specific name any more
    access(all) resource CertificateNFT: NonFungibleToken.NFT, Pistis.Pool {
        access(all) let id: UInt64
        access(all) var vaultsDict: @{Type: {FungibleToken.Vault}}
        access(all) var vaultReceiverPath: {Type: PublicPath}
        access(all) let name: String
        access(all) let description: String
        access(all) let thumbnail: String 
        access(all) let royalties: MetadataViews.Royalty
        access(all) let metadata: {String: AnyStruct}
        
        init(
            id: UInt64,
            name: String,
            description: String,
            thumbnail: String,
            metadata: {String: AnyStruct}
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.thumbnail = thumbnail
            self.royalties = MetadataViews.Royalty(
                    receiver: getAccount(Mneme.account.address).capabilities.get<&FlowToken.Vault>(/public/flowTokenReceiver),
                    cut: 0.5,
                    description: "The deployer gets 5% of every secondary sale."
                )
            self.metadata = metadata
            self.vaultsDict <- {}
            self.vaultReceiverPath = {}
        }


        /// createEmptyCollection creates an empty Collection
        /// and returns it to the caller so that they can own NFTs
        /// @{NonFungibleToken.Collection}
        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <-Mneme.createEmptyCollection(nftType: Type<@Mneme.CertificateNFT>())

            
        }

        access(all) view fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Royalties>(),
                Type<MetadataViews.Editions>(),
                Type<MetadataViews.ExternalURL>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>(),
                Type<MetadataViews.Serial>(),
                Type<MetadataViews.Traits>(),
                Type<MetadataViews.EVMBridgedMetadata>()
            ]
        }

        access(all) fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.name,
                        description: self.description,
                        thumbnail: MetadataViews.HTTPFile(
                            url: self.thumbnail
                        )
                    )
                case Type<MetadataViews.Editions>():
                    // There is no max number of NFTs that can be minted from this contract
                    // so the max edition field value is set to nil
                    let editionInfo = MetadataViews.Edition(name: "Example NFT Edition", number: self.id, max: nil)
                    let editionList: [MetadataViews.Edition] = [editionInfo]
                    return MetadataViews.Editions(
                        editionList
                    )
                case Type<MetadataViews.Serial>():
                    return MetadataViews.Serial(
                        self.id
                    )
                case Type<MetadataViews.Royalties>():
                    return MetadataViews.Royalties(
                        [self.royalties]
                    )
                case Type<MetadataViews.ExternalURL>():
                    return MetadataViews.ExternalURL("https://example-nft.onflow.org/".concat(self.id.toString()))
                case Type<MetadataViews.NFTCollectionData>():
                    return Mneme.resolveContractView(resourceType: Type<@Mneme.CertificateNFT>(), viewType: Type<MetadataViews.NFTCollectionData>())
                case Type<MetadataViews.NFTCollectionDisplay>():
                    return Mneme.resolveContractView(resourceType: Type<@Mneme.CertificateNFT>(), viewType: Type<MetadataViews.NFTCollectionDisplay>())
                case Type<MetadataViews.Traits>():
                    // exclude mintedTime and foo to show other uses of Traits
                    let excludedTraits = ["mintedTime", "foo"]
                    let traitsView = MetadataViews.dictToTraits(dict: self.metadata, excludedNames: excludedTraits)

                    // mintedTime is a unix timestamp, we should mark it with a displayType so platforms know how to show it.
                    let mintedTimeTrait = MetadataViews.Trait(name: "mintedTime", value: self.metadata["mintedTime"]!, displayType: "Date", rarity: nil)
                    traitsView.addTrait(mintedTimeTrait)

                    // foo is a trait with its own rarity
                    let fooTraitRarity = MetadataViews.Rarity(score: 10.0, max: 100.0, description: "Common")
                    let fooTrait = MetadataViews.Trait(name: "foo", value: self.metadata["foo"], displayType: nil, rarity: fooTraitRarity)
                    traitsView.addTrait(fooTrait)
                    

                    return traitsView
                case Type<MetadataViews.EVMBridgedMetadata>():
                    // Implementing this view gives the project control over how the bridged NFT is represented as an
                    // ERC721 when bridged to EVM on Flow via the public infrastructure bridge.
                    // NOTE: If your NFT is a cross-VM NFT, meaning you control both your Cadence & EVM contracts and
                    //      registered your custom association with the VM bridge, it's recommended you use the 
                    //      CrossVMMetadata.EVMBytesMetadata view to define and pass metadata as EVMBytes into your
                    //      EVM contract at the time of bridging into EVM. For more information about cross-VM NFTs,
                    //      see FLIP-318: https://github.com/onflow/flips/issues/318

                    // Get the contract-level name and symbol values
                    let contractLevel = Mneme.resolveContractView(
                            resourceType: nil,
                            viewType: Type<MetadataViews.EVMBridgedMetadata>()
                        ) as! MetadataViews.EVMBridgedMetadata?

                    if let contractMetadata = contractLevel {
                        // Compose the token-level URI based on a base URI and the token ID, pointing to a JSON file. This
                        // would be a file you've uploaded and are hosting somewhere - in this case HTTP, but this could be
                        // IPFS, S3, a data URL containing the JSON directly, etc.
                        let baseURI = "https://example-nft.onflow.org/token-metadata/"
                        let uriValue = self.id.toString().concat(".json")

                        return MetadataViews.EVMBridgedMetadata(
                            name: contractMetadata.name,
                            symbol: contractMetadata.symbol,
                            uri: MetadataViews.URI(
                                baseURI: baseURI, // defining baseURI results in a concatenation of baseURI and value
                                value: self.id.toString().concat(".json")
                            )
                        )
                    } else {
                        return nil
                    }
/*                 case Type<CrossVMMetadataViews.EVMPointer>():
                    // This view is intended for NFT projects with corresponding NFT implementations in both Cadence and
                    // EVM. Resolving EVMPointer indicates the associated EVM implementation. Fully validating the
                    // cross-VM association would involve inspecting the associated EVM contract and ensuring that
                    // contract also points to the resolved Cadence type and contract address. For more information
                    // about cross-VM NFTs, see FLIP-318: https://github.com/onflow/flips/issues/318

                    return Mneme.resolveContractView(resourceType: self.getType(), viewType: view)
                case Type<CrossVMMetadataViews.EVMBytesMetadata>():
                    // This view is intended for Cadence-native NFTs with corresponding ERC721 implementations. By
                    // resolving, you're able to pass arbitrary metadata into your EVM contract whenever an NFT is
                    // bridged which can be useful for Cadence NFTs with dynamic metadata values.
                    // See FLIP-318 for more information about cross-VM NFTs: https://github.com/onflow/flips/issues/318

                    // Here we encoded the EVMBridgedMetadata URI and encode the string as EVM bytes, but you could pass any
                    // Cadence values that can be abi encoded and decode them in your EVM contract as you wish. Within
                    // your EVM contract, you can abi decode the bytes and update metadata in your ERC721 contract as
                    // you see fit.
                    let bridgedMetadata = (self.resolveView(Type<MetadataViews.EVMBridgedMetadata>()) as! MetadataViews.EVMBridgedMetadata?)!
                    let uri = bridgedMetadata.uri.uri()
                    let encodedURI = EVM.encodeABI([uri])
                    let evmBytes = EVM.EVMBytes(value: encodedURI)
                    return CrossVMMetadataViews.EVMBytesMetadata(bytes: evmBytes) */
            }
            return nil
        }
    }

    access(all) resource Collection: NonFungibleToken.Collection, Pistis.Loyalty {
        /// dictionary of NFT conforming tokens
        /// NFT is a resource type with an `UInt64` ID field
        access(all) var ownedNFTs: @{UInt64: {NonFungibleToken.NFT}}
        access(all) var loyaltyPoints: {Address: UFix64}

        init () {
            self.ownedNFTs <- {}
            self.loyaltyPoints = {}
            self.loyaltyPoints[Mneme.account.address] = 0.0
        }

        access(all) fun addVault(vaultType: Type, vault: @{FungibleToken.Vault}, id: UInt64, vaultReceiverPath: PublicPath) {
            let nft <- self.ownedNFTs.remove(key: id) as! @Mneme.CertificateNFT
            nft.addVault(vaultType: vaultType, vault: <- vault, vaultReceiverPath: vaultReceiverPath)
            self.ownedNFTs[id] <-! nft 
        } 

        access(all) fun depositToVault(id: UInt64, vaultType: Type, vaultDeposit: @{FungibleToken.Vault}) {
            let nft <- self.ownedNFTs.remove(key: id) as! @Mneme.CertificateNFT
            nft.depositToVault(vaultType: vaultType, vaultDeposit: <- vaultDeposit)
            self.ownedNFTs[id] <-! nft 
        } 

        // Withdraw from a vault
        access(all) fun withdrawFromVault(id: UInt64, vaultType: Type) {
            let nft <- self.ownedNFTs.remove(key: id) as! @Mneme.CertificateNFT
            let newVault <- nft.withdrawFromVault(id: id, vaultType: vaultType)
            let account = getAccount(self.owner!.address)
            let vault <- newVault.remove(key: newVault.keys[0])!
            let receiverRef = account.capabilities.borrow<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)!
            receiverRef.deposit(from: <- vault.withdraw(amount: vault.balance))
            destroy newVault
            destroy vault
            self.ownedNFTs[id] <-! nft 
        }

        /// getSupportedNFTTypes returns a list of NFT types that this receiver accepts
        access(all) view fun getSupportedNFTTypes(): {Type: Bool} {
            let supportedTypes: {Type: Bool} = {}
            supportedTypes[Type<@Mneme.CertificateNFT>()] = true
            return supportedTypes
        }

        /// Returns whether or not the given type is accepted by the collection
        /// A collection that can accept any type should just return true by default
        access(all) view fun isSupportedNFTType(type: Type): Bool {
            return type == Type<@Mneme.CertificateNFT>()
        }

        /// withdraw removes an NFT from the collection and moves it to the caller
        access(NonFungibleToken.Withdraw) fun withdraw(withdrawID: UInt64): @{NonFungibleToken.NFT} {
            let token <- self.ownedNFTs.remove(key: withdrawID)
                ?? panic("Mneme.Collection.withdraw: Could not withdraw an NFT with ID "
                        .concat(withdrawID.toString())
                        .concat(". Check the submitted ID to make sure it is one that this collection owns."))

            // Based on NFT's edition and other factors, substract loyalty points from the collector
            let collectorLoyalty = self.owner!.capabilities.borrow<&Mneme.Collection>(Mneme.CollectionPublicPath)!
            collectorLoyalty.substractLoyalty(address: Mneme.account.address, loyaltyPoints: 1.0)

            return <-token
        }

        /// deposit takes a NFT and adds it to the collections dictionary
        /// and adds the ID to the id array
        access(all) fun deposit(token: @{NonFungibleToken.NFT}) {
            let token <- token as! @Mneme.CertificateNFT
            let id = token.id

            // Based on NFT's edition and other factors, add loyalty points to the collector
            let collectorLoyalty = self.owner!.capabilities.borrow<&Mneme.Collection>(Mneme.CollectionPublicPath)!
            collectorLoyalty.addLoyalty(address: Mneme.account.address, loyaltyPoints: 1.0)

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[token.id] <- token

            destroy oldToken

            // This code is for testing purposes only
            // Do not add to your contract unless you have a specific
            // reason to want to emit the NFTUpdated event somewhere
            // in your contract
            let authTokenRef = (&self.ownedNFTs[id] as auth(NonFungibleToken.Update) &{NonFungibleToken.NFT}?)!
            //authTokenRef.updateTransferDate(date: getCurrentBlock().timestamp)
            Mneme.emitNFTUpdated(authTokenRef)
        }

        /// getIDs returns an array of the IDs that are in the collection
        access(all) view fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        /// Gets the amount of NFTs stored in the collection
        access(all) view fun getLength(): Int {
            return self.ownedNFTs.length
        }

        access(all) view fun borrowNFT(_ id: UInt64): &{NonFungibleToken.NFT}? {
            return &self.ownedNFTs[id]
        }

        /// Borrow the view resolver for the specified NFT ID
        access(all) view fun borrowViewResolver(id: UInt64): &{ViewResolver.Resolver}? {
            if let nft = &self.ownedNFTs[id] as &{NonFungibleToken.NFT}? {
                return nft as &{ViewResolver.Resolver}
            }
            return nil
        }

        /// createEmptyCollection creates an empty Collection of the same type
        /// and returns it to the caller
        /// @return A an empty collection of the same type
        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <-Mneme.createEmptyCollection(nftType: Type<@Mneme.CertificateNFT>())
        }
    }
    // -----------------------------------------------------------------------
    // Mneme public functions
    // -----------------------------------------------------------------------
    // Get all the Artists and their Editions
    access(all) view fun getAllArtists(): {Address: [Int64]} {
        return self.artistEditions
    }
    
    // Get an Edition's metadata
    // parameters: artistAddress: Address, editionId: UInt64
    access(all) view fun  getEditionMetadata(artistAddress: Address, editionId: UInt64): &Mneme.Edition? {
        pre {
            self.artistEditions[artistAddress] != nil: "This artist does not exist"
        }
        let storageIdentifier = "ArtDrop/\(artistAddress)/\(Mneme.totalEditions)"
        let publicPath = PublicPath(identifier: storageIdentifier)!

        let editionRef = Mneme.account.capabilities.borrow<&Mneme.Edition>(publicPath)!
        return editionRef
    }
    /// createEmptyCollection creates an empty Collection for the specified NFT type
    /// and returns it to the caller so that they can own NFTs
    access(all) fun createEmptyCollection(nftType: Type): @{NonFungibleToken.Collection} {
        return <- create Collection()
    }

    /// Function that returns all the Metadata Views implemented by a Non Fungible Token
    ///
    /// @return An array of Types defining the implemented views. This value will be used by
    ///         developers to know which parameter to pass to the resolveView() method.
    ///
    access(all) view fun getContractViews(resourceType: Type?): [Type] {
        return [
            Type<MetadataViews.NFTCollectionData>(),
            Type<MetadataViews.NFTCollectionDisplay>(),
            Type<MetadataViews.EVMBridgedMetadata>()
        ]
    }

    /// Function that resolves a metadata view for this contract.
    ///
    /// @param view: The Type of the desired view.
    /// @return A structure representing the requested view.
    ///
    access(all) fun resolveContractView(resourceType: Type?, viewType: Type): AnyStruct? {
        switch viewType {
            case Type<MetadataViews.NFTCollectionData>():
                let collectionData = MetadataViews.NFTCollectionData(
                    storagePath: self.CollectionStoragePath,
                    publicPath: self.CollectionPublicPath,
                    publicCollection: Type<&Mneme.Collection>(),
                    publicLinkedType: Type<&Mneme.Collection>(),
                    createEmptyCollectionFunction: (fun(): @{NonFungibleToken.Collection} {
                        return <-Mneme.createEmptyCollection(nftType: Type<@Mneme.CertificateNFT>())
                    })
                )
                return collectionData
            case Type<MetadataViews.NFTCollectionDisplay>():
                let media = MetadataViews.Media(
                    file: MetadataViews.HTTPFile(
                        url: "https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg"
                    ),
                    mediaType: "image/svg+xml"
                )
                return MetadataViews.NFTCollectionDisplay(
                    name: "The Example Collection",
                    description: "This collection is used as an example to help you develop your next Flow NFT.",
                    externalURL: MetadataViews.ExternalURL("https://example-nft.onflow.org"),
                    squareImage: media,
                    bannerImage: media,
                    socials: {
                        "twitter": MetadataViews.ExternalURL("https://twitter.com/flow_blockchain")
                    }
                )
            case Type<MetadataViews.EVMBridgedMetadata>():
                // Implementing this view gives the project control over how the bridged NFT is represented as an ERC721
                // when bridged to EVM on Flow via the public infrastructure bridge.

                // Compose the contract-level URI. In this case, the contract metadata is located on some HTTP host,
                // but it could be IPFS, S3, a data URL containing the JSON directly, etc.
                return MetadataViews.EVMBridgedMetadata(
                    name: "Mneme",
                    symbol: "XMPL",
                    uri: MetadataViews.URI(
                        baseURI: nil, // setting baseURI as nil sets the given value as the uri field value
                        value: "https://example-nft.onflow.org/contract-metadata.json"
                    )
                )
/*             case Type<CrossVMMetadataViews.EVMPointer>():
                // This view is intended for NFT projects with corresponding NFT implementations in both Cadence and
                // EVM. Resolving EVMPointer indicates the associated EVM implementation. Fully validating the
                // cross-VM association would involve inspecting the associated EVM contract and ensuring that contract
                // also points to the resolved Cadence type and contract address. For more information about cross-VM
                // NFTs, see FLIP-318: https://github.com/onflow/flips/issues/318

                // Assigning a dummy EVM address and deserializing. Implementations would want to declare the actual
                // EVM address corresponding to their corresponding ERC721. If using a proxy in your EVM contracts, this
                // address should be your proxy's address.
                let evmContractAddress = EVM.addressFromString(
                        "0x1234565789012345657890123456578901234565"
                    )
                // Since this NFT is distributed in Cadence, it's declared as Cadence-native
                let nativeVM = CrossVMMetadataViews.VM.Cadence
                return CrossVMMetadataViews.EVMPointer(
                    cadenceType: Type<@Mneme.CertificateNFT>(),
                    cadenceContractAddress: self.account.address,
                    evmContractAddress: evmContractAddress,
                    nativeVM: nativeVM
                ) */
        }
        return nil
    }

    // Administrator resource
    access(all) resource Administrator {
        // Function to create a new Edition resource
        access(all) fun createEdition(
            name: String,
            price: UFix64,
            type: String,
            story: String,
            dimensions: {String: String},
            reprintLimit: Int64,
            artistAddress: Address) {
            if Mneme.artistEditions[artistAddress] == nil {
                Mneme.artistEditions[artistAddress] = []
            }
            // increase the total editions count
            Mneme.totalEditions = Mneme.totalEditions + 1

            let storageIdentifier = "ArtDrop/\(artistAddress)/\(Mneme.totalEditions)"
            let storagePath = StoragePath(identifier: storageIdentifier)!
            let publicPath = PublicPath(identifier: storageIdentifier)!

            // create a new edition resource
            let newEdition <- create Edition(id: Mneme.totalEditions, name: name, price: price, type: type, story: story, dimensions: dimensions, reprintLimit: reprintLimit, artistAddress: artistAddress)

            // save the new edition to storage
            Mneme.account.storage.save(<-newEdition, to: storagePath)
            // create a public capability for the edition
            let editionCap = Mneme.account.capabilities.storage.issue<&Mneme.Edition>(storagePath)
            Mneme.account.capabilities.publish(editionCap, at: publicPath)
            // add the new edition to the artist's editions
            Mneme.artistEditions[artistAddress]!.append(Int64(Mneme.totalEditions))
            // return <- newEdition
        }

    }


    init() {
        self.collectionInfo = {}
        self.artistEditions = {}
        self.totalEditions = 0

        let identifier = "Mneme_\(self.account.address))"
        // Set the named paths
        self.ArtDropStoragePath = StoragePath(identifier: identifier)!
        self.ArtDropPublicPath = PublicPath(identifier: identifier)!
        self.AdministratorStoragePath = StoragePath(identifier: "\(identifier)Administrator")!
        self.CollectionStoragePath = StoragePath(identifier: identifier)!
        self.CollectionPublicPath = PublicPath(identifier: identifier)!
        self.ArtistStoragePath = StoragePath(identifier: "\(identifier)Artist")!

        // Create a Collection resource and save it to storage
        let collection <- create Collection()
        self.account.storage.save(<-collection, to: self.CollectionStoragePath)
        // create a public capability for the collection
        let collectionCap = self.account.capabilities.storage.issue<&Mneme.Collection>(self.CollectionStoragePath)
        self.account.capabilities.publish(collectionCap, at: self.CollectionPublicPath)
        // Create an Administrator resource and save it to storage
        let administrator <- create Administrator()
        self.account.storage.save(<-administrator, to: self.AdministratorStoragePath)
    }
}