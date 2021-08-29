//
//  Person.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/24/21.
//

import Foundation
import Contacts
import UIKit

class Friend {
    
    var uid = UUID().uuidString
    var firstName: String
    var lastName: String
    var avatarKey: String?
    
    var source: CNContact?
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

extension Friend : Equatable{
    static func ==(lhs: Friend, rhs: Friend) -> Bool{
        return lhs.firstName == rhs.firstName &&
          lhs.lastName == rhs.lastName &&
            lhs.phoneNumber == rhs.phoneNumber
    }
}

extension Friend{
        
    convenience init(contact: CNContact) {
        self.init(firstName: contact.givenName, lastName:contact.familyName)
        self.uid = contact.identifier
        if let number = contact.phoneNumbers.first{
            self.phoneNumber = number
        }
        self.source = contact
    }
    
    func toCNContact() -> CNContact{
        if let storedContact = source{
            print("stored contact:", storedContact)
            return storedContact
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
    Friend(firstName: "Nil", lastName: "Nguyen"),
    Friend(firstName: "Steve", lastName: "Jobs"),
    Friend(firstName: "Ada", lastName: "Lovelace"),
    Friend(firstName: "Daniel", lastName: "Bourke")
]
#endif
