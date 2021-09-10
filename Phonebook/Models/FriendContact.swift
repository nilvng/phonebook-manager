//
//  FriendContact.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/9/21.
//

import CoreData
import Contacts
import UIKit

@objc(Friend)
class FriendContact : NSManagedObject {
    
    var uid = UUID().uuidString
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var phoneNumbers: [String]
    @NSManaged var avatarData: Data?
}
