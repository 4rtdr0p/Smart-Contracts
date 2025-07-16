import "Mneme"
import "MetadataViews"

access(all)
fun main(id: UInt64): MetadataViews.Traits? {
  return Mneme.getArtist(id: id)
}