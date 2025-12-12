package main

import (
	"testing"

	. "github.com/bjartek/overflow/v2"
	"github.com/fatih/color"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Full cover test suite for the whole app Flow

func TestFullFlow(t *testing.T) {
	o, err := OverflowTesting()
	require.NoError(t, err)
	require.NotNil(t, o)
	assert.NoError(t, err)

	color.White("STARTING ArtDrop FLOW TEST")
	color.Green("GREEN transactions are meant to SUCCEED")
	color.Red("Red transactions are meant to FAIL")
	// initialize the contract and setup Bob account for ArtDrop collection
	color.Green("Bob account setup to Mneme")
	o.Tx("Mneme/setup",
		WithSigner("bob"),
	).AssertSuccess(t).Print()
	color.Green("Alice account setup to Mneme")
	o.Tx("Mneme/setup",
		WithSigner("alice"),
	).AssertSuccess(t).Print()
	// Admin creates an Edition rule for an artist
	color.Green("Admin creates an Edition rule for an artist")
	o.Tx("Mneme/admin/create_edition",
		WithSigner("account"),
		WithArg("name", "Sunflowers"),
		WithArg("price", "100.0"),
		WithArg("type", "Limited Edition"),
		WithArg("story", "John Doe's Sunflowers"),
		WithArg("dimensions", `{"Width": "100 in", "Height": "100 in", "Weight": "10 lbs"}`),
		WithArg("reprintLimit", "100"),
		WithArg("artistAddress", "bob"),
	).AssertSuccess(t).Print()
	// Get all the Artist and their Editions
	color.Green("Get all the Artist and their Editions")
	o.Script("get_all_artists").Print()
	// Get the edition rule
	color.Green("Get the edition rule")
	o.Script("get_edition_metadata",
		WithArg("artistAddress", "bob"),
		WithArg("editionId", 1),
	).Print()
	// Admin edits the edition rule
	color.Green("Admin edits the edition rule")
	o.Tx("Mneme/admin/edit_edition",
		WithSigner("account"),
		WithArg("editionID", 1),
		WithArg("artistAddress", "bob"),
		WithArg("name", "Sunflowers (edited)"),
		WithArg("price", "100.0"),
		WithArg("type", "Limited Edition"),
		WithArg("story", "John Doe's Sunflowers (edited)"),
		WithArg("dimensions", `{"Width": "100 in", "Height": "100 in", "Weight": "10 lbs"}`),
		WithArg("reprintLimit", "100"),
	).AssertSuccess(t).Print()
	// Get the edition rule
	color.Green("Get the edition rule")
	o.Script("get_edition_metadata",
		WithArg("artistAddress", "bob"),
		WithArg("editionId", 1),
	).Print()
	// Admin mints a Certificate NFT
	color.Green("Admin mints a Certificate NFT")
	o.Tx("Mneme/admin/mint_certificate",
		WithSigner("account"),
		WithArg("artistAddress", "bob"),
		WithArg("editionId", 1),
		WithArg("thumbnail", "https://www.johndoe.com/images/sunflowers.jpg"),
	).AssertSuccess(t).Print()
	// Bob attempts to mint a Certificate NFT
	// without the authorized capability
	color.Red("Bob attempts to mint a Certificate NFT without the authorized capability")
	o.Tx("Mneme/mint_certificate",
		WithSigner("bob"),
		WithArg("artistAddress", "bob"),
		WithArg("editionId", 1),
		WithArg("thumbnail", "https://www.johndoe.com/images/sunflowers.jpg"),
	).AssertFailure(t, "unexpectedly found nil while forcing an Optional value").Print()
	// Bob claims the authorized capability to mint a Certificate NFT
	color.Green("Bob claims the authorized capability to mint a Certificate NFT")
	o.Tx("Mneme/claim_mint_cap",
		WithSigner("bob"),
		WithArg("editionId", 1),
	).AssertSuccess(t).Print()
	// Bob mints a Certificate NFT
	color.Green("Bob mints a Certificate NFT")
	o.Tx("Mneme/authorized_mint_certificate",
		WithSigner("bob"),
		WithArg("artistAddress", "bob"),
		WithArg("editionId", 1),
		WithArg("thumbnail", "https://www.johndoe.com/images/sunflowers.jpg"),
	).AssertSuccess(t).Print()
	// Bob checks if she has the Certificate NFT
	color.Green("Bob checks if she has the Certificate NFT")
	o.Script("get_owned_nfts",
		WithArg("account", "bob"),
	).Print()
	// Bob checks if he has the loyalty points
	color.Green("Bob checks if he has the loyalty points")
	o.Script("Pistis/get_loyalty_by_address",
		WithArg("address", "bob"),
	).Print()
	// Bob(artist) transfers the Certificate NFT to Alice
	color.Green("Bob(artist) transfers the Certificate NFT to Alice")
	o.Tx("Mneme/transfer_certificate",
		WithSigner("bob"),
		WithArg("to", "alice"),
		WithArg("id", 1),
	).AssertSuccess(t).Print()
	// Alice checks if she has the Certificate NFT
	color.Green("Alice checks if she has the Certificate NFT")
	o.Script("get_owned_nfts",
		WithArg("account", "alice"),
	).Print()
	// Add a new vault to the pool
	color.Green("Add a new vault to the pool")
	o.Tx("Pistis/add_vault",
		WithSigner("alice"),
	).AssertSuccess(t).Print()
	color.Green("Deposit Flow to a Certificate NFT")
	o.Tx("Pistis/deposit_to_vault",
		WithSigner("account"),
		WithArg("account", "alice"),
		WithArg("amount", "1.0"),
		WithArg("id", 1),
	).AssertSuccess(t).Print()
}
