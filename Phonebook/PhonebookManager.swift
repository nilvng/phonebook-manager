//
//  PhonebookManager.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/27/21.
//

import Foundation
import Contacts
import ContactsUI
import CoreData

protocol PhonebookManagerDelegate {
    func contactListRefreshed(contacts: [String: Friend])
    func newContactAdded(contact: Friend)
    func contactDeleted(row: Int)
    func contactUpdated(_ contact: Friend)
}
class PhonebookManager {
    var friendStore: FriendStore! {
        didSet{
            self.friends = self.listToDict(listFriend: self.friendStore.getAll())
        }
    }
    private let nativeStore = CNContactStore()
    
    private var friends : [String: Friend] = [:]
    
    private var isAuthorized = {
        CNContactStore.authorizationStatus(for: .contacts) == .authorized
    }()

    let friendsQueue = DispatchQueue(
        label: "zalo.phonebook.friendList",
        qos: .utility,
        autoreleaseFrequency: .workItem,
        target: nil)
    
    var delegate: PhonebookManagerDelegate?

    static let shared = PhonebookManager()
    private init(){}
    
    
    func fetchData(forceReload :Bool = false,_ complilationHandler: @escaping (Result<String,Error>) -> () ){
        var dataDidChange = false

        print("Fetching data..")
        // TODO: when contacts list is occupied
        // 0. pull data from local database
        // 1. upload current list to Contacts.app
        // 1a. record is new
        // 1b. record existed

        // Fetch data from native Contacts app
        guard isAuthorized else {
            complilationHandler(.failure(FetchError.unauthorized))
            return
        }
        

        self.friendsQueue.async {
            let cnContacts = self.getAllContactsFromNative()
            // case 1: native contact added or updated O(n)
            for cnContact in cnContacts{
                let nativeFriend = Friend(contact: cnContact)
                if let localCopy = self.friends[cnContact.identifier] {
                    /// assign native source
                    localCopy.source = cnContact
                    // notice changes from native
                    if nativeFriend != localCopy {
                        /// Edited contact if we have a record with this id but the record's content is not the same
                        dataDidChange = true
                        self.updateFriend(nativeFriend)
                        self.friendStore.updateFriend(nativeFriend)
                        print("updated contact:\(nativeFriend)")
                   }
                }else {
                    /// New contact if we didn't have record that has this contact id
                    dataDidChange = true
                    self.addFriend(nativeFriend)
                    self.friendStore.addFriend(nativeFriend)
                    print("new contact:\(nativeFriend)")
                }
            }
            // case 2: native contact deleted O(n^2)
            if cnContacts.count < self.friends.count{
                for localCopy in self.friends.values{ // reader
                    if !cnContacts.contains(where: {$0.identifier == localCopy.uid}){
                        /// Deleted contact
                        dataDidChange = true
                        self.deleteFriend(localCopy)
                        self.friendStore.deleteFriend(localCopy)
                        print("deleted contact:\(localCopy)")
                        }
                    }
            }

            if forceReload || dataDidChange {
                print("Data did change.")
                self.friendStore.saveChanges(){ res in
                    print("Done persist data: \(res)")
                }// hanging: may not able to persist
                self.delegate?.contactListRefreshed(contacts: self.friends)
            }
        }
            
    }

    func resolveConflicts(){
        /* Assume that our contact list is the most up-to-date
            Push our list to native database */
        for friend in self.friends.values {
            self.saveContact(friend) { res in
                if !res {
                    // cannot save this contact -> attempt to update it
                    self.updateContact(friend){ res in
                        print("Resolve conflict of friend \(friend.uid): Update")
                    }
                }else {
                    print("Resolve conflict of friend \(friend.uid): Add")
                }
            }
        }
        // fetchData()
    }
    
