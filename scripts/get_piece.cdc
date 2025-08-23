import "Mneme" 
import "MetadataViews"

access(all)
fun main(id: UInt64, artistAccount: Address): MetadataViews.Traits? {
  let piece = Mneme.getPiece(id: id, artistAddress: artistAccount)
  return piece!
} 