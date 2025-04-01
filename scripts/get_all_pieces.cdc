import "ArtDrop"

access(all)
fun main(): &{String: ArtDrop.Piece} {
  return ArtDrop.getAllPieces()
}