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
    var avatarData: Data?
    
    var source: CNContact?
    var phoneNumber: String

    init(random:Bool=false) {
        if !random {
            firstName=""
            lastName=""
            phoneNumber=""
            return
        }
        self.firstName = "Nil"
        self.lastName = "Ng"
        self.phoneNumber="911"
    }
    
    init(firstName: String, lastName: String, phoneNumber:String) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
    }
    
    func copy() -> Friend {
        let copy = Friend(firstName: self.firstName, lastName: self.lastName, phoneNumber: self.phoneNumber)
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
            lhs.phoneNumber == rhs.phoneNumber
    }
}

extension Friend{
        
    convenience init(contact: CNContact) {
        let phoneNumberString =  contact.phoneNumbers.first?.value.stringValue ?? ""
        
        self.init(firstName: contact.givenName,
                  lastName:contact.familyName,
                  phoneNumber: phoneNumberString)
        
        self.uid = contact.identifier
        self.source = contact
        
        if let photoData = contact.imageData {
            self.avatarData = photoData
        }
    }
    
    func toCNContact() -> CNContact{
        if let storedContact = source{
            print("use source contact.")
            return storedContact
        }
        // in case when there a contact is not in native App
        let contactObj = CNMutableContact()
        contactObj.givenName = firstName
        contactObj.familyName = lastName

        let label = CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: phoneNumber))
        contactObj.phoneNumbers.append(label)
            

        return contactObj.copy() as! CNContact

    }
}



#if DEBUG
let samplePersons = [
    Friend(firstName: "Nil", lastName: "Nguyen",phoneNumber: "0902801xxx"),
    Friend(firstName: "Steve", lastName: "Jobs",phoneNumber: "09012345"),
    Friend(firstName: "Ada", lastName: "Lovelace",phoneNumber: "09023456" ),
    Friend(firstName: "Daniel", lastName: "Bourke", phoneNumber: "09812345")
]
#endif
