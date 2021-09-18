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
    private var notiToken: NSObjectProtocol?

    static let shared = PhonebookManager()
    private init(){
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .CNContactStoreDidChange, object: nil)
    }
    
    deinit {
//        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func refreshData() {
        fetchData { res in
            print(res)
        }
    }
    
    func fetchData(forceReload :Bool = false,_ complilationHandler: @escaping (Result<String,Error>) -> () ){
        var dataDidChange = false

        print("Fetching data..")
        // TODO: when contacts list is occupied
        // 0. pull data from local database
        // 1. upload current list to Contacts.app
        // 1a. record is new
        // 1b. record existed

        guard isAuthorized else {
            complilationHandler(.failure(FetchError.unauthorized))
            return
        }
        
        // Sync native data into the app
        self.friendsQueue.async {
            // Fetch data from native Contacts app
            let cnContacts = self.getAllContactsFromNative()
            // case 1: contact added or updated O(n)
            for cnContact in cnContacts{
                
                let nativeFriend = Friend(contact: cnContact)
                /// assign native source
                self.friends[cnContact.identifier]?.source = cnContact

                if let localCopy = self.friends[cnContact.identifier] {
                    if localCopy != cnContact {
                        /// Edited contact if we have a record with this id but the record's content is not the same
                        dataDidChange = true
                        print("updated contact:\(nativeFriend)")
                        print("previous: \(localCopy)")
                        self.updateFriend(nativeFriend)
                        self.friendStore.updateFriend(nativeFriend)

                   }
                }else {
                    /// It is new contact if we didn't have record that has this contact id
                    dataDidChange = true
                    self.addFriend(nativeFriend)
                    self.friendStore.addFriend(nativeFriend)
                    print("new contact:\(nativeFriend)")
                }
            }
            // case 2: contact deleted O(n^2)
            if cnContacts.count < self.friends.count{
                for localCopy in self.friends.values{ // reader
                    if !cnContacts.contains(where: {$0.identifier == localCopy.uid}){
                        /// Deleted contact
                        dataDidChange = true
                        self.deleteFriend(localCopy)
                        self.friendStore.deleteFriend(id: localCopy.uid)
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
            self.saveContactToNative(friend) { res in
                if !res {
                    // cannot save this contact -> attempt to update it
                    self.updateNativeContact(friend){ res in
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
            self.saveContactToNative(contact){ success in
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
            self.friendStore.deleteFriend(id: contact.uid)
            // qualified to delegate now...
            self.delegate?.contactDeleted(row: row)
            
            // delete copy in native database
            self.removeNativeContact(contact){ success in
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
            self.updateNativeContact(contact){ success in
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
        self.friendsQueue.sync {
        return self.friends[key]
        }
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

    private func addFriend(_ person: Friend){
        friends[person.uid] = person
    }
    
    private func deleteFriend(_ person: Friend) {
        // remove in-memo
        friends.removeValue(forKey: person.uid)
    }
    
    private func updateFriend(_ person: Friend){
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
    
    private func saveContactToNative(_ contact: Friend, completition: @escaping (Bool) -> Void) {
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
    
    private func removeNativeContact(_ contact: Friend, completition: @escaping (Bool) -> Void) {
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
    
    private func updateNativeContact(_ contact: Friend, completition: @escaping (Bool) -> Void) {
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


