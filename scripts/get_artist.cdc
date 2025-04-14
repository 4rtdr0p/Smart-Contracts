import "Mneme"

access(all)
fun main(name: String): Mneme.Artist? {
  return Mneme.getArtist(name: name)
}