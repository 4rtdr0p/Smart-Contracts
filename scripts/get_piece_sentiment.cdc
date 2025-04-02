import "ArtDrop"

access(all)
fun main(pieceName: String): ArtDrop.Sentiment? {
  return ArtDrop.getPieceSentiment(pieceName: pieceName)
}