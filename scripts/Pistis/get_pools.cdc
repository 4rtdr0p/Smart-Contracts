import "Pistis"

// This transaction is for any user to create a new Project 
// on the proof-of-support platform 

access(all) fun main(): {String: Pistis.PoolStruct} {

    return Pistis.getPools()
}