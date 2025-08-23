package main

import (
	"fmt"
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
	// initialize the contract and setups
	color.Green("Bob account setup to Arsenal")
	o.Tx("Mneme/setup",
		WithSigner("bob"),
	).AssertSuccess(t).Print()

	color.Green("Admin creates an Artist resource")
	// Admin create artist
	id, error := o.Tx("Mneme/admin/create_artist",
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
	).AssertSuccess(t).Print().GetIdFromEvent("ArtistCreated", "id")
	fmt.Println(error, "artist id ", id)
	// Get the artist
	o.Script("get_artist",
		WithArg("address", "0x12ecc177508efad8"),
	).Print()

	// FAILED create artist with same id
	color.Red("Admin creates an Artist resource with the same Address and it should fail")
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
	).AssertFailure(t, "There's already an artist with this account address.").Print()
	// Create a new Piece blueprint
	color.Green("Admin creates piece Blueprint under Artist")
	pieceId, error := o.Tx("Mneme/admin/create_piece_blueprint",
		WithSigner("account"),
		WithArg("title", "Sunflowers"),
		WithArg("description", "Printed on 300 gr, paper stock. With John Doe logo and title. Open edition"),
		WithArg("artistAddress", "0x12ecc177508efad8"),
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
	).AssertSuccess(t).Print().GetIdFromEvent("PieceCreated", "id")
	fmt.Println(error, pieceId)
	// Get Piece
	o.Script("get_piece",
		WithArg("id", pieceId),
		WithArg("artistName", "John Doe"),
	)
	// FAILED Create Piece with same title under same artist
	color.Red("Admin creates a Piece with the same title under same artist and it should fail")
	o.Tx("Mneme/admin/create_piece_blueprint",
		WithSigner("account"),
		WithArg("title", "Sunflowers"),
		WithArg("description", "Printed on 300 gr, paper stock. With John Doe logo and title. Open edition"),
		WithArg("artistAddress", "0x12ecc177508efad8"),
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
	).AssertFailure(t, `There's already a piece with this title`).Print()
	// Mint a new Print
	color.Green("Admin mints a new Print")
	o.Tx("Mneme/admin/mint_print",
		WithSigner("account"),
		WithArg("XUID", "1234567890"),
		WithArg("pieceName", "Sunflowers"),
		WithArg("artistAddress", "0x12ecc177508efad8"),
		WithArg("paidPrice", "844.0"),
		WithArg("description", "Printed on 300 gr, paper stock. With John Doe logo and title. Open edition"),
		WithArg("image", "https://www.johndoe.com/images/sunflowers.jpg"),
		WithArg("recipient", "0x12ecc177508efad8"),
	).AssertSuccess(t).Print()
}
