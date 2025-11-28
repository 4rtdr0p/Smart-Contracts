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

	// Create a new Edition resource
	o.Tx("Mneme/admin/create_edition",
		WithSigner("account"),
		WithArg("artistAddress", "bob"),
		WithArg("name", "John Doe"),
		WithArg("description", "German-born, John Doe partially grew up in Cameroon, West Africa. She studied art education with Professor Kiefer (father of Anselm Kiefer) and sculpting with Professor Spelmann at the Johann Wolfgang Goethe University in Frankfurt/Main, Germany. During this time she also met the Fantastic Realist, Robert Venosa, and greatly inspired by his work, began her work as a painter. During their 30 year relationship they closely worked together, taught workshops worldwide and shared studios, both in the US as well as in Europe. Today John Doe works as a painter and sculptress and remains a central figure in contemporary Visionary Art. Her paintings offer the viewer a detailed glimpse into her inner landscapes - imagery that has been inspired by expanded states of consciousness. Her Visionary Realism is decidedly feminine and places the Universal Woman in an intimate cosmos. She transcribes her ecstatic experiences but also her subtle reflections on the nature of women in a realistic style which marries the fantastic to the sacred. The artist has spoken on behalf of art and culture at events and conferences such as 'Estados Modificados De Consciencia', Universiity of Cuernavaca Mexico, 'Chimeria', France, and the 'The Promethean Impulse' at the HR Giger Museum in Switzerland, et. al.. In addition the artist has created original art and photography for numerous CD as well as book and magazine covers. John Doe has been exhibiting her work worldwide since 1985 and is represented in the permanent collection of NAIA Museum, France. She currently keeps studios in the USA as well as France."),
		WithArg("thumbnail", "https://www.johndoe.com/images/sunflowers.jpg"),
	).Print()

	// Create a new Artist struct
	/* 	o.Tx("Mneme/admin/create_artist",
		WithSigner("account"),
		WithArg("name", "John Doe"),
		WithArg("description", "German-born, John Doe partially grew up in Cameroon, West Africa. She studied art education with Professor Kiefer (father of Anselm Kiefer) and sculpting with Professor Spelmann at the Johann Wolfgang Goethe University in Frankfurt/Main, Germany. During this time she also met the Fantastic Realist, Robert Venosa, and greatly inspired by his work, began her work as a painter. During their 30 year relationship they closely worked together, taught workshops worldwide and shared studios, both in the US as well as in Europe. Today John Doe works as a painter and sculptress and remains a central figure in contemporary Visionary Art. Her paintings offer the viewer a detailed glimpse into her inner landscapes - imagery that has been inspired by expanded states of consciousness. Her Visionary Realism is decidedly feminine and places the Universal Woman in an intimate cosmos. She transcribes her ecstatic experiences but also her subtle reflections on the nature of women in a realistic style which marries the fantastic to the sacred. The artist has spoken on behalf of art and culture at events and conferences such as 'Estados Modificados De Consciencia', Universiity of Cuernavaca Mexico, 'Chimeria', France, and the 'The Promethean Impulse' at the HR Giger Museum in Switzerland, et. al.. In addition the artist has created original art and photography for numerous CD as well as book and magazine covers. John Doe has been exhibiting her work worldwide since 1985 and is represented in the permanent collection of NAIA Museum, France. She currently keeps studios in the USA as well as France."),
		WithArg("thumbnail", "https://www.johndoe.com/images/sunflowers.jpg"),
		WithArg("accountAddress", "bob"),
	).Print() */
	// Get the artist
	o.Script("Mneme/get_artist",
		WithArg("accountAddress", "bob"),
	).Print()
	// Admin creates an Edition rule for an artist
	o.Tx("Mneme/admin/create_edition_rule",
		WithSigner("account"),
		WithArg("artistAddress", "bob"),
		WithArg("editionRule", "100"),
	).Print()
	// Artist claims the authorized capability to mint a Certificate NFT
	o.Tx("Mneme/artist/claim_authorized_capability",
		WithSigner("bob"),
	).Print()
	// Artist mints a Certificate NFT from last edition
	o.Tx("Mneme/artist/mint_certificate_nft",
		WithSigner("bob"),
		WithArg("thumbnail", "https://www.johndoe.com/images/sunflowers.jpg"),
	).Print()
}
