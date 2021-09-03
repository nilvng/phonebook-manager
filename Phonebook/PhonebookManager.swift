//
//  PhonebookManager.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/27/21.
//

import Foundation
import Contacts

protocol PhonebookDelegate {
    func contactListRefreshed(contacts: [String: Friend])
    func newContactAdded(contact: Friend)
    func contactDeleted(row: Int)
}
class PhonebookManager {
    var store: FriendStore = InMemoFriendStore.shared
    let contactsUtils: ContactsUtils = ContactsUtils.shared
    
    var delegate: PhonebookDelegate?
    
    static let shared = PhonebookManager()
    private init(){
        NotificationCenter.default.addObserver(self, selector: #selector(nativeContactsDidChange), name: NSNotification.Name.CNContactStoreDidChange, object: nil)
    }
    func fetchData(_ complilationHandler: @escaping (Result<String,Error>) -> () ){
        var contacts : [String: Friend] = [:]
        // TODO: when contacts list is occupied
        // 0. pull data from local database
        // 1. upload current list to Contacts.app
        // 1a. record is new
        // 1b. record existed
        
        // Fetch data from native Contacts app
        let granted = self.contactsUtils.accessGranted()
        if granted {
            DispatchQueue.global(qos: .utility).async {
                // pull data
                let cnContacts = self.contactsUtils.getAllContacts()
                // merge data
                contacts = self.store.reloadData(cnContacts: cnContacts)
                // inform table view
                self.delegate?.contactListRefreshed(contacts: contacts)
                complilationHandler(.success("Sync data is completed"))
                }
        } else{
            complilationHandler(.failure(FetchError.unauthorized))
        }
    }
    @objc func nativeContactsDidChange(noti: NSNotification){
        print("native changed.")
        DispatchQueue.global(qos: .utility).async {
            // pull data
            let cnContacts = self.contactsUtils.getAllContacts()
            // case 1: native contact deleted O(n^2)
            if cnContacts.count < self.store.friends.count{
                for current in self.store.friends.values{
                    if !cnContacts.contains(where: {$0.identifier == current.uid}){
                        self.store.deleteFriend(current)
                        }
                    }
            }
            // case 2: native contact added or updated O(n)
            for cnContact in cnContacts{
                self.store.friends[cnContact.identifier] = Friend(contact: cnContact)
            }
            self.delegate?.contactListRefreshed(contacts: self.store.friends)

        }
    }
    func addContact(_ contact: Friend){
        store.addFriend(contact)
    }
    func deleteContact(_ contact: Friend, at: Int? = nil){
        store.deleteFriend(contact)
    }
    func updateContact(_ contact: Friend){
        print("manager update contact...")
        store.updateFriend(contact)
        DispatchQueue.global(qos: .utility).async {
            if let mutableContact = contact.toMutableContact(){
                do {
                    try self.contactsUtils.updateContact(mutableContact)
                } catch (let err){
                    print("cannot update contact to native database: \(err)")
                }
            }
        }
    }
    
    func getContactList()->[String: Friend]{
        return store.friends
    }
    func getContact(key: String) -> Friend? {
        return store.get(key: key)
    }
}

enum FetchError: Error {
    case unauthorized
    case failed
}
