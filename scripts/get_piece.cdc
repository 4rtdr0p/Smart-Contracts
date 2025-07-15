import "Mneme" 
import "MetadataViews"

access(all)
fun main(id: UInt64, artistName: String): MetadataViews.Traits? {
  let piece = Mneme.getPiece(id: id, artistName: artistName)
  return piece!
}