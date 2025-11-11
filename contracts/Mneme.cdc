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
    // Dictionary to map artists by Address to their name
    access(self) let artists:  {Address: String}
    // Dictionary to map Piece by Title to their Id
    access(self) let pieces: {String: UInt64}
    // Dictionary to map Print by id to their owner
    // access(contract) let prints: {UInt64: Address}

    // Track of total supply of Mneme NFTs
    access(all) var totalSupply: UInt64
    access(all) var totalArtist: UInt64
    access(all) var totalPieces: UInt64
    access(all) var totalPrintBlueprints: Int64
    // -----------------------------------------------------------------------
    // Mneme Entitlements
    // ----------------------------------------------------------------------- 
    access(all) entitlement AddArtist
    access(all) entitlement AddPiece
    access(all) entitlement CreatePrint
    access(all) entitlement MintPrint
    access(all) entitlement AddCertificate
    access(all) entitlement UpdateOwner
    access(all) entitlement UpdateSentiment
    access(all) entitlement StorePrint
    access(all) entitlement ClaimStatus
    access(all) entitlement DeliverPrint
    // -----------------------------------------------------------------------
    // Mneme contract Events
    // ----------------------------------------------------------------------- 
    access(all) event ContractInitialized()
    access(all) event Withdraw(id: UInt64, from: Address?)
	access(all) event Deposit(id: UInt64, to: Address?)
    access(all) event PistisCreated(id: UInt64, accountAddress: Address)
    access(all) event ArtistCreated(id: UInt64, name: String, accountAddress: Address)
    access(all) event PieceCreated(id: UInt64, title: String, artist: String)
    access(all) event PrintMinted(id: UInt64, xuid: String, pieceId: UInt64, toBeClaimedBy: Address)
    access(all) event NewPrintOwner(id: UInt64, pieceId: UInt64, oldOwner: Address, newOwner: Address)
    access(all) event ViewsUpdated(pieceName: String, oldViewsCount: Int64, newViewsCount: Int64)

    // -----------------------------------------------------------------------
    // Mneme account paths
    // -----------------------------------------------------------------------
	access(all) let CollectionStoragePath: StoragePath
	access(all) let CollectionPublicPath: PublicPath
	access(all) let AdministratorStoragePath: StoragePath
	access(all) let ArtDropPath: StoragePath
	access(all) let PistisStoragePath: StoragePath
	access(all) let PistisPublicPath: PublicPath
	access(all) let ArtDropPublicPath: PublicPath
	access(all) let PrintsRecordStoragePath: StoragePath

    // -----------------------------------------------------------------------
    // Mneme contract-level Composite Type definitions
    // -----------------------------------------------------------------------
    // These are just *definitions* for Types that this contract
    // and other accounts can use. These definitions do not contain
    // actual stored values, but an instance (or object) of one of these Types
    // can be created by this contract that contains stored values.
    // -----------------------------------------------------------------------
    // Storage resource for Prints yet to be claimed
    access(all) resource PrintsRecord {
        access(account) let prints: {String: Print}

        init() {
            self.prints = {}
        }

        access(contract) fun addPrint(XUID: String, id: UInt64, address: Address) {
            pre {
                self.prints[XUID] == nil: "There's already a print with this XUID"
            }
            self.prints[XUID] = Print(XUID: XUID, id: id, address: address)
        }

        access(contract) fun getPrint(XUID: String): {UInt64: Address} {
            pre {
                self.prints[XUID] != nil: "There's no print with this XUID"
            }
            return self.prints[XUID]!
        }

    }
    // Storage resource for all of the Pieces' metadata
    // this is stored inside the smart contract's account
    access(all) resource ArtDrop {

        access(self) let artists: @{Address: Artist}
        access(self) let future: {String: AnyStruct}

        init() {
            self.artists <- {}
            // self.pieces = {}
            self.future = {}
        }
        // Function to add an Artist to the storage
        access(AddArtist) fun addArtist(newArtist: @Artist) {
            pre {
                self.artists[newArtist.accountAddress] == nil: "There's already an Artist by this address: \(newArtist.accountAddress)"
            }
            emit ArtistCreated(id: newArtist.id, name: newArtist.name, accountAddress: newArtist.accountAddress)
            self.artists[newArtist.accountAddress] <-! newArtist
        }
        // Function to get all Artists stored
        access(contract) view fun getAllArtistIds(): [Address] {
            return self.artists.keys
        }
        // Function to get an Artist's metadata
        access(contract) fun getArtist(address: Address): MetadataViews.Traits? {
            pre {
                self.artists[address] != nil: "There's no Artist by the address: \(address)"
            }
            let artist = &self.artists[address] as &Artist?
            let metadata = artist?.resolveView(Type<MetadataViews.Traits>()) as! MetadataViews.Traits?
            return metadata
        }
        // Function to get an Artist's id
        access(contract) view fun getArtistId(address: Address): UInt64 {
            pre {
                self.artists[address] != nil: "There's no Artist by the address: \(address)"
            }
            let artist = &self.artists[address] as &Artist?
            let id = artist?.id!
            return id
        }
        // Function to get an Artist's account address
/*         access(all) fun getArtistAccountAddress(name: String): Address {
            pre {
                self.artists[name] != nil: "There's no Artist by the name: \(name)"
            }
            let artist = &self.artists[name] as &Artist?
            let accountAddress = artist?.getAccountAddress()!
            return accountAddress
        } */
        // Function to get an Artist's community pool
        access(all) fun getArtistRoyalties(address: Address): UFix64? {
            pre {
                self.artists[address] != nil: "There's no Artist by the address: \(address)"
            }
            let artist = &self.artists[address] as &Artist?
            let communityRoyalties = artist?.communityRoyalties
            return communityRoyalties
        }

        // Function to add a Piece to the storage
        access(AddPiece) fun createPiece(
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
            _ image: String) {
            pre {
                self.artists[artistAccount] != nil: "There's no Artist by the address: \(artistAccount)"
            }
            let artist = &self.artists[artistAccount] as &Artist?
            artist!.createPiece(title, description, artistName, artistAccount, creationDate, creationLocation, artType, medium, subjectMatter, provenanceNotes, acquisitionDetails, productionDetails, price, image) 
        }
        // Get a Piece's metadata
        access(all) fun getPiece(id: UInt64, artistAddress: Address): MetadataViews.Traits? {
            pre {
                self.artists[artistAddress] != nil: "There's no Artist by the address: \(artistAddress)"
            }
            let artist = &self.artists[artistAddress] as &Artist?
            let metadata = artist!.getPieceMetadata(id: id)

            return metadata
        }
        // Get a Piece's display view
        access(all) fun getPieceDisplayView(id: UInt64, artistAddress: Address): MetadataViews.Display? {
            pre {
                self.artists[artistAddress] != nil: "There's no Artist by the address: \(artistAddress)"
            }
            let artist = &self.artists[artistAddress] as &Artist?
            let display = artist!.getPieceDisplayView(id: id)
            return display
        }
        // Function to update a Piece's sentiment
        access(UpdateSentiment)
        fun updateSentiment(
            _ pieceID: UInt64,
            _ artistAddress: Address,
            _ newViewsCount: Int64,
            _ newLikesCount: Int64,
            _ newSharesCount: Int64,
            _ newPurchasesCount: Int64) {
            pre {
                self.artists[artistAddress] != nil: "There's no Artist with this address"
            }
            let artist = &self.artists[artistAddress] as &Artist?
            artist!.updateSentiment(id: pieceID, newViewsCount: newViewsCount, newLikesCount: newLikesCount, newSharesCount: newSharesCount, newPurchasesCount: newPurchasesCount)
        }
    }
    // Struct for Artist's metadata
    access(all) resource Artist {
        // Unique ID for artist
        access(all) let id: UInt64
        access(all) let accountAddress: Address
        access(all) let name: String
        access(all) var biography: String
        access(all) var nationality: String
        access(all) var preferredMedium: String
        access(all) var socials: {String: String}
        access(all) var representation: String?
        access(all) var communityRoyalties: UFix64
        access(all) var extra: {String: AnyStruct}
        access(all) var image: String
        // Dictionary to map Piece by id to their metadata
        access(all) var pieces: @{UInt64: Piece}
        // Dictionary to map Piece by title to their id
        access(all) var piecesByTitle: {String: UInt64}

        init(
            _ name: String,
            _ biography: String,
            _ nationality: String, 
            _ preferredMedium: String,
            _ socials: {String: String},
            _ representation: String?,
            _ accountAddress: Address,
            _ communityRoyalties: UFix64,
            _ image: String
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
            self.extra = {}
            self.image = image
            self.pieces <- {}
            self.piecesByTitle = {}
            emit ArtistCreated(id: self.id, name: self.name, accountAddress: self.accountAddress)
        }

        access(all) fun createPiece(
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
            _ image: String) {
            pre {
                self.pieces[Mneme.totalPieces] == nil: "There's already a piece with this id"
                self.piecesByTitle[title] == nil: "There's already a piece with this title"
            }

            let piece <- create Piece(title,
                description,
                artistName,
                artistAccount,
                creationDate,
                creationLocation,
                artType,
                medium,
                subjectMatter,
                provenanceNotes,
                acquisitionDetails,
                productionDetails,
                price,
                image)
            let id = piece.id
            self.piecesByTitle[title] = id
            self.pieces[id] <-! piece
            // emit event
            emit PieceCreated(id: id, title: title, artist: self.name)
        }
        
/*         access(all) fun addPrint(newPrintId: UInt64) {
            pre {
                self.prints[newPrint.printId] == nil: "There's already a print with this id"
            }
            self.prints[newPrint.printId] = newPrint
        } */
        // Get a Piece's metadata
        access(all) fun getPieceMetadata(id: UInt64): MetadataViews.Traits {
            pre {
                self.pieces[id] != nil: "There's no Piece by the id: \(id)"
            }
            let piece = &self.pieces[id] as &Piece?
            let metadata = piece!.resolveView(Type<MetadataViews.Traits>()) as! MetadataViews.Traits
            return metadata
        }
        // Get a Piece's DisplayView
        access(all) fun getPieceDisplayView(id: UInt64): MetadataViews.Display {
            pre {
                self.pieces[id] != nil: "There's no Piece by the id: \(id)"
            }
            let piece = &self.pieces[id] as &Piece?
            let display = piece!.resolveView(Type<MetadataViews.Display>()) as! MetadataViews.Display
            return display
        }
        // Function to update a Piece's sentiment
        access(all) fun updateSentiment(
            id: UInt64,
            newViewsCount: Int64,
            newLikesCount: Int64,
            newSharesCount: Int64,
            newPurchasesCount: Int64) {
            pre {
                self.pieces[id] != nil: "There's no Piece by the id: \(id)"
            }
            let piece = &self.pieces[id] as &Piece?
            piece?.updateSentiment(newViewsCount: newViewsCount, newLikesCount: newLikesCount, newSharesCount: newSharesCount, newPurchasesCount: newPurchasesCount) ?? panic("Piece not found")
        }
        // Function to get an artist's account address
        access(all) view fun getAccountAddress(): Address {
            return self.accountAddress
        }

        access(self) view fun getTraits(): {String: AnyStruct} {
            let traits = {
                "id": self.id,
                "uuid": self.uuid,
                "Artist": self.name,
                "Description": self.biography,
                "Nationality": self.nationality,
                "Preferred Medium": self.preferredMedium,
                "Socials": self.socials,
                "Representation": self.representation,
                "Account Address": self.accountAddress,
                "Community Royalties": self.communityRoyalties,
                "Image": self.image
            }
            return traits
        }
        // Standard to return Artist's metadata
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
                switch view {
				case Type<MetadataViews.Display>():
					return MetadataViews.Display(
						name: self.name,
						description: self.biography,
						thumbnail: MetadataViews.HTTPFile( 
            				url: "data:image/png;base64,\(self.image)"
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
        		case Type<MetadataViews.Royalties>():
          			return MetadataViews.Royalties([
            			MetadataViews.Royalty(
              				receiver: getAccount(Mneme.account.address).capabilities.get<&FlowToken.Vault>(/public/flowTokenReceiver),
              				cut: self.communityRoyalties, 
              				description: "\(self.name)'s community pool percentage is \(self.communityRoyalties)"
            			)
          			])
				case Type<MetadataViews.Serial>():
					return MetadataViews.Serial(
						0
					)
			}
			return nil
        }

        // Artist struct functionality

        // Update attribute variable
    }

    // The Piece resource represents the Art's metadata
    // it serves as a blueprint from which NFTs can be minted
    access(all) resource Piece {
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
        // Dictionary to map Print by id to their metadata
        access(all) var prints: [UInt64]

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
            self.prints = []

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
            let sentiment = &self.sentimentTrack as auth(UpdateSentiment) &Mneme.Sentiment
            let oldCount = sentiment.views
            sentiment.updateSentiment(newViewsCount, newLikesCount, newSharesCount, newPurchasesCount)

            emit ViewsUpdated(pieceName: self.title, oldViewsCount: oldCount, newViewsCount: sentiment.views)
        }

        access(self) view fun getTraits(): {String: AnyStruct} {
            let traits = {
                "id": self.id,
                "title": self.title,
                "artistName": self.artistName,
                "description": self.description,
                "artistAccount": self.artistAccount,
                "creationDate": self.creationDate,
                "creationLocation": self.creationLocation,
                "artType": self.artType,
                "medium": self.medium,
                "subjectMatter": self.subjectMatter,
                "provenanceNotes": self.provenanceNotes,
                "acquisitionDetails": self.acquisitionDetails,
                "productionDetails": self.productionDetails,
                "sentimentTrack": self.sentimentTrack,
                "price": self.price,
                "image": self.image
            }
            return traits
        }
        // Standard to return Artist's metadata
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
						name: self.title,
						description: self.description,
						thumbnail: MetadataViews.HTTPFile( 
            				url: "data:image/png;base64,\(self.image)"
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
				case Type<MetadataViews.Serial>():
					return MetadataViews.Serial(
						0
					)
			}
			return nil
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
        access(UpdateSentiment)
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

    // Print Struct to keep record of owner and serials and unique features
    access(all) struct Print {
        access(all) let id: Int64
        access(all) let pieceId: UInt64
        access(all) let printDimensions: String
        access(all) let printMedium: String
        access(all) let image: String
        access(all) var totalSupply: Int64
        access(all) var extra: AnyStruct?


        init(
        id: Int64,
        pieceId: UInt64,
        printDimensions: String,
        printMedium: String,
        image: String,
        extra: AnyStruct?
        ) {
            self.id = id
            self.pieceId = pieceId
            self.printDimensions = printDimensions
            self.printMedium = printMedium
            self.image = image
            self.totalSupply = 0
            self.extra = extra
        }

        access(all) fun incrementTotalSupply() {
            self.totalSupply = self.totalSupply + 1
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
/*             pre {
                Mneme.artists[artistName] != nil: "This artist does not exist"
                self.currentSupport + supportAmount <= 100: "This will exceed the support limit of 100"
                // Verify if this collector owns a piece from this artist
            } */
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
        access(all) let artistName: String // Certificate 1
        access(all) let pieceTitle: String
        access(all) let serial: UInt64
        access(all) let XUID: String
        access(all) let pieceId: UInt64
        access(all) let description: String
        access(all) let artistAddress: Address
        access(all) let image: String
        access(all) let studio: String
        access(all) var claimed: Bool
        access(all) var toBeClaimedBy: Address


        init(
            artistName: String,
            pieceTitle: String,
            serial: UInt64,
            XUID: String,
            pieceId: UInt64,
            artistAddress: Address,
            description: String,
            image: String,
            studio: String,
            toBeClaimedBy: Address) {
            // Increment the global Cards IDs
            Mneme.totalSupply = Mneme.totalSupply + 1
            self.id = Mneme.totalSupply
            self.artistName = artistName
            self.pieceTitle = pieceTitle
            self.serial = serial
            self.XUID = XUID
            self.pieceId = pieceId
            self.artistAddress = artistAddress
            self.description = description
            self.image = image
            self.studio = studio
            self.claimed = false
            self.toBeClaimedBy = toBeClaimedBy
        }

        // Update claimed status to true
        access(ClaimStatus) fun claimTrue(): Bool {
            pre {
                self.claimed == false: "This Print has already been claimed"
            }
            self.claimed = true
            return self.claimed
        }
        // Update claimed status to false
        access(ClaimStatus) fun claimFalse(): Bool {
            pre {
                self.claimed == true: "This Print has not been claimed yet"
            }
            self.claimed = false
            return self.claimed
        }
        access(all) fun getMetadata(): MetadataViews.Traits? {
            // I need to return this NFT's XUID as part of the metadata
            let metadata = Mneme.getPieceTraits(id: self.id, artistAddress: self.artistAddress)
            
            return metadata
        }
        // Get currentOwner


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
            	let display = Mneme.getPieceDisplayView(id: self.id, artistAddress: self.artistAddress)
                let traits = Mneme.getPieceTraits(id: self.id, artistAddress: self.artistAddress)
                switch view {
				case Type<MetadataViews.Display>():
					return display
				case Type<MetadataViews.Traits>():
					return traits
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
                    // Get the artist's id  
                    let artistId = Mneme.getArtistId(address: self.artistAddress)
                    let royalties = Mneme.getArtistRoyalties(address: self.artistAddress, id: artistId)!
          			return MetadataViews.Royalties([
            			MetadataViews.Royalty(
              				receiver: getAccount(Mneme.account.address).capabilities.get<&FlowToken.Vault>(/public/flowTokenReceiver),
              				cut: royalties, 
              				description: "\(self.artistName)'s community pool percentage is \(royalties)"
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
            // Mneme.prints[newMneme.id] = self.owner?.address
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
        // Claim Print
/*         access(ClaimPrint) fun claimPrint(id: UInt64) {
            let storage = Mneme.account.storage.borrow<auth(DeliverPrint) &Mneme.ArtStorage>(from: Mneme.ArtStoragePath)!
            
            let token <- storage.deliverPrint(address: self.owner!.address, id: id)
            self.deposit(token: <- token)
        } */
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
        access(AddArtist) fun createArtist(
            name: String,
            biography: String,
            nationality: String,
            preferredMedium: String,
            socials: {String: String},
            representation: String?,
            accountAddress: Address,
            communityRoyalties: UFix64,
            image: String): UInt64 {
         pre {
                Mneme.artists[accountAddress] == nil: "There's already an artist with this account address."
            }
            // borrow ArtDrop from Account
            let storage = Mneme.account.storage.borrow<auth(AddArtist) &Mneme.ArtDrop>(from: Mneme.ArtDropPath)!
            // Create new Artist struct
            let newArtist <- create Artist(name, biography, nationality, preferredMedium, socials, representation, accountAddress, communityRoyalties, image)
            // Get the new ID
            let newID = newArtist.id
            // Save artist to the dictionary stored inside the smart contract
            storage.addArtist(newArtist: <- newArtist)
            // Create the community pool
            self.createCommunityPool(artistAddress: accountAddress)
            // Save artist to the dictionary stored inside the smart contract
            Mneme.artists[accountAddress] = name

            return newID
        }
        // createPiece creates a new Piece resource 
        // and stores it in the Piece dictionary in the Mneme smart contract
        //
        // Returns: the ID of the new Piece object
        //
        access(AddPiece) fun addPiece(
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
            image: String) {

            // borrow ArtDrop from Account
            let storage = Mneme.account.storage.borrow<auth(AddPiece) &Mneme.ArtDrop>(from: Mneme.ArtDropPath)!
            // Store the new resource inside the smart contract
            storage.createPiece(title,
                description,
                artistName,
                artistAccount,
                creationDate,
                creationLocation,
                artType,
                medium,
                subjectMatter,
                provenanceNotes,
                acquisitionDetails,
                productionDetails,
                price,
                image
                )

            // return newID
        } 
        // createPrint creates a new Print struct 
        // and stores it in the Prints dictionary inside the Artist's dictionary
        //
        // Returns: the ID of the new Print object
        //
        // updateViews and other functions update the
        // sentiment track for a particular print
        access(CreatePrint) fun createPrint(
            pieceId: UInt64,
            printDimensions: String,
            printMedium: String,
            image: String,
            extra: AnyStruct?
            ) {
            // Increase total prints    
            Mneme.totalPrintBlueprints = Mneme.totalPrintBlueprints + 1
            // Create new struct
            let newPrint = Print(
                id: Mneme.totalPrintBlueprints,
                pieceId: pieceId,
                printDimensions: printDimensions,
                printMedium: printMedium,
                image: image,
                extra: extra
                )

            // Get the ArtDrop resource
            let storage = Mneme.account.storage.borrow<auth(CreatePrint) &Mneme.ArtDrop>(from: Mneme.ArtDropPath)!


            // borrow ArtDrop from Account
        }
        access(UpdateSentiment) fun updateSentiment(
            pieceID: UInt64,
            artistAddress: Address,
            newViewsCount: Int64,
            newLikesCount: Int64,
            newSharesCount: Int64,
            newPurchasesCount: Int64) {
            // borrow ArtDrop from Account
            let storage = Mneme.account.storage.borrow<auth(UpdateSentiment) &Mneme.ArtDrop>(from: Mneme.ArtDropPath)!
            storage.updateSentiment(pieceID, artistAddress, newViewsCount, newLikesCount, newSharesCount, newPurchasesCount)
        } 
        // Mint Print NFT
         access(MintPrint) fun mintPrint(
            printId: UInt64,
            pieceTitle: String,
            artistAddress: Address,
            description: String,
            XUID: String,
            pieceId: UInt64,
            paidPrice: UFix64,
            image: String,
            toBeClaimedBy: Address) {
            pre {
                Mneme.artists[artistAddress] != nil: "This artist does not exist"
            }

            // Add XUID to the PrintsRecord
/*             let storage = Mneme.account.storage.borrow<auth(MintPrint) &Mneme.PrintsRecord>(from: Mneme.PrintsRecordStoragePath)!
            // If this function fails, then the XUID is already in the PrintsRecord
            storage.addPrint(XUID: XUID, id: pieceId, address: toBeClaimedBy)
            // Create NFT
            // NEED TO DO SOMETHING WITH PAID PRICE
            let nft <- create NFT(
                XUID: XUID,
                pieceTitle: pieceTitle,
                pieceId: pieceId,
                artistName: Mneme.artists[artistAddress]!,
                artistAddress: artistAddress,
                description: description,
                image: image,
                toBeClaimedBy: toBeClaimedBy
                )
            // Copy Id
            let id = nft.id
            // Send NFT to artist's collection
            let artistAccount = getAccount(artistAddress)
            let artistCollection = artistAccount.capabilities.borrow<&{NonFungibleToken.Receiver}>(Mneme.CollectionPublicPath)!
            artistCollection.deposit(token: <- nft)
            // emit event   
            emit PrintMinted(id: id, xuid: XUID, pieceId: pieceId, toBeClaimedBy: toBeClaimedBy) */
        }  
        // Helper function to create the community pool
          access(self) fun createCommunityPool(artistAddress: Address) {
            pre {
                Mneme.artists[artistAddress] == nil: "This artist already has a community pool"
            } 
            // This pool is either going to be on 30 days period or per season
            // If it is per season, then it's tied to that season's NFTs
            let path = "Mneme_artist_\(artistAddress)_community_pool"
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
    access(all) view fun getAllArtistsNames(): [String] {
        return self.artists.values
    }
    // public function to get an Artist's metadata by id
    access(all) fun getArtistTraits(address: Address): MetadataViews.Traits? {
        pre {
            Mneme.artists[address] != nil: "This artist does not exist"
        }
        // borrow ArtDrop from Account
        let storage = Mneme.account.storage.borrow<&Mneme.ArtDrop>(from: Mneme.ArtDropPath)!
        let name = Mneme.artists[address]!
        let artist = storage.getArtist(address: address)
        return artist
    }
    // public function to get an Artist's id
    access(all) fun getArtistId(address: Address): UInt64 {
        pre {
            Mneme.artists[address] != nil: "This artist does not exist"
        }
        let storage = Mneme.account.storage.borrow<&Mneme.ArtDrop>(from: Mneme.ArtDropPath)!
        let id = storage.getArtistId(address: address)
        return id
    }
    // Get Artist account address
/*     access(all) fun getArtistAccountAddress(id: UInt64): Address {
        pre {
            Mneme.artists[id] != nil: "This artist does not exist"
        }
        let storage = Mneme.account.storage.borrow<&Mneme.ArtDrop>(from: Mneme.ArtDropPath)!
        let name = Mneme.artists[id]!
        let accountAddress = storage.getArtistAccountAddress(name: name)
        return accountAddress
    } */
    // Get Artist royalties
    access(all) fun getArtistRoyalties(address: Address, id: UInt64): UFix64? {
        pre {
            Mneme.artists[address] != nil: "This artist does not exist"
        }
        let storage = Mneme.account.storage.borrow<&Mneme.ArtDrop>(from: Mneme.ArtDropPath)!
        let name = Mneme.artists[address]!
        let royalties = storage.getArtistRoyalties(address: address)
        return royalties
    }
    // Public function to get an Artist's community pool
/*     access(all) fun getArtistCommunityPool(id: UInt64): UFix64 {
        pre {
            Mneme.artists[id] != nil: "This artist does not exist"
        }

        let path = PublicPath(identifier: "Mneme_artist_\(id)_community_pool")!
		let artistTreasury = getAccount(Mneme.account.address).capabilities.borrow<&{FungibleToken.Balance}>(path)!
        return artistTreasury.balance
    } */
    // public function to get a dictionary of all artists
/*     access(all) view fun getAllPieces(): {String: Mneme.Piece} {
        // Borrow public capability for the art storage
        let storage = Mneme.account.capabilities.borrow<&Mneme.ArtDrop>(Mneme.ArtDropPublicPath)!
        let pieces = storage.getAllPieces()

        return pieces
    } */
    // public function to get the sentiment on a Piece
   /*  access(all) view fun getPieceSentiment(pieceName: String): Sentiment {
        // borrow ArtDrop from Account
        let storage = Mneme.account.capabilities.borrow<&{Mneme.ArtDropPublic}>(Mneme.ArtDropPublicPath)!
        let piece = storage.getPiece(pieceName)
        return piece.sentimentTrack
    }  */
   
    // public function to get a Piece's metadata
    access(all) fun getPieceTraits(id: UInt64, artistAddress: Address): MetadataViews.Traits {
        pre {
            self.artists[artistAddress] != nil: "This artist does not exist"
        }
        let storage = Mneme.account.capabilities.borrow<&Mneme.ArtDrop>(Mneme.ArtDropPublicPath)!

        let traits = storage.getPiece(id: id, artistAddress: artistAddress)!
        return traits
    } 
    // public function to get a Piece's display view
    access(all) fun getPieceDisplayView(id: UInt64, artistAddress: Address): MetadataViews.Display {
        pre {
            self.artists[artistAddress] != nil: "This artist does not exist"
        }
        let storage = Mneme.account.capabilities.borrow<&Mneme.ArtDrop>(Mneme.ArtDropPublicPath)!

        let display = storage.getPieceDisplayView(id: id, artistAddress: artistAddress)!
        return display
    }
        // public getter for print's owner
    access(all) fun getPrint(xuid: String): AnyStruct? {
/*         pre {
            self.prints[id] != nil: "This print does not exist"
        } */
        // get artist address from PrintsRecord
        let storage = Mneme.account.storage.borrow<&Mneme.PrintsRecord>(from: Mneme.PrintsRecordStoragePath)!
        let print = storage.getPrint(xuid: xuid)
        let account = getAccount(print.values[0]) 
        let cap = account.capabilities.borrow<&Mneme.Collection>(Mneme.CollectionPublicPath)!
        let resolver = cap.borrowViewResolver(id: print.keys[0])!
        let displayView: MetadataViews.Display = MetadataViews.getDisplay(resolver)!
        let serialView = MetadataViews.getSerial(resolver)!
        let traits = MetadataViews.getTraits(resolver)!
        let printData = {
            "display": displayView,
            "serial": serialView,
            "traits": traits
        }
        return printData
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
    access(all) view fun resolveContractView(resourceType: Type?, viewType: Type): AnyStruct? {
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
        self.pieces = {}

        self.totalSupply = 0
        self.totalArtist = 0
        self.totalPieces = 0
        self.totalPrintBlueprints = 0

        let identifier = "Mneme_\(self.account.address))"
        // Set the named paths
		self.CollectionStoragePath = StoragePath(identifier: identifier)! 
		self.CollectionPublicPath = PublicPath(identifier: identifier)!
		self.AdministratorStoragePath = StoragePath(identifier: "\(identifier)Administrator")!
		self.ArtDropPath = StoragePath(identifier: "\(identifier)ArtDrop")!
        self.ArtDropPublicPath = PublicPath(identifier: "\(identifier)ArtDropPublic")!
        self.PistisStoragePath = StoragePath(identifier: "\(identifier)Pistis")!
        self.PistisPublicPath = PublicPath(identifier: "\(identifier)Pistis")!
        self.PrintsRecordStoragePath = StoragePath(identifier: "\(identifier)PrintsRecord")!
		// Create a Administrator resource and save it to Mneme account storage
		let administrator <- create Administrator()
		self.account.storage.save(<- administrator, to: self.AdministratorStoragePath)
		// Create a ArtDrop resource and save it to Mneme account storage
		let artDrop <- create ArtDrop()
		self.account.storage.save(<- artDrop, to: self.ArtDropPath)
        // Create a public capability for the art storage
        let artDropCap = self.account.capabilities.storage.issue<&Mneme.ArtDrop>(self.ArtDropPath)
		self.account.capabilities.publish(artDropCap, at: self.ArtDropPublicPath)
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
        // Create a PrintsRecord resource and save it to storage
		let printsRecord <- create PrintsRecord()
		self.account.storage.save(<- printsRecord, to: self.PrintsRecordStoragePath)
	}
}