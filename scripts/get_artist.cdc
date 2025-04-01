import "ArtDrop"

access(all)
fun main(name: String): ArtDrop.Artist? {
  return ArtDrop.getArtist(name: name)
}