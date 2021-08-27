//
//  Person.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/24/21.
//

import Foundation
import Contacts
import UIKit

class Person {
    
    var uid = UUID().uuidString
    var firstName: String
    var lastName: String
    
    var storedContactValue: CNMutableContact?
    var phoneNumber: (CNLabeledValue<CNPhoneNumber>)?

    init(random:Bool) {
        if !random {
            firstName=""
            lastName=""
            return
        }
        self.firstName="Nil"
        self.lastName="Ng"
    }
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}

extension Person : Equatable{
    static func ==(lhs: Person, rhs: Person) -> Bool{
        return lhs.firstName == rhs.firstName &&
          lhs.lastName == rhs.lastName &&
            lhs.phoneNumber == rhs.phoneNumber
    }
}

extension Person{
        
    convenience init(contact: CNContact) {
        self.init(firstName: contact.givenName, lastName:contact.familyName)
        self.uid = contact.identifier
        if let number = contact.phoneNumbers.first{
            self.phoneNumber = number
        }
        self.storedContactValue = contact.mutableCopy() as? CNMutableContact
    }
    
    func toCNContact() -> CNContact{
        if let storedContact = storedContactValue{
            print("stored contact:", storedContact)
            return storedContact.copy() as! CNContact
        }
        // in case when there a contact is not in native App
        let contactObj = CNMutableContact()
        contactObj.givenName = firstName
        contactObj.familyName = lastName

        if let phoneNumber = phoneNumber{
            contactObj.phoneNumbers.append(phoneNumber)
        }

        return contactObj.copy() as! CNContact

    }
}

#if DEBUG
let samplePersons = [
    Person(firstName: "Nil", lastName: "Nguyen"),
    Person(firstName: "Steve", lastName: "Jobs"),
    Person(firstName: "Ada", lastName: "Lovelace"),
    Person(firstName: "Daniel", lastName: "Bourke")
]
#endif
