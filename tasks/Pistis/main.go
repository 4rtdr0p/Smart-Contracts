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

	color.Green("User creates the ArtDrop project under the Art cateogry")

	// Create a new pool
	o.Tx("Pistis/mint_NFT",
		WithSigner("account"),
		WithArg("newNFTName", "Matina Hoffman"),
		WithArg("newNFTDescription", "Matina Hoffman"),
		WithArg("newNFTPreview", "https://www.matinahoffman.com/ancestral-ascension"),
	)

}
