import "ArtStudio"

access(all)
fun main(name: String): ArtStudio.Artist? {
  return ArtStudio.getArtist(name: name)
}