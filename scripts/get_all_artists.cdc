import "ArtDrop"

access(all)
fun main(): {String: ArtDrop.Artist} {
  return ArtDrop.getArtists()
}