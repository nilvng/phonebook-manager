//
//  Person.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/24/21.
//

import Contacts
import UIKit
import CoreData

@objc(Friend)
class Friend: NSManagedObject{
    
    @NSManaged var uid : String
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var phoneNumbers: [String]
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

    
    func copy() -> Friend {
        let copy = Friend()
        copy.uid = self.uid
        copy.source = self.source
        copy.avatarData = self.avatarData
        return copy
    }

}
//
//extension Friend : Codable{
//
//    enum CodingKeys : String, CodingKey {
//        case uid
//        case firstName
//        case lastName
//        case phoneNumbers
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(firstName, forKey: .firstName)
//        try container.encode(lastName, forKey: .lastName)
//        try container.encode(uid, forKey: .uid)
//        try container.encode(phoneNumbers, forKey: .phoneNumbers)
//    }
//}

extension Friend{
        
    convenience init(contact: CNContact, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Friend", in: context)
        
        self.init(entity: entity!, insertInto: context)
        self.firstName = contact.givenName
        self.lastName = contact.familyName
        
        let numbers =  contact.phoneNumbers.compactMap { $0.value.stringValue}
        self.phoneNumbers = numbers
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
