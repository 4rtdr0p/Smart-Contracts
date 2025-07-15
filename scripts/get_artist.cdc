import "Mneme"
import "MetadataViews"

access(all)
fun main(name: String): MetadataViews.Traits? {
  return Mneme.getArtist(name: name)
}