// MADE BY: Noah Naizir

// This contract is for Pistis, a proof of support platform
// built on Flow. 

// Pistis (Πίστις) is not a goddess in the traditional Olympian sense
// but rather a personified spirit (daimona) representing:
// Good Faith, Trust, Loyalty and Reliability

// She is the embodiment of belief between people 
// the social and moral glue of contracts, pacts, and promises. 
// In early Greek society, Pistis wasn't just religious faith — 
// it was interpersonal and civic trust.

// Pistis is a proof-of-support protocol where:

// Collectors pledge soulbound tokens as a form of trust in creators. (Pledged trust/faith)
// Artists distribute rewards in return, honoring loyalty. (Proof of loyalty & belief)
// Multipliers reflect belief over time, rewarding early conviction. (Honoring those who believed)
// It's a trust economy based on On—chain Provenance and that's exactly what Pistis governs.

import "FungibleToken"
import "FlowToken"
import "NonFungibleToken"
import "ViewResolver"
import "MetadataViews" 
import "FindViews"

access(all) 
contract Pistis: NonFungibleToken, ViewResolver {
    // -----------------------------------------------------------------------
    // Pistis contract-level fields.
    // These contain actual values that are stored in the smart contract.
    // -----------------------------------------------------------------------
    // Dictionary to hold general collection information
    access(self) let collectionInfo: {String: AnyStruct}  
    // Dictionary mapping projectNames to the poolID        
    access(self) let pools: {String: UInt64}

    // Track of total supply of Pistis(support) NFTs
    access(all) var totalSupply: UInt64
    // Track of total amount of Projects on Pistis
    access(all) var totalPools: UInt64
    // Track of total amount of MetadataStructs on Pistis
    access(all) var totalMetadatas: UInt64
    // -----------------------------------------------------------------------
    // Pistis contract Events
    // ----------------------------------------------------------------------- 
    access(all) event ContractInitialized()
    access(all) event Withdraw(id: UInt64, from: Address?)
	access(all) event Deposit(id: UInt64, to: Address?)
    access(all)
    event PoolCreated(
        id: UInt64,
        poolCreator: Address,
        soulProject: String,
        soulSupply: UFix64
        )

    // -----------------------------------------------------------------------
    // Pistis account paths
    // -----------------------------------------------------------------------
	access(all) let CollectionStoragePath: StoragePath
	access(all) let CollectionPublicPath: PublicPath
    access(all) let PoolStoragePath: StoragePath
    access(all) let PoolPublicPath: PublicPath

    // -----------------------------------------------------------------------
    // Pistis contract-level Composite Type definitions
    // -----------------------------------------------------------------------

    access(all) resource interface PoolStoragePublic {
        access(all) fun getPoolMetadata(poolName: String): MetadataStruct
        access(all) fun getPools(): {String: MetadataStruct}
    }

    // Resource used to store Pools metadatas
    access(all) resource PoolStorage {
        // mapping of metadatas to their IDs
        access(all) let pools: {String: MetadataStruct}

        init() {
            self.pools = {}
        }

        // Functionality around the resource    
        //

        // Add new Metadata to the Storage
        access(all) fun addPool(poolName: String, newMetadata: MetadataStruct) {
            self.pools[poolName] = newMetadata
        }

        access(all) fun getPools(): {String: MetadataStruct} {
            return self.pools
        }
    }

    // Struct used to copy a Project's NFT metadata
    // and save it inside Pistis' storage

    access(all) struct MetadataStruct {
        access(all) let id: UInt64
        // Project to which this Metadata belongs to
        access(all) let projectName: String  
        access(all) let nftType: Type
        access(all) let nftRef: Capability<&{NonFungibleToken.NFT}>

        init(_ projectName: String,_ nftType: Type, _ metadataTraits: Capability<&{NonFungibleToken.NFT}>) {
/*             pre {
                Pistis.projects[projectName] != nil: "There's no project on Pistis named: ".concat(projectName)
            } */
            self.projectName = projectName
            self.nftType = nftType
            self.nftRef = metadataTraits
            // Increment the global Metadatas IDs
            Pistis.totalMetadatas = Pistis.totalMetadatas + 1
            self.id = Pistis.totalMetadatas
        }
    }

    /// The resource that represents a VenezulaNFT
	access(all) resource NFT: NonFungibleToken.NFT {
        access(all) let id: UInt64
        access(all) let metadata: AnyStruct

        init() {
            // Increment the global Cards IDs
            Pistis.totalSupply = Pistis.totalSupply + 1
            self.id = Pistis.totalSupply
            self.metadata = {"AnyStruct": 2}
        }

        /// createEmptyCollection creates an empty Collection
        /// and returns it to the caller so that they can own NFTs
        /// @{NonFungibleToken.Collection}
        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <- Pistis.createEmptyCollection(nftType: Type<@Pistis.NFT>())
        }
        // Standard to return NFT's metadata
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
        // Standard for resolving Views
        access(all) fun resolveView(_ view: Type): AnyStruct? {
            	let metadata = self.metadata
                switch view {
				case Type<MetadataViews.Display>():
					return MetadataViews.Display(
						name: "Card Name",
						description: "Card Description",
						thumbnail: MetadataViews.HTTPFile( 
            				url: "https://bafybeiceaod6tlnx36curr5fheppn43yuum42iuqodwnd4ve3hfsncagly.ipfs.dweb.link?filename=u8583739436_Create_a_logo_with_the_letter_V._This_illustrated_608e624a-bc77-4ad8-b2bd-ebda78890729_0.png"
            			)
					)
				case Type<MetadataViews.Traits>():
					return MetadataViews.dictToTraits(dict: {"String": 2}, excludedNames: nil)
				case Type<MetadataViews.NFTView>():
					return MetadataViews.NFTView(
						id: self.id,
						uuid: self.uuid,
						display: self.resolveView(Type<MetadataViews.Display>()) as! MetadataViews.Display?,
						externalURL: self.resolveView(Type<MetadataViews.ExternalURL>()) as! MetadataViews.ExternalURL?,
						collectionData: self.resolveView(Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?,
						collectionDisplay: self.resolveView(Type<MetadataViews.NFTCollectionDisplay>()) as! MetadataViews.NFTCollectionDisplay?,
						royalties: self.resolveView(Type<MetadataViews.Royalties>()) as! MetadataViews.Royalties?,
						traits: self.resolveView(Type<MetadataViews.Traits>()) as! MetadataViews.Traits?
					)
				case Type<MetadataViews.NFTCollectionData>():
					return Pistis.resolveContractView(resourceType: Type<@Pistis.NFT>(), viewType: Type<MetadataViews.NFTCollectionData>())
        		case Type<MetadataViews.ExternalURL>():
        			return Pistis.getCollectionAttribute(key: "website") as! MetadataViews.ExternalURL
		        case Type<MetadataViews.NFTCollectionDisplay>():
					return Pistis.resolveContractView(resourceType: Type<@Pistis.NFT>(), viewType: Type<MetadataViews.NFTCollectionDisplay>())
				case Type<MetadataViews.Medias>():
                    let metadata = 10
					if metadata != nil {
						return MetadataViews.Medias(
							[
								MetadataViews.Media(
									file: MetadataViews.HTTPFile(
										url: "metadata.embededHTML"
									),
									mediaType: "html"
								)
							]
						)
					}
        		case Type<MetadataViews.Royalties>():
          			return MetadataViews.Royalties([
            			MetadataViews.Royalty(
              				receiver: getAccount(Pistis.account.address).capabilities.get<&FlowToken.Vault>(/public/flowTokenReceiver),
              				cut: 0.5, // 5% royalty on secondary sales
              				description: "The deployer gets 5% of every secondary sale."
            			)
          			])
				case Type<MetadataViews.Serial>():
					return MetadataViews.Serial(
                        // GOTTA FIX
						0
					)
			}
			return nil
        }
    }
    // Collection is a resource that every user who owns NFTs 
    // will store in their account to manage their NFTS
    //
	access(all) resource Collection: NonFungibleToken.Collection {
        // *** Collection Variables *** //
		access(all) var ownedNFTs: @{UInt64: {NonFungibleToken.NFT}}
        // *** Collection Constructor *** //
        init () {
			self.ownedNFTs <- {}
		}
        // *** Collection Functions *** //

        /// Returns a list of NFT types that this receiver accepts
        access(all) view fun getSupportedNFTTypes(): {Type: Bool} {
            let supportedTypes: {Type: Bool} = {}
            supportedTypes[Type<@Pistis.NFT>()] = true
            return supportedTypes
        }
        /// Returns whether or not the given type is accepted by the collection
        /// A collection that can accept any type should just return true by default
        access(all) view fun isSupportedNFTType(type: Type): Bool {
            return type == Type<@Pistis.NFT>()
        }
		// Withdraw removes a Pistis from the collection and moves it to the caller(for Trading)
		access(NonFungibleToken.Withdraw) fun withdraw(withdrawID: UInt64): @{NonFungibleToken.NFT} {
			let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("This Collection doesn't own a Pistis by id: ".concat(withdrawID.toString()))

			emit Withdraw(id: token.id, from: self.owner?.address)

			return <-token
		}
		// Deposit takes a Pistis and adds it to the collections dictionary
		// and adds the ID to the id array
		access(all) fun deposit(token: @{NonFungibleToken.NFT}) {
			let newPistis <- token as! @NFT
			let id: UInt64 = newPistis.id
			// Add the new Pistis to the dictionary
            let oldPistis <- self.ownedNFTs[id] <- newPistis
            // Destroy old Pistis in that slot
            destroy oldPistis

			emit Deposit(id: id, to: self.owner?.address)
		}

		// GetIDs returns an array of the IDs that are in the collection
		access(all) view fun getIDs(): [UInt64] {
			return self.ownedNFTs.keys
		}
        /// Gets the amount of NFTs stored in the collection
        access(all) view fun getLength(): Int {
            return self.ownedNFTs.length
        }

		// BorrowNFT gets a reference to an NFT in the collection
		access(all) view fun borrowNFT(_ id: UInt64): &{NonFungibleToken.NFT}? {
			return &self.ownedNFTs[id]
		}

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
            return <-Pistis.createEmptyCollection(nftType: Type<@Pistis.NFT>())
        }
    }

    // -----------------------------------------------------------------------
    // Pistis Generic or Standard public "transaction" functions
    // -----------------------------------------------------------------------
    
    // Function to create a new Project
    access(all) fun createPool(poolName: String, metadataStruct: MetadataStruct) {
        pre {
            Pistis.pools[poolName] == nil: "There's already a project on Pistis named: ".concat(poolName)
        }
        //Pistis.pools[projectName] = MetadataStruct(projectName, nftType, nftCap)  
        let storage = Pistis.account.storage.borrow<&Pistis.PoolStorage>(from: Pistis.PoolStoragePath)!
        let poolID = storage.addPool(poolName: poolName, newMetadata: metadataStruct)
    }

    /// createEmptyCollection creates an empty Collection for the specified NFT type
    /// and returns it to the caller so that they can own NFTs
    access(all) fun createEmptyCollection(nftType: Type): @{NonFungibleToken.Collection} {
        return <- create Collection()
    }
    // -----------------------------------------------------------------------
    // Pistis Generic or Standard public "script" functions
    // -----------------------------------------------------------------------


    // Public function to fetch a collection attribute
    access(all) fun getCollectionAttribute(key: String): AnyStruct {
		return self.collectionInfo[key] ?? panic(key.concat(" is not an attribute in this collection."))
	}

    // Function to get all the projects on Pistis
    access(all) fun getPools(): {String: Pistis.MetadataStruct} {
        let storage = Pistis.account.storage.borrow<&{Pistis.PoolStoragePublic}>(from: Pistis.PoolStoragePath)!
        return storage.getPools()
    }
    // Function to get all the projects on Pistis
