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
	)
	// Get all the pools by category
	o.Script("Pistis/get_pools_by_category",
		WithArg("category", "Art"),
	)
	// Add Receipt to the Pool
	o.Tx("Pistis/add_receipt",
		WithSigner("account"),
		WithArg("poolName", "Matina Hoffman"),
		WithArg("receiptName", "Ancesteal Ascension"),
		WithArg("receiptDescription", "Receipt 1 Description"),
		WithArg("receiptImage", "https://www.matinahoffman.com/ancestral-ascension"),
		WithArg("receiptMetadata", "{}"),
		WithArg("earlyAdopter", "{10: 3.0, 20: 2.0, 50: 1.5}"),
		WithArg("stakingWeight", "{10: 1.5, 20: 2.0, 50: 3.0}"),
		WithArg("loyaltyWeight", "{3: 1.5, 9: 2.0, 10: 3.0}"),
	)
	// Get all the pools
	o.Script("Pistis/get_pools")
	// Mint a receipt
	o.Tx("Pistis/mint_receipt",
		WithSigner("account"),
		WithArg("poolName", "Matina Hoffman"),
		WithArg("receiptName", "Ancesteal Ascension"),
	)

}
