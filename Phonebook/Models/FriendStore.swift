//
//  PersonStore.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/24/21.
//

import UIKit
import Contacts
import CoreData

protocol FriendStore {
    func addFriend(_ person : Friend)
    func deleteFriend(id : String)
    func updateFriend(_ person: Friend)
    func getAll() -> [Friend]
    func saveChanges(completion: @escaping (Bool) ->Void)
    func getFriend(id: String) -> Friend?
    func contains(id: String) -> Bool
}
//
//class CoreDataFriendStoreAdapter: FriendStore {
//
//
//    private var adaptee : CoreDataFriendStore
//    init(adaptee : CoreDataFriendStore) {
//        self.adaptee = adaptee
//    }
//    func gets(id: String) -> Friend? {
//        let cdFriend = adaptee.gets(id: id)
//        if let cdfriend = cdFriend {
//            return toFriend(cdfriend)
//        }
//        return nil
//    }
//
//    func contains(id: String) -> Bool {
//        return gets(id: id) != nil
//    }
//
//    func addFriend(_ person: Friend) {
//        toFriendCoreData(person){ coreDataCopy in
//            self.adaptee.addFriend(coreDataCopy)
//        }
//    }
//
//    func deleteFriend(_ person: Friend) {
//        toFriendCoreData(person){ coreDataCopy in
//            self.adaptee.deleteFriend(coreDataCopy)
//        }
//    }
//
//    func updateFriend(_ person: Friend) {
//        toFriendCoreData(person){ coreDataCopy in
//            self.adaptee.updateFriend(coreDataCopy)
//        }
//    }
//
//    func getAll() -> [Friend] {
//        let cdList = adaptee.getAll()
//        return toFriendList(cdList)
//    }
//
//    func saveChanges(completion: @escaping (Bool) -> Void) {
//        adaptee.saveChanges(completion: completion)
//    }
//}


class PlistFriendStoreAdapter : FriendStore{

    private var adaptee : PlistFriendStore
    init(adaptee : PlistFriendStore) {
        self.adaptee = adaptee
    }
    func addFriend(_ person: Friend){
        let plistCopy = convertToPlistFriend(person)
        adaptee.addFriend(plistCopy)
    }
    
    func deleteFriend(id : String) {
        adaptee.deleteFriend(uid: id)
    }
    
    func updateFriend(_ person: Friend) {
        let plistCopy = convertToPlistFriend(person)
        adaptee.updateFriend(plistCopy)
    }
    
    func getAll() -> [Friend] {
        let plistFriends = adaptee.getAll()
        return convertToFriendList(plistFriends)
    }
    
    func saveChanges(completion: @escaping (Bool) -> Void) {
        adaptee.saveChanges(completion: completion)
    }
    func getFriend(id: String) -> Friend? {
        let cdFriend = adaptee.gets(id: id)
        if cdFriend == nil {
            return nil
        }
        return convertToFriend(cdFriend!)
    }
    
    func contains(id: String) -> Bool{
        return getFriend(id: id) != nil
    }

    
    func convertToFriendList(_ plistFriends: [FriendPlist]) -> [Friend] {
        let friendList : [Friend] = plistFriends.compactMap {f in
            var friend = Friend()
            friend.firstName = f.firstName
            friend.lastName = f.lastName
            friend.phoneNumbers = f.phoneNumbers
            friend.uid = f.uid
            return friend
        }
        return friendList
    }
    
    func convertToFriend(_ f : FriendPlist) -> Friend {
            var friend = Friend()
            friend.firstName = f.firstName
            friend.lastName = f.lastName
            friend.phoneNumbers = f.phoneNumbers
            friend.uid = f.uid
            return friend
        }
    
    func convertToPlistFriend(_ f : Friend) -> FriendPlist {
        let friend = FriendPlist(uid: f.uid,
                                 firstName: f.firstName,
                                 lastName: f.lastName,
                                 phoneNumbers: f.phoneNumbers)
            return friend
        }


}
