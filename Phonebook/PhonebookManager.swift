//
//  PhonebookManager.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/27/21.
//

import Foundation
import Contacts
import ContactsUI


protocol PhonebookManagerDelegate {
    func contactListRefreshed(contacts: [String: Friend])
    func newContactAdded(contact: Friend)
    func contactDeleted(row: Int)
    func contactUpdated(_ contact: Friend)
}
class PhonebookManager {
    private var friendStore: FriendStore = PlistFriendStore()
    private let nativeStore = CNContactStore()
    
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
    
    func fetchData(_ complilationHandler: @escaping (Result<String,Error>) -> () ){
        print("Fetching data..")
        var contacts : [String: Friend] = [:]
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
            // pull data
            let cnContacts = self.getAllContactsFromNative()
            // merge data
            contacts = self.friendStore.reloadData(cnContacts: cnContacts) // writer
            // inform table view
            self.delegate?.contactListRefreshed(contacts: contacts)
            complilationHandler(.success("Sync data is completed"))
            }
    }
    func refreshData(){
        var dataDidChange = false
        print("Refreshing data...")
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            return
        }
        self.friendsQueue.async {
            // pull data
            let cnContacts = self.getAllContactsFromNative()
            // case 1: native contact deleted O(n^2)
            if cnContacts.count < self.friendStore.friends.count{
                for current in self.friendStore.friends.values{ // reader
                    if !cnContacts.contains(where: {$0.identifier == current.uid}){
                        dataDidChange = true
                        self.friendStore.deleteFriend(current)
                        }
                    }
            }
            // case 2: native contact added or updated O(n)
            for cnContact in cnContacts{
                let nativeFriend = Friend(contact: cnContact)
                if let localCopy = self.friendStore.friends[nativeFriend.uid], localCopy != nativeFriend {
                    dataDidChange = true
                self.friendStore.friends[cnContact.identifier] = Friend(contact: cnContact)
                }
            }
            
            if dataDidChange {
                print("Data did change.")
                self.delegate?.contactListRefreshed(contacts: self.friendStore.friends)
            }
        }
    }
    func add(_ contact: Friend ){
        self.friendsQueue.async {
            // save copy in database
            self.friendStore.addFriend(contact)
            self.delegate?.newContactAdded(contact: contact)
            // save copy in database
            self.saveContact(contact){ success in
                if success {
                    print("Completed save update to native.")
                }
            }
        }
    }
    func delete(_ contact: Friend, at row: Int){
        self.friendsQueue.async {
            // delete copy in database
            self.friendStore.deleteFriend(contact)
            self.delegate?.contactDeleted(row: row)
            // delete copy in native database
            self.updateContact(contact){ success in
                if success {
                    print("Completed delete update from native.")
                }
            }
        }
    }
    func update(_ contact: Friend){
        self.friendsQueue.async {
            // update copy in database
            self.friendStore.updateFriend(contact)
            self.delegate?.contactUpdated(contact)
            // update copy in native database
            self.updateContact(contact){ success in
                if success {
                    print("Completed update contact to native.")
                }
            }
        }
    }
    
    func getContactList()->[String: Friend]{
        let immutableList = friendStore.friends // Copying this variable into a new variable for immutability
        return self.friendsQueue.sync {
            return immutableList
        }
    }
    
    func getContact(key: String) -> Friend? {
        return self.friendsQueue.sync {
            return friendStore.get(key: key)
        }
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
            request.add(contact.toMutableContact()!, toContainerWithIdentifier: nil)
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
        if let mutableContact = contact.toMutableContact(){
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
    }
    
    private func updateContact(_ contact: Friend, completition: @escaping (Bool) -> Void) {
        guard isAuthorized else {
            completition(false)
            return
        }
        do{
            let request = CNSaveRequest()
            request.update(contact.toMutableContact()!)
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


