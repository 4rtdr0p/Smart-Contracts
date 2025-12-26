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
	//	WithNetwork("testnet"),
	)

	fmt.Println("Testing Contract")

	color.Blue("Escrow Contract testing")

	color.Green("User creates the Escrow")

	// Deposit to the vault
	o.Tx("Escrow/init_escrow",
		WithSigner("alice"),
		WithArg("amount", "5.0"),
		WithArg("receiver", "bob"),
	)

	o.Script("get_flow_balance",
		WithArg("address", "alice"),
	)

	o.Script("get_stored_items",
		WithArg("account", "alice"),
	)

	o.Tx("Escrow/claim_cap_withdraw",
		WithSigner("bob"),
		WithArg("handlerId", "1"),
		WithArg("provider", "alice"),
	)

	o.Script("get_flow_balance",
		WithArg("address", "alice"),
	)

	o.Tx("Escrow/auth_withdrawal",
		WithSigner("bob"),
		WithArg("handlerId", "1"),
	)

}
