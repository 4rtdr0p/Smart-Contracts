import "Mneme" 

access(all)
fun main(pieceName: String): Mneme.Sentiment? {
  let piece = Mneme.getPiece(pieceName)
  return piece.sentimentTrack
}