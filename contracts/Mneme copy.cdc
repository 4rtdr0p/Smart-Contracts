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
    access(self) var artists: {String: Address}

    // Track of total supply of Mneme NFTs
    access(all) var totalSupply: UInt64
    access(all) var totalArtist: UInt64
    access(all) var totalEditions: UInt64
    access(all) var totalPrints: Int64
    // -----------------------------------------------------------------------
    // Mneme account paths
    // -----------------------------------------------------------------------
    access(all) var AdministratorStoragePath: StoragePath


    // -----------------------------------------------------------------------
    // Mneme contract-level Composite Type definitions
    // -----------------------------------------------------------------------
    // These are just *definitions* for Types that this contract
    // and other accounts can use. These definitions do not contain
    // actual stored values, but an instance (or object) of one of these Types
    // can be created by this contract that contains stored values.
    // -----------------------------------------------------------------------
    // The Edition resource represents the Art's metadata
    // it serves as a blueprint from which NFTs can be minted
    access(all) resource Edition {
        access(all) let id: UInt64
        access(all) let title: String
        access(all) let description: String
        access(all) let image: String
        access(all) let sentimentTrack: Sentiment
        access(all) var extra: {String: AnyStruct}
        access(all) var proofs: @{UInt64: Proof}

        init(
            _ title: String,
            _ description: String,
            _ image: String
        ) {
            // Increase total supply of Pieces
            Mneme.totalEditions = Mneme.totalEditions + 1
            // Set the Piece's metadata
            self.title = title
            self.description = description
            self.image = image
            self.id = Mneme.totalEditions
            self.sentimentTrack = Sentiment()
            self.extra = {}
            self.proofs <- {}
        }
        access(all) fun updateSentiment(
            _ newViewsCount: Int64,
            _ newLikesCount: Int64,
            _ newSharesCount: Int64,
            _ newPurchasesCount: Int64
        ) {
            pre {
                self.sentimentTrack.views <= newViewsCount: "The new Views count has to be equal or higher than the current count"
                self.sentimentTrack.likes <= newLikesCount: "The new Likes count has to be equal or higher than the current count"
                self.sentimentTrack.shares <= newSharesCount: "The new Shares count has to be equal or higher than the current count"
                self.sentimentTrack.purchases <= newPurchasesCount: "The new Purchases count has to be equal or higher than the current count"
            }
            self.sentimentTrack.views = newViewsCount
            self.sentimentTrack.likes = newLikesCount
            self.sentimentTrack.shares = newSharesCount
            self.sentimentTrack.purchases = newPurchasesCount

            // Emit Event
        }
        access(all) fun createProof(
            _ printingDetails: {String: AnyStruct},
            _ image: String
        ) {
            let proof <- create Proof(self.id, printingDetails, image)
            let id = proof.id
            self.proofs[id] <-! proof
            // Emit Event
            emit ProofCreated(id: id, pieceId: self.id, printingDetails: printingDetails)
        }
    }
    // -----------------------------------------------------------------------
    // Print resource represents each different variant ArtDrop has for sale 
    // for a particular 
    access(all) resource Print {
        access(all) let id: UInt64
        access(all) let editionId: UInt64
        access(all) let printingDetails: {String: AnyStruct}
        access(all) var minted: UInt64
        access(all) var sentimentTrack: Sentiment
        access(all) let image: String
        access(all) var prints: {String: UInt64}
        access(all) var extra: {String: AnyStruct}

        init(
            _ editionId: UInt64,
            _ printingDetails: {String: AnyStruct},
            _ image: String
        ) {
            Mneme.totalPrints = Mneme.totalPrints + 1
            self.id = Mneme.totalPrints
            self.editionId = editionId
            self.minted = 0
            self.printingDetails = printingDetails
            self.sentimentTrack = Sentiment()
            self.image = image
            self.prints <- {}
            self.extra = {}
            // Emit Event
            // emit EditionCreated(id: self.id, editionId: self.editionId, printingDetails: self.printingDetails)
        }

        access(all) fun updateSentiment(
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
    // Resource for Artist's metadata
    access(all) resource ArtDropVault {
        // Unique ID for artist
        access(all) let id: UInt64
        access(all) let accountAddress: Address
        access(all) let ownerName: String
        access(all) var socials: {String: String}
        access(all) var communityRoyalties: UFix64
        access(all) var image: String
        access(all) var extra: {String: AnyStruct}
        // Dictionary to map Piece by id to their metadata
        access(all) var editions: @{UInt64: Edition}
        // Dictionary to map Piece by title to their id
        access(all) var editionsByTitle: {String: UInt64}
        // Dictionary to map Print by id tot their metadata
/*         access(all) var prints: @{UInt64: Print}
        // Dictionary to map Print by pieceId to their id
        access(all) var printsByPieceId: {UInt64: UInt64} */

        init(
            _ name: String,
            _ socials: {String: String},
            _ accountAddress: Address,
            _ communityRoyalties: UFix64,
            _ image: String
        ) {
            // Increase total supply of Artists
            Mneme.totalArtist = Mneme.totalArtist + 1

            self.id = Mneme.totalArtist
            self.ownerName = name
            self.socials = socials
            self.accountAddress = accountAddress
            self.communityRoyalties = communityRoyalties
            self.extra = {}
            self.image = image
            self.editions <- {}
            self.editionsByTitle = {}
/*             self.prints <- {}
            self.printsByPieceId <- {} */
            // Emit EvENT
        }

        access(all) fun createEdition(
            title: String,
            description: String,
            image: String
            ) {
            pre {
                self.piecesByTitle[title] == nil: "There's already a piece with this title"
            }

            let edition <- create Edition(title, description, image)
            let id = edition.id
            self.editionsByTitle[title] = id
            self.editions[id] <-! edition
            // emit event
            emit EditionCreated(id: id, title: title, artist: self.name)
        }
        // Get a Piece's metadata
        access(all) fun getPieceMetadata(id: UInt64): MetadataViews.Traits {
            pre {
                self.editions[id] != nil: "There's no Edition by the id: \(id)"
            }
            let edition = &self.editions[id] as &Edition?
            let metadata = piece!.resolveView(Type<MetadataViews.Traits>()) as! MetadataViews.Traits
            return metadata
        }
        // Function to update a Piece's sentiment
/*         access(all) fun updatePieceSentiment(
            id: UInt64,
            newViewsCount: Int64,
            newLikesCount: Int64,
            newSharesCount: Int64,
            newPurchasesCount: Int64) {
            pre {
                self.pieces[id] != nil: "There's no Piece by the id: \(id)"
            }
            let piece = &self.pieces[id] as &Piece?
            piece?.updateSentiment(newViewsCount, newLikesCount, newSharesCount, newPurchasesCount) ?? panic("Piece not found")
        } */







        // Standard to return views inside this Resource
/*         access(all) view fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Royalties>(),
                Type<MetadataViews.Traits>(),
			]
        } */


        // Artist struct functionality

        // Update attribute variable
    }

    access(all) resource Administrator {

    }
    init() {
        
        self.artists = {}
        self.totalSupply = 0
        self.totalArtist = 0
        self.totalEditions = 0
        self.totalPrints = 0
        
        let identifier = "Mneme_\(self.account.address))"
        // Set the named paths
		self.AdministratorStoragePath = StoragePath(identifier: "\(identifier)Administrator")!


        // Create a Administrator resource and save it to Mneme account storage
		let administrator <- create Administrator()
		self.account.storage.save(<- administrator, to: self.AdministratorStoragePath)
    }
}