/*     access(all) fun getPoolMetadata(poolName: String): Pistis.MetadataStruct {
        let pool = self.pools[poolName]!

        return pool
    } */
    /// Function that returns all the Metadata Views implemented by a Non Fungible Token
    ///
    /// @return An array of Types defining the implemented views. This value will be used by
    ///         developers to know which parameter to pass to the resolveView() method.
    ///
    access(all) view fun getContractViews(resourceType: Type?): [Type] {
        return [
            Type<MetadataViews.NFTCollectionData>(),
            Type<MetadataViews.NFTCollectionDisplay>()
        //    Type<MetadataViews.EVMBridgedMetadata>()
        ]
    }
    // Public function to return general metadata around the collection
    access(all) fun resolveContractView(resourceType: Type?, viewType: Type): AnyStruct? {
        switch viewType {
            case Type<MetadataViews.NFTCollectionData>():
                let collectionData = MetadataViews.NFTCollectionData(
                    storagePath: self.CollectionStoragePath,
                    publicPath: self.CollectionPublicPath,
                    publicCollection: Type<&Pistis.Collection>(),
                    publicLinkedType: Type<&Pistis.Collection>(),
                    createEmptyCollectionFunction: (fun (): @{NonFungibleToken.Collection} {
                        return <-Pistis.createEmptyCollection(nftType: Type<@Pistis.NFT>())
                    })
                )
                return collectionData
            case Type<MetadataViews.NFTCollectionDisplay>():
                let media = Pistis.getCollectionAttribute(key: "image") as! MetadataViews.Media
                return MetadataViews.NFTCollectionDisplay(
                    name: "Pistis",
                    description: "Pistis and Telegram governance.",
                    externalURL: MetadataViews.ExternalURL("https://Pistis.gg/"),
                    squareImage: media,
                    bannerImage: media,
                    socials: {
                        "twitter": MetadataViews.ExternalURL("https://twitter.com/Pistis")
                    }
                )
        }
        return nil
    }
    init() {
        self.collectionInfo = {}
        self.totalSupply = 0
        self.totalPools = 0
        self.totalMetadatas = 0
        self.pools = {}
        self.collectionInfo["identifier"] = "Pistis_".concat(self.account.address.toString())
        // Set the named paths
		self.CollectionStoragePath = StoragePath(identifier: self.collectionInfo["identifier"] as! String)!
		self.CollectionPublicPath = PublicPath(identifier: self.collectionInfo["identifier"] as! String )!
        self.PoolStoragePath = StoragePath(identifier: self.collectionInfo["identifier"] as! String)!
        self.PoolPublicPath = PublicPath(identifier: self.collectionInfo["identifier"] as! String)!

        // Create a Collection resource and save it to storage
		let collection <- create Collection()
		self.account.storage.save(<- collection, to: self.CollectionStoragePath)
        // create a public capability for the collection
	    let collectionCap = self.account.capabilities.storage.issue<&Pistis.Collection>(self.CollectionStoragePath)
		self.account.capabilities.publish(collectionCap, at: self.CollectionPublicPath)
        // Create a PoolStorage resource and save it to storage
        let poolStorage <- create PoolStorage()
        self.account.storage.save(<- poolStorage, to: self.PoolStoragePath)
        // create a public capability for the pool
        let poolCap = self.account.capabilities.storage.issue<&{Pistis.PoolStoragePublic}>(self.PoolStoragePath)
        self.account.capabilities.publish(poolCap, at: self.PoolPublicPath)

    }
}