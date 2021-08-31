//
//  PersonStore.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/24/21.
//

import UIKit
import Contacts
class BaseFriendStore {
    var friends = [String:Friend]()
    var contactsUtils = ContactsUtils.shared
}
protocol FriendStore : BaseFriendStore{
    func fetchAllContacts(compilationClosure: @escaping (_  contactsFetched: Bool)->())
    @discardableResult func addFriend(_ person : Friend) -> Friend
    func deleteFriend(_ person: Friend)
    func contains(_ person:Friend) -> Bool
    func get(key: String) -> Friend?
}

extension FriendStore{
    func addFriend(_ person: Friend) -> Friend{
        friends[person.uid] = person
        return person
    }
    
    func deleteFriend(_ person: Friend) {
        // remove in-memo
        friends.removeValue(forKey: person.uid)
        // remove in Contacts.app
        DispatchQueue.global(qos: .utility).async {
            do{
                try self.contactsUtils.removeContact(person.source?.mutableCopy() as! CNMutableContact)
            }catch let err{
                print("Failed to delete contact in Contacts native app: ",err)
            }
        }
    }
    func contains(_ person:Friend) -> Bool{
        return friends[person.uid] != nil
    }
    func get(key: String) -> Friend?{
        return friends[key]
    }
    func fetchAllContacts(compilationClosure: @escaping (_ contactsFetched: Bool)->()){
        let granted = self.contactsUtils.accessGranted()
        if granted {
            DispatchQueue.global(qos: .utility).async {
                let contacts = self.contactsUtils.getAllContacts()
                    self.reloadData(cnContacts: contacts)
                }
            }
        compilationClosure(granted)
        }
    func reloadData(cnContacts:[CNContact]) -> [String: Friend]{
        // override current list with cnContacts
        for c in cnContacts{
            friends[c.identifier] = Friend(contact: c)
        }
        return friends
    }
}

class InMemoFriendStore : BaseFriendStore, FriendStore{
    static let shared = InMemoFriendStore()
    private override init() {
        super.init()
        for contact in samplePersons{
            friends[contact.uid] = contact
        }
    }
}

class PlistFriendStore: BaseFriendStore,FriendStore {
    let itemArchiveURL : URL = {
        
        let documentDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentDirectories.first!
        
        return documentDirectory.appendingPathComponent("contacts.plist")
    }()

        
    @objc func saveChanges() -> Bool {
//        print("Saving items to: \(itemArchiveURL)")
//
//        do{
//            let encoder = PropertyListEncoder()
//            let data = try encoder.encode(persons)
//            try data.write(to: itemArchiveURL)
//            print("Saved all items")
//            return true
//        } catch let encodingError{
//            print("Error encoding items: \(encodingError)")
//            return false
//        }
        return false
    }
    
    func loadData(){
//        do {
//            let data = try Data(contentsOf: itemArchiveURL)
//            let unarchiver = PropertyListDecoder()
//            let persons = try unarchiver.decode([Person].self, from: data)
//            self.persons = persons
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
    
}
