import "ArtStudio"

access(all)
fun main(pieceName: String): ArtStudio.Sentiment? {
  return ArtStudio.getPieceSentiment(pieceName: pieceName)
}