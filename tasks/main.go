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

	color.Green("Admin creates an Artist struct")

	// Create a new Artist struct
	o.Tx("Mneme/admin/create_artist",
		WithSigner("account"),
		WithArg("name", "John Doe"),
		WithArg("biography", "German-born, John Doe partially grew up in Cameroon, West Africa. She studied art education with Professor Kiefer (father of Anselm Kiefer) and sculpting with Professor Spelmann at the Johann Wolfgang Goethe University in Frankfurt/Main, Germany. During this time she also met the Fantastic Realist, Robert Venosa, and greatly inspired by his work, began her work as a painter. During their 30 year relationship they closely worked together, taught workshops worldwide and shared studios, both in the US as well as in Europe. Today John Doe works as a painter and sculptress and remains a central figure in contemporary Visionary Art. Her paintings offer the viewer a detailed glimpse into her inner landscapes - imagery that has been inspired by expanded states of consciousness. Her Visionary Realism is decidedly feminine and places the Universal Woman in an intimate cosmos. She transcribes her ecstatic experiences but also her subtle reflections on the nature of women in a realistic style which marries the fantastic to the sacred. The artist has spoken on behalf of art and culture at events and conferences such as 'Estados Modificados De Consciencia', Universiity of Cuernavaca Mexico, 'Chimeria', France, and the 'The Promethean Impulse' at the HR Giger Museum in Switzerland, et. al.. In addition the artist has created original art and photography for numerous CD as well as book and magazine covers. John Doe has been exhibiting her work worldwide since 1985 and is represented in the permanent collection of NAIA Museum, France. She currently keeps studios in the USA as well as France."),
		WithArg("nationality", "German"),
		WithArg("preferredMedium", "Oil on Canvas"),
		WithArg("socials", `{"Website": "https://www.johndoe.com/"}`),
		WithArg("representation", "N/A"),
		WithArg("accountAddress", "0x12ecc177508efad8"),
		WithArg("communityRoyalties", "0.5"),
		WithArg("image", "https://www.johndoe.com/images/sunflowers.jpg"),
	)
	o.Script("get_artist",
		WithArg("name", "John Doe"),
	)
	o.Script("get_all_artists")
	// get that artist's community pool
	o.Script("get_artist_pool",
		WithArg("artistName", "John Doe"),
	)

	// Create a new Piece blueprint
	color.Green("Admin creates a Piece resource")
	o.Tx("Mneme/admin/create_piece_blueprint",
		WithSigner("account"),
		WithArg("title", "Sunflowers"),
		WithArg("description", "Printed on 300 gr, paper stock. With John Doe logo and title. Open edition"),
		WithArg("artistName", "John Doe"),
		WithArg("creationDate", "2008"),
		WithArg("creationLocation", "Unspecified"),
		WithArg("artType", "Psychodelics"),
		WithArg("medium", "Oil on Canvas"),
		WithArg("subjectMatter", "Flowers"),
		WithArg("provenanceNotes", "N/A"),
		WithArg("collection", "VIVA Gallery"),
		WithArg("acquisitionDetails", "N/A"),
		WithArg("price", "844.0"),
		WithArg("encodedImg", "https://www.johndoe.com/images/sunflowers.jpg"),
	)
	// mint
	o.Script("get_all_pieces")
	// Update a Piece's blueprint with sentiment feedback
	o.Tx("mneme/admin/update_piece_sentiments",
		WithSigner("Mneme"),
		WithArg("pieceName", "Tree of Knowledge"),
		WithArg("newViewsCount", 100),
		WithArg("newLikesCount", 100),
		WithArg("newSharesCount", 100),
		WithArg("newPurchasesCount", 100),
	)
	// Get a Piece's views
	o.Script("get_all_pieces")

	// Mint a Piece into bob's account
	o.Tx("Mneme/admin/mint_piece",
		WithSigner("account"),
		WithArg("pieceName", "Sunflowers"),
		WithArg("artistName", "John Doe"),
		WithArg("recipient", "account"),
	)
	// Check the artist's pool
	o.Script("get_artist_pool",
		WithArg("artistName", "Martin"),
	)

	o.Script("get_owned_nfts",
		WithArg("account", "Mneme"),
	)

}
