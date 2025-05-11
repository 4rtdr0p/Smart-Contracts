import "Pistis"

// This transaction is for any user to create a new Project 
// on the proof-of-support platform 

access(all) fun main(category: String): [String] {

    return Pistis.getPoolsByCategory(category: category)
} 