//
//  PersonStore.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/24/21.
//

import Foundation

protocol ContactStore {
    func fetch()
    func upload()
}

class PersonStore {
    var persons = [Person]()
    
    init() {
        for _ in 0..<5{
            addPerson()
        }
    }
    @discardableResult func addPerson()->Person{
        let p = Person(random: true)
        persons.append(p)
        return p
    }

}
