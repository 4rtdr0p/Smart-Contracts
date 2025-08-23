import "Mneme" 

access(all)
fun main(id: UInt64): Address? {
  return Mneme.getPrintOwner(id: id)
}