    func add(_ contact: Friend ){
        self.friendsQueue.async {
            // save copy in memo
            self.addFriend(contact)
            // save copy in database
            self.friendStore.addFriend(contact)
            // qualified to delegate now...
            self.delegate?.newContactAdded(contact: contact)
            
            // save copy in database
            self.saveContact(contact){ success in
                if success {
                    // TODO: update uid to match native contact identifier
                    print("Successfully Add contact to native.")
                }
            }
        }
    }
    func delete(_ contact: Friend, at row: Int){
        self.friendsQueue.async {
            // delete copy in memory
            self.deleteFriend(contact)
            // delete copy in database
            self.friendStore.deleteFriend(contact)
            // qualified to delegate now...
            self.delegate?.contactDeleted(row: row)
            
            // delete copy in native database
            self.removeContact(contact){ success in
                if success {
                    print("Successfully Delete from native.")
                }
            }
        }
    }
    func update(_ contact: Friend){
        self.friendsQueue.async {
            // update copy in memory
            self.updateFriend(contact)
            // update copy in database
            self.friendStore.updateFriend(contact)
            // qualified to delegate now...
            self.delegate?.contactUpdated(contact)
            
            // update copy in native database
            self.updateContact(contact){ success in
                if success {
                    print("Successfully Update contact to native.")
                }
            }
        }
    }
    
    func getContactList()->[String: Friend]{
        let immutableList = self.friends // Copying this variable into a new variable for immutability
        return immutableList
    }
    
    func getContact(key: String) -> Friend? {
        return self.friends[key]
    }
    
    func listToDict(listFriend: [Friend]) -> [String:Friend]{
        var dict : [String: Friend] = [:]
        for i in listFriend{
            dict[i.uid] = i
        }
        return dict
    }

}

// MARK: - In-memo Store
extension PhonebookManager {

    func addFriend(_ person: Friend){
        friends[person.uid] = person
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
    func getAll() -> [String: Friend]{
        return friends
    }
}

// MARK: - methods for CnContactStore

extension PhonebookManager {

    private func getAllContactsFromNative()-> [CNContact]{
        // fetching all contacts from the Contacts.app
        var results: [CNContact] = []
        var keysToFetch : [CNKeyDescriptor] = [CNContactIdentifierKey,CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey, CNContactImageDataKey] as [CNKeyDescriptor]
        keysToFetch += [CNContactViewController.descriptorForRequiredKeys()]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        do {
            try self.nativeStore.enumerateContacts(with: fetchRequest, usingBlock: {(contact, stopPointer) in
                results.append(contact)
            })
        } catch let err {
            print("Failed to fetch contacts: ",err)
        }
        return results
    }
    
    private func saveContact(_ contact: Friend, completition: @escaping (Bool) -> Void) {
        guard isAuthorized else {
            completition(false)
            return
        }
        do{
            let request = CNSaveRequest()
            request.add(contact.toMutableContact(), toContainerWithIdentifier: nil)
            try self.nativeStore.execute(request)
            completition(true)
        }catch let err{
            print("Failed to save contact in Contacts native app: ",err)
            completition(false)
        }
    }
    
    private func removeContact(_ contact: Friend, completition: @escaping (Bool) -> Void) {
        guard isAuthorized else {
            completition(false)
            return
        }
        let mutableContact = contact.toMutableContact()
            do{
                let request = CNSaveRequest()
                request.delete(mutableContact)
                try self.nativeStore.execute(request)
                completition(true)
            }catch let err{
                print("Failed to delete contact in Contacts native app: ",err)
                completition(false)
            }
    }
    
    private func updateContact(_ contact: Friend, completition: @escaping (Bool) -> Void) {
        guard isAuthorized else {
            completition(false)
            return
        }
        do{
            let request = CNSaveRequest()
            request.update(contact.toMutableContact())
            try self.nativeStore.execute(request)
            completition(true)
        }catch let err{
            print("Failed to update contact in Contacts native app: ",err)
            completition(false)
        }
    }
}

enum FetchError: Error {
    case unauthorized
    case failed
}


