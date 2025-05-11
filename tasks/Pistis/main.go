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
	o.Tx("Pistis/create_pool",
		WithSigner("account"),
		WithArg("newPoolName", "Matina Hoffman"),
		WithArg("category", "Art"),
		WithArg("metadata", "{}"),
	)
	// Get all the pools by category
	o.Script("Pistis/get_pools_by_category",
		WithArg("category", "Art"),
	)
}
