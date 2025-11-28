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
		// WithNetwork("testnet"),
	)

	fmt.Println("Testing Contract")

	color.Blue("Mneme Contract testing")

	color.Green("Admin creates an Artist resource")

	// Admin creates an Edition rule for an artist
	o.Tx("Mneme/admin/create_edition",
		WithSigner("account"),
		WithArg("name", "Sunflowers"),
		WithArg("price", "100.0"),
		WithArg("type", "Limited Edition"),
		WithArg("story", "John Doe's Sunflowers"),
		WithArg("dimensions", `{"Width": "100 in", "Height": "100 in", "Weight": "10 lbs"}`),
		WithArg("reprintLimit", "100"),
		WithArg("artistAddress", "bob"),
	).Print()
	// Get all the Artist and their Editions
	o.Script("get_all_artists").Print()
	// Get the edition rule
	o.Script("get_edition_metadata",
		WithArg("artistAddress", "bob"),
		WithArg("editionId", 1),
	).Print()
	// Artist claims the authorized capability to mint a Certificate NFT
	/* 	o.Tx("Mneme/artist/claim_authorized_capability",
		WithSigner("bob"),
	).Print() */

}
