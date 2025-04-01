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

	color.Blue("ArtDrop Contract testing")

	color.Green("Admin creates an Artist struct")

	// Create a new Artist struct
	o.Tx("admin/create_artist",
		WithSigner("account"),
		WithArg("name", "Beeple"),
		WithArg("biography", "Born on Earth"),
		WithArg("nationality", "human"),
		WithArg("preferredMedium", "digital"),
		WithArg("socials", `{"Twitter": "www.x.com/beeple"}`),
		WithArg("representation", ""),
		WithArg("accountAddress", "bob"),
	)
	o.Script("get_all_artists")
	// Create a new Piece blueprint
	/* 	color.Green("Admin creates an Artist struct")
	   	o.Tx("create_piece_blueprint",
	   		WithSigner("account"),
	   		WithArg("name", "Bull Run"),
	   		WithArg("artistName", "Beeple"),
	   		WithArg("description", "Beeple's artwork was featured on Louis Vuitton’s Women's Spring 2019 ready to wear collection as well as window displays at their flagship stores all over the world. They also worked together to build a bespoke custom handbag featuring bendable LED screens that featured his videos."),
	   		WithArg("artistAccount", "bob"),
	   		WithArg("creationDate", "Spring 2019"),
	   		WithArg("creationLocation", "Charleston, SC, USA"),
	   		WithArg("artType", "Digital"),
	   		WithArg("medium", "Photoshop"),
	   		WithArg("subjectMatter", "Bitcoin"),
	   		WithArg("provenanceNotes", ""),
	   		WithArg("collection", "Everydays, the 2020 Collection!"),
	   		WithArg("acquisitionDetails", "N/A"),
	   	)
	   	o.Script("get_all_pieces") */
}
