package main

import (
	"fmt"

	//if you imports this with .  you do not have to repeat overflow everywhere
	. "github.com/bjartek/overflow/v2"
	"github.com/fatih/color"
)

// ReadFile reads a text file and returns an array of paragraphs

func main() {
	o := Overflow(
		WithGlobalPrintOptions(),
		// WithNetwork("mainnet"),
	)

	fmt.Println("Testing Contract")

	color.Blue("Mneme Contract testing")

	color.Green("Admin creates an Artist struct")

	// Setup Bob to be a collector
	o.Tx("mneme/setup",
		WithSigner("bob"),
	)

	// Create a new Artist struct
	o.Tx("mneme/admin/create_artist",
		WithSigner("account"),
		WithArg("name", "Beeple"),
		WithArg("biography", "Born on Earth"),
		WithArg("nationality", "human"),
		WithArg("preferredMedium", "digital"),
		WithArg("socials", `{"Twitter": "www.x.com/beeple"}`),
		WithArg("representation", ""),
		WithArg("accountAddress", "bob"),
		WithArg("communityRoyalties", "0.1"),
	)
	o.Script("get_all_artists")
	// get that artist's community pool
	o.Script("get_artist_pool",
		WithArg("artistName", "Beeple"),
	)
	// Create a new Piece blueprint
	color.Green("Admin creates a Piece resource")
	o.Tx("mneme/admin/create_piece_blueprint",
		WithSigner("account"),
		WithArg("title", "Bull Run"),
		WithArg("description", "A bull with a BitCoin on its back"),
		WithArg("artistName", "Beeple"),
		WithArg("creationDate", "Spring 2019"),
		WithArg("creationLocation", "Charleston, SC, USA"),
		WithArg("artType", "Digital"),
		WithArg("medium", "Photoshop"),
		WithArg("subjectMatter", "Bitcoin"),
		WithArg("provenanceNotes", ""),
		WithArg("collection", "Everydays, the 2020 Collection!"),
		WithArg("acquisitionDetails", "N/A"),
		WithArg("price", "1000.0"),
	)
	o.Script("get_all_pieces")
	// Update a Piece's blueprint with sentiment feedback
	o.Tx("mneme/admin/update_piece_sentiments",
		WithSigner("account"),
		WithArg("pieceName", "Bull Run"),
		WithArg("newViewsCount", 100),
		WithArg("newLikesCount", 100),
		WithArg("newSharesCount", 100),
		WithArg("newPurchasesCount", 100),
	)
	// Get a Piece's views
	o.Script("get_all_pieces")

	// Mint a Piece into bob's account
	o.Tx("mneme/admin/mint_piece",
		WithSigner("account"),
		WithArg("pieceName", "Bull Run"),
		WithArg("artistName", "Beeple"),
		WithArg("recipient", "account"),
	)
	// Check the artist's pool
	o.Script("get_artist_pool",
		WithArg("artistName", "Beeple"),
	)

}
