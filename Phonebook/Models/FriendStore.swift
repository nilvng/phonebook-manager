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
    func deleteFriend(_ person: Friend)
    func updateFriend(_ person: Friend)
    func getAll() -> [Friend]
    func saveChanges(completion: @escaping (Bool) ->Void)
}

class CoreDataFriendStoreAdapter: FriendStore {
    
    private var adaptee : CoreDataFriendStore
    init(adaptee : CoreDataFriendStore) {
        self.adaptee = adaptee
    }
    
    func toFriendCoreData(_ person: Friend) -> FriendCoreData{
        let context =  adaptee.getContext()
        var friend : FriendCoreData!
        context.performAndWait {
        friend = FriendCoreData(context: context)
        friend.firstName = person.firstName
        friend.lastName = person.lastName
        friend.phoneNumbers = person.phoneNumbers
        friend.uid = person.uid
        }
        return friend
    }
    
    func toFriend(_ person: FriendCoreData) -> Friend {
        let friend = Friend()
        friend.uid = person.uid!
        friend.firstName = person.firstName!
        friend.lastName = person.lastName!
        friend.phoneNumbers = person.phoneNumbers!
        return friend
    }
    
    func toFriendList(_ friends: [FriendCoreData]) -> [Friend]{
        return friends.compactMap {f in
            let friend = toFriend(f)
            return friend
        }
    }
    
    func addFriend(_ person: Friend) {
        let coreDataCopy = toFriendCoreData(person)
        adaptee.addFriend(coreDataCopy)
    }
    
    func deleteFriend(_ person: Friend) {
        let coreDataCopy = toFriendCoreData(person)
        adaptee.deleteFriend(coreDataCopy)
    }
    
    func updateFriend(_ person: Friend) {
        let coreDataCopy = toFriendCoreData(person)
        adaptee.updateFriend(coreDataCopy)
    }
    
    func getAll() -> [Friend] {
        let cdList = adaptee.getAll()
        return toFriendList(cdList)
    }
    
    func saveChanges(completion: @escaping (Bool) -> Void) {
        adaptee.saveChanges(completion: completion)
    }
}


class PlistFriendStoreAdapter : FriendStore{
    private var adaptee : PlistFriendStore
    init(adaptee : PlistFriendStore) {
        self.adaptee = adaptee
    }
    func addFriend(_ person: Friend){
        let plistCopy = convertToPlistFriend(person)
        adaptee.addFriend(plistCopy)
    }
    
    func deleteFriend(_ person: Friend) {
        adaptee.deleteFriend(uid: person.uid)
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
    
    
    func convertToFriendList(_ plistFriends: [FriendPlist]) -> [Friend] {
        let friendList : [Friend] = plistFriends.compactMap {f in
            let friend = Friend()
            friend.firstName = f.firstName
            friend.lastName = f.lastName
            friend.phoneNumbers = f.phoneNumbers
            friend.uid = f.uid
            return friend
        }
        return friendList
    }
    
    func convertToFriend(_ f : FriendPlist) -> Friend {
            let friend = Friend()
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
