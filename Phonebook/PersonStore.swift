//
//  PersonStore.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/24/21.
//

import Foundation

class BasePersonStore {
    var persons = [Person]()
}
protocol PersonStore : BasePersonStore{
    func addPerson(_ person : Person)
    func updatePerson(_ person: Person)
    func deletePerson(at index: Int)
}

class InMemoPersonStore : BasePersonStore, PersonStore{
    
    func addPerson(_ person: Person) {
        persons.append(person)
    }
    
    func updatePerson(_ person: Person) {
        
    }
    
    func deletePerson(at index: Int) {
        persons.remove(at: index)
    }
        
    override init() {
        super.init()
        self.persons=samplePersons
    }
    
    func persistData(){
        
    }
    
    @discardableResult func addPerson()->Person{
        let p = Person(random: true)
        persons.append(p)
        return p
    }

}
