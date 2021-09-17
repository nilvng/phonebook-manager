//
//  Person.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/24/21.
//

import Contacts
import UIKit
import CoreData

class Friend{
    
    var uid : String
    var firstName: String
    var lastName: String
    var phoneNumbers: [String]
    var avatarData: Data?

    var source: CNContact? {
        didSet{
            if let photoData = source?.imageData {
                self.avatarData = photoData
            }
        }
    }

    init() {
        uid = UUID().uuidString
        firstName = ""
        lastName = ""
        phoneNumbers = [""]
    }

    func copy() -> Friend {
        let copy = Friend()
        copy.uid = self.uid
        copy.firstName = self.firstName
        copy.lastName = self.lastName
        copy.phoneNumbers = self.phoneNumbers
        copy.source = self.source
        copy.avatarData = self.avatarData
        return copy
    }
    
    func getPhoneNumber(index: Int) -> String{
        guard index > -1 else {
            print("Warning: access phone number out of range.")
            return ""
        }
        guard  phoneNumbers.count > index else {
            return ""
        }
        return phoneNumbers[index]
    }
    
    func setPhoneNumber(_ value :String ,at index: Int) {
        if phoneNumbers.count <= index {
            phoneNumbers.append(value)
        } else {
            phoneNumbers[index] = value
        }
    }
}

extension Friend{
        
    convenience init(contact: CNContact) {
        
        self.init()
        self.firstName = contact.givenName
        self.lastName = contact.familyName
        self.uid = contact.identifier
        self.source = contact
        self.avatarData     = contact.imageData
        let numbers =  contact.phoneNumbers.compactMap { $0.value.stringValue}
        self.phoneNumbers = numbers
            }
    
    func toCNContact() -> CNContact {
        if let storedContact = source{
            return storedContact
        }
        // in case when there a contact is not in native App
        return toMutableContact() as CNContact
    }
    
    func toMutableContact() -> CNMutableContact {
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
}

extension Friend : Equatable {
    static func == (lhs: Friend, rhs: Friend) -> Bool {
        return lhs.uid == rhs.uid &&
            lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName &&
            lhs.phoneNumbers == rhs.phoneNumbers
    }
}

extension Friend : CustomStringConvertible {
    var description: String{
        "id: \(uid); name: \(firstName) \(lastName); \(phoneNumbers)"
    }
}
