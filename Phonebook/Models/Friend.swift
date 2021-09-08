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
    var phoneNumbers: [String]
    var avatarData: Data?
    
    var source: CNContact?
    var mutableCopy : CNMutableContact {
        let contactObj : CNMutableContact
        if let source = source {
            contactObj = source.mutableCopy() as! CNMutableContact
        } else{
            contactObj = CNMutableContact()
        }
        
        contactObj.givenName = firstName
        contactObj.familyName = lastName

        contactObj.phoneNumbers = phoneNumbers.map {
            return CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: $0))}
        return contactObj
    }

    init(random:Bool=false) {
        if !random {
            firstName=""
            lastName=""
            phoneNumbers=[""]
            return
        }
        self.firstName = "Nil"
        self.lastName = "Ng"
        self.phoneNumbers=["911"]
    }
    
    init(firstName: String, lastName: String, phoneNumbers:[String]) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumbers = phoneNumbers
    }
    
    func copy() -> Friend {
        var copy = Friend(firstName: self.firstName, lastName: self.lastName, phoneNumbers: self.phoneNumbers)
        copy.uid = self.uid
        copy.source = self.source
        copy.avatarData = self.avatarData
        return copy
    }
}

extension Friend : Equatable{
    static func ==(lhs: Friend, rhs: Friend) -> Bool{
        return lhs.uid == rhs.uid &&
            lhs.firstName == rhs.firstName &&
          lhs.lastName == rhs.lastName &&
            lhs.phoneNumbers == rhs.phoneNumbers
    }
}

extension Friend{
        
    convenience init(contact: CNContact) {
        let numbers =  contact.phoneNumbers.map { $0.value.stringValue }
        
        self.init(firstName: contact.givenName,
                  lastName:contact.familyName,
                  phoneNumbers: numbers)
        
        self.uid = contact.identifier
        self.source = contact
        
        if let photoData = contact.imageData {
            self.avatarData = photoData
        }
    }
    
    func toCNContact() -> CNContact {
        if let storedContact = source{
            return storedContact
        }
        // in case when there a contact is not in native App
        return mutableCopy as CNContact
    }
    
    func toMutableContact() -> CNMutableContact? {
        return mutableCopy
    }
}



#if DEBUG
let samplePersons = [
    Friend(firstName: "Nil", lastName: "Nguyen",phoneNumbers: ["0902801xxx"]),
    Friend(firstName: "Steve", lastName: "Jobs",phoneNumbers: ["09012345"]),
    Friend(firstName: "Ada", lastName: "Lovelace",phoneNumbers: ["09023456"] ),
    Friend(firstName: "Daniel", lastName: "Bourke", phoneNumbers: ["09812345"])
]
#endif
