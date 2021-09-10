//
//  PersonStore.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/24/21.
//

import UIKit
import Contacts
import CoreData

class BaseFriendStore {
    var friends = [String:Friend]()
}
protocol FriendStore : BaseFriendStore{
    @discardableResult func addFriend(_ person : Friend) -> Friend
    func deleteFriend(_ person: Friend)
    func updateFriend(_ person: Friend)
    func contains(_ person:Friend) -> Bool
    func get(key: String) -> Friend?
    func getAll() -> [String: Friend]
    func saveChanges() -> Bool
}

extension FriendStore{
    func addFriend(_ person: Friend) -> Friend{
        friends[person.uid] = person
        return person
    }
    
    func deleteFriend(_ person: Friend) {
        // remove in-memo
        friends.removeValue(forKey: person.uid)
    }
    
    func updateFriend(_ person: Friend){
        friends[person.uid] = person
    }
    func contains(_ person:Friend) -> Bool{
        return friends[person.uid] != nil
    }
    func get(key: String) -> Friend?{
        return friends[key]
    }
    func reloadData(cnContacts:[CNContact]) -> [String: Friend]{
        // override current list with cnContacts
//        for c in cnContacts{
//            friends[c.identifier] = Friend(contact: c)
//        }
        return friends
    }
    
    func getAll() -> [String: Friend]{
        return friends
    }
}

class InMemoFriendStore : BaseFriendStore, FriendStore{
    func saveChanges() -> Bool {
        fatalError()
    }

}

class PlistFriendStore: BaseFriendStore,FriendStore {
    let itemArchiveURL : URL = {
        
        let documentDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentDirectories.first!
        
        return documentDirectory.appendingPathComponent("contacts.plist")
    }()

        
    @objc func saveChanges() -> Bool {
        print("Saving items to: \(itemArchiveURL)")
        fatalError()
//
//        do{
//            let encoder = PropertyListEncoder()
//            let data = try encoder.encode(friends)
//            try data.write(to: itemArchiveURL)
//            print("Saved all items")
//            return true
//        } catch let encodingError{
//            print("Error encoding items: \(encodingError)")
//            return false
//        }
    }
    
    func loadData(){
//        do {
//            let data = try Data(contentsOf: itemArchiveURL)
//            let unarchiver = PropertyListDecoder()
//            let persons = try unarchiver.decode([String: Friend].self, from: data)
//            self.friends = persons
//
//        } catch let error {
//            print("Error reading in save file: \(error)")
//        }
}
    override init() {
        super.init()
        self.loadData()
        // auto save the list of items whenever users turn off the app
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector:#selector(saveChanges),
                                       name: UIScene.didEnterBackgroundNotification,
                                       object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIScene.didEnterBackgroundNotification, object: nil)
    }
    
}


class CoreDataFriendStore : BaseFriendStore, FriendStore {
    

    func saveChanges() -> Bool {
        fatalError()
    }
    
    
}
