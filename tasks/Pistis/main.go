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

	// Add a new vault to the pool
	o.Tx("Pistis/add_vault",
		WithSigner("account"),
	)

	// Get the pools
	o.Script("Pistis/get_pools",
		WithArg("address", "account"),
	)

	o.Script("Pistis/get_vault_balance",
		WithArg("address", "account"),
	)

	// Deposit to the vault
	o.Tx("Pistis/deposit_to_vault",
		WithSigner("bob"),
		WithArg("amount", "5.0"),
		WithArg("id", "1"),
		WithArg("account", "account"),
	)

	o.Script("Pistis/get_vault_balance",
		WithArg("address", "account"),
	)

	o.Tx("Pistis/withdraw_flowtoken",
		WithSigner("account"),
	)

	o.Script("Pistis/get_vault_balance",
		WithArg("address", "account"),
	)
}
