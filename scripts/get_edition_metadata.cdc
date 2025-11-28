import "Mneme"

access(all)
fun main(artistAddress: Address, editionId: UInt64): &Mneme.Edition? {
  return Mneme.getEditionMetadata(artistAddress: artistAddress, editionId: editionId)
}