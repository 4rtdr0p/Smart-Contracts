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

	// Create a new Artist struct
	o.Tx("Pistis/create_project",
		WithSigner("account"),
		WithArg("newProjectName", "Mneme"),
	)
	o.Script("Pistis/get_all_projects")
	// Create a new Piece blueprint

	/* - User has to specify the following:
	1. Define the name of the project and its description
	2. The NFT collection used as proof of support metadata
	3. The multipliers for the editions of these NFTs
	4. The number of soul-tokens per account that participates in the project */

}
