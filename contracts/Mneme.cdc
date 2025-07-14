// MADE BY: Noah Naizir

// This contract is for Mneme, a proof of support platform
// on Flow. 

// Mneme (Μνήμη) is one of the original three Muses in pre-Homeric Greek mythology.
// Before the more famous Nine Muses were standardized by Hesiod (daughters of Zeus and Mnemosyne)
// there were three older Muses:

// Melete – Muse of Practice/Contemplation
// Mneme – Muse of Memory
// Aoide – Muse of Song

// Mneme herself was seen as the preserver of knowledge and inspiration, responsible for the ability of poets, orators 
// and artists to recall what came before and give it form. She represents the thread that links art to time and culture 
// Literally, the memory of humanity encoded in creative work.

import "FungibleToken"
import "FlowToken"
import "NonFungibleToken"
import "ViewResolver"
import "MetadataViews"


access(all)
contract Mneme: NonFungibleToken, ViewResolver {
    // -----------------------------------------------------------------------
    // Mneme contract-level fields.
    // These contain actual values that are stored in the smart contract.
    // -----------------------------------------------------------------------
    // Dictionary to hold general collection information
    access(self) let collectionInfo: {String: AnyStruct}  
    // Dictionary to map artists by name to their metadata
    access(self) let artists: {String: Artist}
    // Dictionary to map Piece by name to their metadata
    // access(self) let pieces: @{String: Piece}

    // Track of total supply of Mneme NFTs
    access(all) var totalSupply: UInt64
    // Track of total amount of Artists on Mneme
    access(all) var totalArtist: UInt64
    // Track of total amount of Pieces on Mneme
    access(all) var totalPieces: UInt64
    // -----------------------------------------------------------------------
    // Mneme Entitlements
    // ----------------------------------------------------------------------- 
    access(all) entitlement AddPiece
    // -----------------------------------------------------------------------
    // Mneme contract Events
    // ----------------------------------------------------------------------- 
    access(all) event ContractInitialized()
    access(all) event Withdraw(id: UInt64, from: Address?)
	access(all) event Deposit(id: UInt64, to: Address?)
    access(all) event PistisCreated(id: UInt64, accountAddress: Address)
    access(all) event ArtistCreated(id: UInt64, name: String, accountAddress: Address)
    access(all) event PieceCreated(id: UInt64, title: String, artist: String)
    access(all) event ViewsUpdated(pieceName: String, oldViewsCount: Int64, newViewsCount: Int64)

    // -----------------------------------------------------------------------
    // Mneme account paths
    // -----------------------------------------------------------------------
	access(all) let CollectionStoragePath: StoragePath
	access(all) let CollectionPublicPath: PublicPath
	access(all) let AdministratorStoragePath: StoragePath
	access(all) let ArtStoragePath: StoragePath
	access(all) let PistisStoragePath: StoragePath
	access(all) let PistisPublicPath: PublicPath
	access(all) let ArtStoragePublicPath: PublicPath

    // -----------------------------------------------------------------------
    // Mneme contract-level Composite Type definitions
    // -----------------------------------------------------------------------
    // These are just *definitions* for Types that this contract
    // and other accounts can use. These definitions do not contain
    // actual stored values, but an instance (or object) of one of these Types
    // can be created by this contract that contains stored values.
    // -----------------------------------------------------------------------
/*     access(all) resource interface ArtStoragePublic {
        access(all) view fun getAllPieces(): {String: Piece}
        access(all) view fun getPiece(_ pieceName: String): Piece
    } */
    // Storage resource for all of the Pieces' metadata
    // this is stored inside the smart contract's account
    access(all) resource ArtStorage {

        access(all) let pieces: {String: Piece}

        init() {
            self.pieces = {}
        }

        // Function to get all stored Pieces
        access(all) view fun getAllPieces(): {String: Piece} {
            return self.pieces
        }
        // Function to get a Piece's metadata
        access(all) view fun getPiece(_ pieceName: String): Piece {
            pre {
                self.pieces[pieceName] != nil: "There's no Piece by the name: \(pieceName)"
            }
            return self.pieces[pieceName]!
        }
        // Function to get a Piece's price
        access(all) fun getPiecePrice(_ pieceName: String): UFix64 {
            pre {
                self.pieces[pieceName] != nil: "There's no Piece by the name: \(pieceName)"
            }
            return self.pieces[pieceName]!.price
        }
        // Function to add a Piece to the storage
        access(AddPiece) fun addPiece(newPiece: Piece) {
            pre {
                self.pieces[newPiece.title] == nil: "There's already a Piece by the name: \(newPiece.title)"
            }
            self.pieces[newPiece.title] = newPiece
        }
        // Function to update a Piece's sentiment
        access(all)
        fun updateSentiment(
            _ pieceName: String,
            _ newViewsCount: Int64,
            _ newLikesCount: Int64,
            _ newSharesCount: Int64,
            _ newPurchasesCount: Int64
        ) {
            self.pieces[pieceName]!.updateSentiment(newViewsCount: newViewsCount, newLikesCount: newLikesCount, newSharesCount: newSharesCount, newPurchasesCount: newPurchasesCount)
        }
    }
    // Struct for Artist's metadata
    access(all) struct Artist {
        // Unique ID for artist
        access(all) var id: UInt64
        access(all) var name: String
        access(all) var biography: String
        access(all) var nationality: String
        access(all) var preferredMedium: String
        access(all) var socials: {String: String}
        access(all) var representation: String?
        access(all) let accountAddress: Address
        access(all) var communityRoyalties: UFix64

        init(
            _ name: String,
            _ biography: String,
            _ nationality: String, 
            _ preferredMedium: String,
            _ socials: {String: String},
            _ representation: String?,
            _ accountAddress: Address,
            _ communityRoyalties: UFix64
        ) {
            // Increase total supply of Artists
            Mneme.totalArtist = Mneme.totalArtist + 1

            self.id = Mneme.totalArtist
            self.name = name
            self.biography = biography
            self.nationality = nationality
            self.preferredMedium = preferredMedium
            self.socials = socials
            self.representation = representation
            self.accountAddress = accountAddress
            self.communityRoyalties = communityRoyalties
            // Emit event
            emit ArtistCreated(id: self.id, name: self.name, accountAddress: self.accountAddress)
        }

        // Artist struct functionality

        // Update attribute variable
    }

    // The Piece struct represents the Art's metadata
    // it serves as a blueprint from which NFTs can be minted
    access(all) struct Piece {
        // Piece's unique id 
        access(all) let id: UInt64
        // Piece's name
        access(all) let title: String
        // Art's artist's name
        access(all) let artistName: String
        // Art's description
        access(all) let description: String
        // Art's artist's account address
        access(all) let artistAccount: Address
        // Art's creation date
        access(all) let creationDate: String
        // Art's creation location
        access(all) let creationLocation: String
        // Art's type
        access(all) let artType: String
        // Piece's medium
        access(all) let medium: String
        // Piece's subject matter
        access(all) let subjectMatter: String
        // Art's provenance notes
        access(all) let provenanceNotes: String
        // Piece's current owners
        // access(all) let currentOwners: String
        access(all) var collections: [String]
        // Piece's acquisition details
        access(all) let acquisitionDetails: String?
        // Piece's production details
        access(all) let productionDetails: ProductionDetails
        // A track of this Piece sentiment
        access(all) let sentimentTrack: Sentiment
        // Price of the Piece
        access(all) let price: UFix64
        // Piece's image
        access(all) let image: String

        init(
            _ title: String,
            _ description: String,
            _ artistName: String,
            _ artistAccount: Address,
            _ creationDate: String,
            _ creationLocation: String,
            _ artType: String,
            _ medium: String,
            _ subjectMatter: String,
            _ provenanceNotes: String,
            _ acquisitionDetails: String?,
            _ productionDetails: ProductionDetails,
            _ price: UFix64,
            _ image: String
        ) {
            // Increase the total of Pieces supply
            Mneme.totalPieces = Mneme.totalPieces + 1

            self.id = Mneme.totalPieces  
            self.title = title
            self.description = description
            self.artistName = artistName
            self.artistAccount = artistAccount
            self.creationDate = creationDate
            self.creationLocation = creationLocation
            self.artType = artType
            self.medium = medium
            self.subjectMatter = subjectMatter
            self.provenanceNotes = provenanceNotes
            self.acquisitionDetails = acquisitionDetails
            self.productionDetails = productionDetails
            self.collections = []
            self.sentimentTrack = Sentiment()
            self.price = price
            self.image = image
        }
        // Functionality around a Piece's blueprint
        access(all)
        fun updateSentiment(
            newViewsCount: Int64,
            newLikesCount: Int64,
            newSharesCount: Int64,
            newPurchasesCount: Int64
            ) {
            pre {
                self.sentimentTrack.views <= newViewsCount: "The new Views count has to be equal or higher than the current count"
                self.sentimentTrack.likes <= newLikesCount: "The new Likes count has to be equal or higher than the current count"
                self.sentimentTrack.shares <= newSharesCount: "The new Shares count has to be equal or higher than the current count"
                self.sentimentTrack.purchases <= newPurchasesCount: "The new Purchases count has to be equal or higher than the current count"
            }
            let sentiment = &self.sentimentTrack as &Mneme.Sentiment
            let oldCount = sentiment.views
            sentiment.updateSentiment(newViewsCount, newLikesCount, newSharesCount, newPurchasesCount)

            emit ViewsUpdated(pieceName: self.title, oldViewsCount: oldCount, newViewsCount: sentiment.views)
        }
    }

    // Struct to store the production details of a Piece
    // like frame's material, packing, or whether it's elevated or not
    access(all) struct ProductionDetails {
        
        access(all) let pieceCondition: String
        access(all) let substrate: String
        access(all) let originalHeight: UFix64
        access(all) let originalWidth: UFix64
        access(all) let texture: String
        access(all) let gloss: String
        access(all) let metalness: String
        access(all) let totalSalePrice: UFix64
        access(all) let totalEditions: String
        access(all) let sizes: String
        access(all) let printingTypes: String
        access(all) let substrateTypes: String
        access(all) let frame: String
        access(all) let mounting: String
        access(all) let packing: String
        access(all) let artistSignature: String
        access(all) let statementOfAuth: String?
        access(all) let numbering: String
        access(all) let status: String
        access(all) let otherFinishings: String


        init(
            _ pieceCondition: String,
            _ substrate: String,
            _ originalHeight: UFix64,
            _ originalWidth: UFix64,
            _ texture: String,
            _ gloss: String,
            _ metalness: String, 
            _ totalSalePrice: UFix64,
            _ totalEditions: String,
            _ sizes: String,
            _ printingTypes: String,
            _ substrateTypes: String,
            _ frame: String,
            _ mounting: String,
            _ packing: String,
            _ artistSignature: String,
            _ statementOfAuth: String?,
            _ numbering: String,
            _ status: String,
            _ otherFinishings: String
        ) {

            self.pieceCondition = pieceCondition
            self.substrate = substrate
            self.originalHeight = originalHeight
            self.originalWidth = originalWidth
            self.texture = texture
            self.gloss = gloss
            self.metalness = metalness
            self.totalSalePrice = totalSalePrice
            self.totalEditions = totalEditions
            self.sizes = sizes
            self.printingTypes = printingTypes
            self.substrateTypes = substrateTypes
            self.frame = frame
            self.mounting = mounting
            self.packing = packing
            self.artistSignature = artistSignature
            self.statementOfAuth = statementOfAuth
            self.numbering = numbering
            self.status = status
            self.otherFinishings = otherFinishings
        }
    }

    // Sentiment struct serves to track feedback on a Piece
    access(all) struct Sentiment {
        access(all) var views: Int64
        access(all) var likes: Int64
        access(all) var shares: Int64
        access(all) var purchases: Int64

        init() {
            self.views = 0
            self.likes = 0
            self.shares = 0
            self.purchases = 0
        }
        // Functionality around updating a Piece's sentiment
        access(all)
        fun updateSentiment(
            _ newViewsCount: Int64,
            _ newLikesCount: Int64,
            _ newSharesCount: Int64,
            _ newPurchasesCount: Int64
        ) {
            pre {
                self.views <= newViewsCount: "The new Views count has to be equal or higher than the current count"
                self.likes <= newLikesCount: "The new Likes count has to be equal or higher than the current count"
                self.shares <= newSharesCount: "The new Shares count has to be equal or higher than the current count"
                self.purchases <= newPurchasesCount: "The new Purchases count has to be equal or higher than the current count"
            }

            self.views = newViewsCount
            self.likes = newLikesCount
            self.shares = newSharesCount
            self.purchases = newPurchasesCount
        }
        access(all) fun updateViews(newCount:  Int64) {
            pre {
                self.views < newCount: "New count cannot be lower that current count"
            }
            self.views = newCount
        }
        access(all) fun updateLikes(newCount:  Int64) {
            pre {
                self.likes < newCount: "New count cannot be lower that current count"
            }
            self.likes = newCount
        }
        access(all) fun updateShares(newCount:  Int64) {
            pre {
                self.shares < newCount: "New count cannot be lower that current count"
            }
            self.shares = newCount
        }
        access(all) fun updatePurchases(newCount:  Int64) {
            pre {
                self.purchases < newCount: "New count cannot be lower that current count"
            }
            self.purchases = newCount
        }
    }
    // Pistis (Πίστις) is not a goddess in the traditional Olympian sense
    // but rather a personified spirit (daimona) representing:
    // Good Faith, Trust, Loyalty and Reliability

    // Pistis is a proof-of-support syste where:

    // Collectors pledge soulbound tokens as a form of trust in creators. (Pledged trust/faith)
    // Artists distribute rewards in return, honoring loyalty. (Proof of loyalty & belief)
    // Multipliers reflect belief over time, rewarding early conviction. (Honoring those who believed)
    // It’s a trust economy based on On—chain Provenance and that’s exactly what Pistis governs.
    access(all) resource Pistis {
        // Soulbound token
        access(all) let limit: Int64
        access(all) var currentSupport: Int64
        access(all) let supportedArtists: {String: Int64}
        init(colletor: Address) {
            self.limit = 100
            self.currentSupport = 0
            self.supportedArtists = {}

            emit PistisCreated(id: self.uuid, accountAddress: colletor)
        }
        access(all) fun addSupport(artistName: String, supportAmount: Int64) {
            pre {
                Mneme.artists[artistName] != nil: "This artist does not exist"
                self.currentSupport + supportAmount <= 100: "This will exceed the support limit of 100"
                // Verify if this collector owns a piece from this artist
            }
            let currentCount = self.supportedArtists[artistName]!
            self.supportedArtists[artistName] = currentCount + supportAmount
            self.currentSupport = self.currentSupport + supportAmount

            // Emit event
            // emit Support(artistName: artistName, supportAmount: supportAmount)
        }
        access(all) fun removeSupport(artistName: String, supportAmount: Int64) {
            pre {
                self.supportedArtists[artistName] != nil: "This artist is not supported"
                self.supportedArtists[artistName]! >= supportAmount: "You're trying to remove more support than you have on this artist"
            }
            let currentCount = self.supportedArtists[artistName]!
            self.supportedArtists[artistName] = currentCount - supportAmount
            self.currentSupport = self.currentSupport - supportAmount

            // Emit event
            // emit Support(artistName: artistName, supportAmount: supportAmount)
        }
        
    }
    access(all) resource artistPool {
        access(all) let artistName: String
        access(all) let storagePath: StoragePath
        access(all) let publicPath: PublicPath
        access(all) let dateCreated: UFix64
        access(all) let supporters: {Address: UFix64}

        init(artistName: String) {
            self.artistName = artistName
            self.storagePath = StoragePath(identifier: "Mneme_\(artistName)_community_pool")!
            self.publicPath = PublicPath(identifier: "Mneme_\(artistName)_community_pool")!
            self.dateCreated = getCurrentBlock().timestamp
            self.supporters = {}

            let communityPool <- FlowToken.createEmptyVault(vaultType: Type<@FlowToken.Vault>())
            Mneme.account.storage.save(<- communityPool, to: self.storagePath)
            // Create a public capability to the stored Vault that only exposes
            // the `deposit` method through the `Receiver` interface
            let receiverCapability = Mneme.account.capabilities.storage.issue<&FlowToken.Vault>( self.storagePath)
            Mneme.account.capabilities.publish(receiverCapability, at: self.publicPath)
        }

        access(all) fun addSupport(supporter: Address, amount: UFix64) { 
            pre {
                self.supporters[supporter]! + amount <= 100.0: "Support limit of 100.0 reached"
            }
            self.supporters[supporter] = self.supporters[supporter]! + amount

            // emit event
            // emit Support(artistName: self.artistName, supporter: supporter, amount: amount)
        }
        // calculate rewards
        access(all) fun calculateRewards(collector: Address) {
            pre {
                self.supporters[collector] != nil: "Collector is not a supporter"
            }

            let editionsMultiplier = self.getTotalEditions(collector: collector) 
            let supportMultiplier = self.supporters[collector]!
            let totalMultiplier = editionsMultiplier + supportMultiplier
            // get Artist's community pool
            let vaultRef = Mneme.account.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: self.storagePath)!
            // Get collector's vault
            let collectorVault = getAccount(collector).capabilities.borrow<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)!
            // Deposit collector's tokens to the artist's pool
            collectorVault.deposit(from: <- vaultRef.withdraw(amount: 0.0) )

        }
        // Get the total of editions owned
        access(all) fun getTotalEditions(collector: Address): UFix64 {
            // Get the owned Pieces from the collector
            // Sum the total of pieces owned
            // Sum their editions multipliers 
            let account = getAccount(collector)
            let cap = account.capabilities.borrow<&Mneme.Collection>(Mneme.CollectionPublicPath)!
            let ids = cap.getIDs()
            var multiplier = 0.0

            for id in ids {
                let nftRef = cap.borrowNFT(id)!
                let resolver = cap.borrowViewResolver(id: id)!
                let serialView = MetadataViews.getSerial(resolver)!
                let edition = serialView as! UInt64

                if edition == 1 {
                    multiplier = multiplier + 5.0
                } else if edition > 1 && edition <= 10 {
                    multiplier = multiplier + 2.0
                } else if edition > 10 {
                    multiplier = multiplier + 1.0
                }
            }
            return multiplier
        }
    }
    // -----------------------------------------------------------------------
    // NFT Resource
    // -----------------------------------------------------------------------
	access(all) resource NFT: NonFungibleToken.NFT {
        access(all) let id: UInt64
        access(all) let pieceTitle: String

        init(pieceTitle: String) {
            // Increment the global Cards IDs
            Mneme.totalSupply = Mneme.totalSupply + 1
            self.id = Mneme.totalSupply
            self.pieceTitle = pieceTitle
        }

        access(all) view fun getMetadata(): Piece {
            let metadata = Mneme.getPiece(self.pieceTitle)
            return metadata
        }

        access(all) view fun getTraits(): {String: AnyStruct} {
            let piece = Mneme.getPiece(self.pieceTitle)
            let traits = {
                "Artist": piece.artistName,
                "Title": piece.title,
                "Description": piece.description,
                "Creation Date": piece.creationDate,
                "Art Type": piece.artType,
                "Medium": piece.medium,
                "Subject Matter": piece.subjectMatter,
                "Provenance Notes": piece.provenanceNotes,
                "Price": piece.price,
                "Total Editions": piece.productionDetails.totalEditions,
                "Sizes": piece.productionDetails.sizes,
                "Artist Signature": piece.productionDetails.artistSignature
            }
            return traits
        }

        /// createEmptyCollection creates an empty Collection
        /// and returns it to the caller so that they can own NFTs
        /// @{NonFungibleToken.Collection}
        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <- Mneme.createEmptyCollection(nftType: Type<@Mneme.NFT>())
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
            	let metadata = self.getMetadata()
                switch view {
				case Type<MetadataViews.Display>():
					return MetadataViews.Display(
						name: self.pieceTitle,
						description: metadata.description,
						thumbnail: MetadataViews.HTTPFile( 
            				url: "data:image/png;base64,\(metadata.image)"
            			)
					)
				case Type<MetadataViews.Traits>():
					return MetadataViews.dictToTraits(dict: self.getTraits(), excludedNames: nil)
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
					return Mneme.resolveContractView(resourceType: Type<@Mneme.NFT>(), viewType: Type<MetadataViews.NFTCollectionData>())
        		case Type<MetadataViews.ExternalURL>():
        			return "https://www.artdrop.me"
		        case Type<MetadataViews.NFTCollectionDisplay>():
					return Mneme.resolveContractView(resourceType: Type<@Mneme.NFT>(), viewType: Type<MetadataViews.NFTCollectionDisplay>())
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
                    let artist = Mneme.getArtist(name: metadata.artistName)!
                    let communityRoyalties = artist.communityRoyalties
          			return MetadataViews.Royalties([
            			MetadataViews.Royalty(
              				receiver: getAccount(Mneme.account.address).capabilities.get<&FlowToken.Vault>(/public/flowTokenReceiver),
              				cut: communityRoyalties, 
              				description: "\(artist.name)'s community pool percentage is \(communityRoyalties.toString())"
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
            supportedTypes[Type<@Mneme.NFT>()] = true
            return supportedTypes
        }
        /// Returns whether or not the given type is accepted by the collection
        /// A collection that can accept any type should just return true by default
        access(all) view fun isSupportedNFTType(type: Type): Bool {
            return type == Type<@Mneme.NFT>()
        }
		// Withdraw removes a Mneme from the collection and moves it to the caller(for Trading)
		access(NonFungibleToken.Withdraw) fun withdraw(withdrawID: UInt64): @{NonFungibleToken.NFT} {
			let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("This Collection doesn't own a Mneme by id: \(withdrawID.toString())")

			emit Withdraw(id: token.id, from: self.owner?.address)

			return <-token
		}
		// Deposit takes a Mneme and adds it to the collections dictionary
		// and adds the ID to the id array
		access(all) fun deposit(token: @{NonFungibleToken.NFT}) {
			let newMneme <- token as! @NFT
			let id: UInt64 = newMneme.id
			// Add the new Mneme to the dictionary
            let oldMneme <- self.ownedNFTs[id] <- newMneme
            // Destroy old Mneme in that slot
            destroy oldMneme

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
            return <-Mneme.createEmptyCollection(nftType: Type<@Mneme.NFT>())
        }
    }
    // -----------------------------------------------------------------------
    // Mneme Administrator Resource
    // -----------------------------------------------------------------------
    // Admin is a special authorization resource that 
    // allows the owner to perform important functions to modify the 
    // various aspects of the Artists, Pieces, and Collections
    access(all) resource Administrator {
        // createArtist creates a new Artist struct 
        // and stores it in the Artist dictionary in the Mneme smart contract
        //
        // Returns: the ID of the new Artist object
        //
        access(all) fun createArtist(
            name: String,
            biography: String,
            nationality: String,
            preferredMedium: String,
            socials: {String: String},
            representation: String?,
            accountAddress: Address,
            communityRoyalties: UFix64
        ): UInt64 {
            // Create the community pool
            self.createCommunityPool(artistName: name)
            // Create new Artist struct
            let newArtist = Artist(name, biography, nationality, preferredMedium, socials, representation, accountAddress, communityRoyalties)
            // Save artist to the dictionary stored inside the smart contract
            Mneme.artists[name] = newArtist

            return newArtist.id

            // emit event
            // emit ArtistCreated(id: newArtist.id, name: newArtist.name)
        }
        // createPiece creates a new Piece resource 
        // and stores it in the Piece dictionary in the Mneme smart contract
        //
        // Returns: the ID of the new Piece object
        //
        access(all) fun createPiece(
            title: String,
            description: String,
            artistName: String,
            artistAccount: Address,
            creationDate: String,
            creationLocation: String,
            artType: String,
            medium: String,
            subjectMatter: String,
            provenanceNotes: String,
            acquisitionDetails: String?,
            productionDetails: ProductionDetails,
            price: UFix64,
            image: String
        ): UInt64 {
            // Create new Piece resource
            let newPiece = Piece(title, description, artistName, artistAccount, creationDate, creationLocation, artType, medium, subjectMatter, provenanceNotes, acquisitionDetails, productionDetails, price, image)
            // store the new id 
            let newID = newPiece.id
            // emit event
            emit PieceCreated(id: newPiece.id, title: newPiece.title, artist: newPiece.artistName)
            // borrow ArtStorage from Account
            let storage = Mneme.account.storage.borrow<auth(AddPiece) &Mneme.ArtStorage>(from: Mneme.ArtStoragePath)!
            // Store the new resource inside the smart contract
            storage.addPiece(newPiece: newPiece)

            return newID
        }
        // updateViews and other functions update the
        // sentiment track for a particular piece
        access(all)
        fun updateSentiment(
            pieceName: String,
            newViewsCount: Int64,
            newLikesCount: Int64,
            newSharesCount: Int64,
            newPurchasesCount: Int64
        ) {
            // borrow ArtStorage from Account
            let storage = Mneme.account.storage.borrow<&Mneme.ArtStorage>(from: Mneme.ArtStoragePath)!
            storage.updateSentiment(pieceName, newViewsCount, newLikesCount, newSharesCount, newPurchasesCount)
        }
        // Mint Piece NFT
        access(all)
        fun mintPiece(
            pieceName: String,
            artistName: String,
            recipient: Address) {
            pre {
                Mneme.artists[artistName] != nil: "This artist does not exist"
            }
/*             let piecePrice = Mneme.getPiecePrice(pieceName)
            let artistRoyalties = Mneme.artists[artistName]!.communityRoyalties
            let royalties = piecePrice * artistRoyalties
            // Get a reference to Mneme's stored vault
            let vaultRef = Mneme.account.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)!
            let path = PublicPath(identifier: "Mneme_\(artistName)_community_pool")!
            // Get contract's Vault
		    let artistTreasury = getAccount(Mneme.account.address).capabilities.borrow<&{FungibleToken.Receiver}>(path)!
            artistTreasury.deposit(from: <- vaultRef.withdraw(amount: royalties)) */
            // Mint the NFT
            let nft <- create NFT(pieceTitle: pieceName)

			if let recipientCollection = getAccount(recipient)
				.capabilities.borrow<&{NonFungibleToken.Receiver}>(Mneme.CollectionPublicPath) 
				{
					recipientCollection.deposit(token: <- nft)
			} else {
				destroy nft
/* 				if let storage = &Piece.nftStorage[recipient] as &{UInt64: NFT}? {
					storage[nft.id] <-! nft
				} else {
					Piece.nftStorage[recipient] <-! {nft.id: <- nft}
				} */
			}
        }
        // Helper function to create the community pool
        access(self) fun createCommunityPool(artistName: String) {
            pre {
                Mneme.artists[artistName] == nil: "This artist already has a community pool"
            }
            // This pool is either going to be on 30 days period or per season
            // If it is per season, then it's tied to that season's NFTs
            let path = "Mneme_\(artistName)_community_pool"
            let pool <-  FlowToken.createEmptyVault(vaultType: Type<@FlowToken.Vault>())
            // Save the pool to storage
            Mneme.account.storage.save(<- pool, to: StoragePath(identifier: path)!)
            // Create a public capability to the Vault that exposes the Vault interfaces
            let vaultCap = Mneme.account.capabilities.storage.issue<&{FungibleToken.Vault}>(StoragePath(identifier: path)!)
            Mneme.account.capabilities.publish(vaultCap, at: PublicPath(identifier: path)!)

            // Emit event
        }
    }
    //
    // -----------------------------------------------------------------------
    // Mneme private functions
    // -----------------------------------------------------------------------

    // -----------------------------------------------------------------------
    // Mneme public functions
    // -----------------------------------------------------------------------
    // public function to get a dictionary of all artists
    access(all) fun getArtists(): {String: Artist} {
        return self.artists
    }
    // public function to get an Artist's metadata by name
    access(all) fun getArtist(name: String): Artist? {
        return self.artists[name]
        ?? panic("No artist by name: \(name)")
    }
    // Public function to get an Artist's community pool
    access(all) fun getArtistCommunityPool(artistName: String): UFix64 {
        pre {
            Mneme.artists[artistName] != nil: "This artist does not exist"
        }

        let path = PublicPath(identifier: "Mneme_\(artistName)_community_pool")!
		let artistTreasury = getAccount(Mneme.account.address).capabilities.borrow<&{FungibleToken.Balance}>(path)!
        return artistTreasury.balance
    }
    // public function to get a dictionary of all artists
    access(all) view fun getAllPieces(): {String: Mneme.Piece} {
        // Borrow public capability for the art storage
        let storage = Mneme.account.capabilities.borrow<&Mneme.ArtStorage>(Mneme.ArtStoragePublicPath)!
        let pieces = storage.getAllPieces()

        return pieces
    }
    // public function to get the sentiment on a Piece
 /*    access(all) view fun getPieceSentiment(pieceName: String): Sentiment {
        // borrow ArtStorage from Account
        let storage = Mneme.account.capabilities.borrow<&{Mneme.ArtStoragePublic}>(Mneme.ArtStoragePublicPath)!
        let piece = storage.getPiece(pieceName)
        return piece.sentimentTrack
    } */
   
    // public function to get a Piece's metadata
    access(all) view fun getPiece(_ pieceName: String): Piece {
        let storage = Mneme.account.capabilities.borrow<&Mneme.ArtStorage>(Mneme.ArtStoragePublicPath)!

        let piece = storage.getPiece(pieceName)
        return piece
    } 
    // -----------------------------------------------------------------------
    // Mneme Generic or Standard public functions
    // -----------------------------------------------------------------------
    //
    /// createEmptyCollection creates an empty Collection for the specified NFT type
    /// and returns it to the caller so that they can own NFTs
    access(all) fun createEmptyCollection(nftType: Type): @{NonFungibleToken.Collection} {
        return <- create Collection()
    }
    /// createEmptyCollection creates an empty Collection for the specified NFT type
    /// and returns it to the caller so that they can own NFTs
    access(all) fun createEmptyPistis(colletor: Address): @Pistis {
        return <- create Pistis(colletor: colletor)
    }
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
                    publicCollection: Type<&Mneme.Collection>(),
                    publicLinkedType: Type<&Mneme.Collection>(),
                    createEmptyCollectionFunction: (fun (): @{NonFungibleToken.Collection} {
                        return <-Mneme.createEmptyCollection(nftType: Type<@Mneme.NFT>())
                    })
                )
                return collectionData
            case Type<MetadataViews.NFTCollectionDisplay>():
                let media = MetadataViews.Media(
            			file: MetadataViews.HTTPFile(
            				url: "https://artdrop.me/cdn/shop/files/logo-white.png"
            			),
            			mediaType: "image/jpeg"
          			)
                return MetadataViews.NFTCollectionDisplay(
                    name: "ArtDrop",
                    description: "ArtDrop is Forever.",
                    externalURL: MetadataViews.ExternalURL("https://ArtDrop.me/"),
                    squareImage: media,
                    bannerImage: media,
                    socials: {
                        "twitter": MetadataViews.ExternalURL("https://X.com/Artdrop")
                    }
                )
        }
        return nil
    } 
    // Public function to fetch a collection attribute
    access(all) fun getCollectionAttribute(key: String): AnyStruct {
		return self.collectionInfo[key] ?? panic("\(key) is not an attribute in this collection.")
	}
    init() {
        self.collectionInfo = {}
        self.artists = {}
        // self.pieces <- {}
        self.totalSupply = 0
        self.totalArtist = 0
        self.totalPieces = 0

        let identifier = "Mneme_\(self.account.address.toString())"
        // Set the named paths
		self.CollectionStoragePath = StoragePath(identifier: identifier)! 
		self.CollectionPublicPath = PublicPath(identifier: identifier)!
		self.AdministratorStoragePath = StoragePath(identifier: "\(identifier)Administrator")!
		self.ArtStoragePath = StoragePath(identifier: "\(identifier)ArtStorage")!
        self.ArtStoragePublicPath = PublicPath(identifier: "\(identifier)ArtStoragePublic")!
        self.PistisStoragePath = StoragePath(identifier: "\(identifier)Pistis")!
        self.PistisPublicPath = PublicPath(identifier: "\(identifier)Pistis")!

		// Create a Administrator resource and save it to Mneme account storage
		let administrator <- create Administrator()
		self.account.storage.save(<- administrator, to: self.AdministratorStoragePath)
		// Create a ArtStorage resource and save it to Mneme account storage
		let artStorage <- create ArtStorage()
		self.account.storage.save(<- artStorage, to: self.ArtStoragePath)
        // Create a public capability for the art storage
        let artStorageCap = self.account.capabilities.storage.issue<&Mneme.ArtStorage>(self.ArtStoragePath)
		self.account.capabilities.publish(artStorageCap, at: self.ArtStoragePublicPath)
		// Create a Collection resource and save it to storage
		let collection <- create Collection()
		self.account.storage.save(<- collection, to: self.CollectionStoragePath)
        // create a public capability for the collection
	    let collectionCap = self.account.capabilities.storage.issue<&Mneme.Collection>(self.CollectionStoragePath)
		self.account.capabilities.publish(collectionCap, at: self.CollectionPublicPath)
		// Create a Pistis resource and save it to storage
		let pistis <- create Pistis(colletor: self.account.address)
		self.account.storage.save(<- pistis, to: self.PistisStoragePath)
        // create a public capability for Pistis
	    let pistisCap = self.account.capabilities.storage.issue<&Mneme.Pistis>(self.PistisStoragePath)
		self.account.capabilities.publish(pistisCap, at: self.PistisPublicPath)
    }

}