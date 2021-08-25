//
//  Person.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/24/21.
//

import Foundation
import Contacts

struct Person {
    
    var firstName: String
    var lastName: String
    
    var storedContactValue: CNContact?
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

extension Person{
    
    var contactValue: CNContact{
        
        let contactObj = CNMutableContact()
        contactObj.givenName = firstName
        contactObj.familyName = lastName
        
        if let phoneNumber = phoneNumber{
            contactObj.phoneNumbers.append(phoneNumber)
        }
        
        return contactObj.copy() as! CNContact
    }
    
    init(contact: CNContact) {
        
        self.init(firstName: contact.givenName, lastName:contact.familyName)
        
        if let number = contact.phoneNumbers.first{
            self.phoneNumber = number
        }
    }
}
