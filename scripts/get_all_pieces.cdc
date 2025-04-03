import "ArtStudio"

access(all)
fun main(): &{String: ArtStudio.Piece} {
  return ArtStudio.getAllPieces()
}