import "Mneme" 

access(all)
fun main(pieceName: String): Mneme.Piece? {
  let piece = Mneme.getPiece(pieceName)
  return piece
}