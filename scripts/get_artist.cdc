import "Mneme"
import "MetadataViews"

access(all)
fun main(address: Address): MetadataViews.Traits? {
  return Mneme.getArtist(address: address)
}