import "Mneme" 

access(all)
fun main(pieceName: String): Mneme.Sentiment? {
  return Mneme.getPieceSentiment(pieceName: pieceName)
}