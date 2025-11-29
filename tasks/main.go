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

	color.Green("Setup bob account for ArtDrop collection")
	// Setup artist account for ArtDrop collection
	o.Tx("Mneme/setup",
		WithSigner("bob"),
	).Print()

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
	// Admin mints a Certificate NFT
	o.Tx("Mneme/admin/mint_certificate",
		WithSigner("account"),
		WithArg("artistAddress", "bob"),
		WithArg("editionId", 1),
		WithArg("thumbnail", "https://www.johndoe.com/images/sunflowers.jpg"),
	).Print()
	// Bob attempts to mint a Certificate NFT
	// without the authorized capability
	// Bob claims the authorized capability to mint a Certificate NFT
	o.Tx("Mneme/claim_mint_cap",
		WithSigner("bob"),
		WithArg("editionId", 1),
	).Print()

	o.Tx("Mneme/authorized_mint_certificate",
		WithSigner("bob"),
		WithArg("artistAddress", "bob"),
		WithArg("editionId", 1),
		WithArg("thumbnail", "https://www.johndoe.com/images/sunflowers.jpg"),
	).Print()

}
