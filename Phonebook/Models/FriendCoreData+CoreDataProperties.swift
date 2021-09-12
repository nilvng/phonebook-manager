//
//  FriendCoreData+CoreDataProperties.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/11/21.
//
//

import Foundation
import CoreData


extension FriendCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FriendCoreData> {
        return NSFetchRequest<FriendCoreData>(entityName: "FriendCoreData")
    }

    @NSManaged public var uid: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var phoneNumbers: [String]?

}

extension FriendCoreData : Identifiable {

}
