//
//  FriendCoreData.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/10/21.
//

import CoreData
import Foundation
@objc(Friend)
class FriendCoreData: NSManagedObject{
    @NSManaged var uid : String
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var phoneNumbers: [String]
}

