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

	color.Blue("Pistis Contract testing")

	color.Green("User creates a new project on the Pistis contract")
	// Create a new Artist struct on the Mneme contract
	o.Tx("Mneme/admin/create_artist",
		WithSigner("account"),
		WithArg("name", "Beeple"),
		WithArg("biography", "Born on Earth"),
		WithArg("nationality", "human"),
		WithArg("preferredMedium", "digital"),
		WithArg("socials", `{"Twitter": "www.x.com/beeple"}`),
		WithArg("representation", ""),
		WithArg("accountAddress", "bob"),
	)
	o.Script("get_all_artists")
	// Create a new Piece blueprint
	color.Green("Admin creates a Piece resource")
	o.Tx("Mneme/admin/create_piece_blueprint",
		WithSigner("account"),
		WithArg("name", "Bull Run"),
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
	)
	o.Script("get_all_pieces")

	// Mint a Piece into Admin's account
	o.Tx("Mneme/admin/mint_piece",
		WithSigner("account"),
		WithArg("recipient", "account"),
	)
	// TEST
	//
	o.Script("Pistis/test",
		WithArg("address", "account"),
	)
	// Create a new Artist struct

	/* 	o.Tx("Pistis/create_project",
	   		WithSigner("account"),
	   		WithArg("newProjectName", "Mneme"),
	   	)
	   	o.Script("Pistis/get_all_projects") */
	// Create a new Piece blueprint

	/* - User has to specify the following:
	1. Define the name of the project and its description
	2. The NFT collection used as proof of support metadata
	3. The multipliers for the editions of these NFTs
	4. The number of soul-tokens per account that participates in the project */

}
