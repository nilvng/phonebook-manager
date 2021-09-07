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
    private var friendStore: FriendStore = InMemoFriendStore.shared
    private let nativeStore = CNContactStore()
    
    var delegate: PhonebookManagerDelegate?
    
    static let shared = PhonebookManager()
    private init(){}
    
    func fetchData(_ complilationHandler: @escaping (Result<String,Error>) -> () ){
        var contacts : [String: Friend] = [:]
        // TODO: when contacts list is occupied
        // 0. pull data from local database
        // 1. upload current list to Contacts.app
        // 1a. record is new
        // 1b. record existed
        
        // Fetch data from native Contacts app
        nativeStore.requestAccess(for: .contacts) { (access, error) in
            if access {
                DispatchQueue.global(qos: .utility).async {
                    // pull data
                    let cnContacts = self.getAllContactsFromNative()
                    // merge data
                    contacts = self.friendStore.reloadData(cnContacts: cnContacts)
                    // inform table view
                    self.delegate?.contactListRefreshed(contacts: contacts)
                    complilationHandler(.success("Sync data is completed"))
                    }
            } else{
                complilationHandler(.failure(FetchError.unauthorized))
            }
        }
    }
    func refreshData(){
        var dataDidChange = false

        DispatchQueue.global(qos: .utility).async {
            // pull data
            let cnContacts = self.getAllContactsFromNative()
            // case 1: native contact deleted O(n^2)
            if cnContacts.count < self.friendStore.friends.count{
                for current in self.friendStore.friends.values{
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
                print("data did change")
                self.delegate?.contactListRefreshed(contacts: self.friendStore.friends)
            }
        }
    }
    func addContact(_ contact: Friend){
        friendStore.addFriend(contact)
        DispatchQueue.global(qos: .background).async {
            do{
                let request = CNSaveRequest()
                request.add(contact.toMutableContact()!, toContainerWithIdentifier: nil)
                try self.nativeStore.execute(request)
            }catch let err{
                print("Failed to delete contact in Contacts native app: ",err)
            }
            
            self.delegate?.newContactAdded(contact: contact)
        }
    }
    func deleteContact(_ contact: Friend, at index: Int? = nil){
        friendStore.deleteFriend(contact)
        
        DispatchQueue.global(qos: .background).async {
            if let mutableContact = contact.toMutableContact(){
                do{
                    let request = CNSaveRequest()
                    request.delete(mutableContact)
                    try self.nativeStore.execute(request)
                }catch let err{
                    print("Failed to delete contact in Contacts native app: ",err)
                }
            }
        }
        if let row = index {
            self.delegate?.contactDeleted(row: row)
        }
    }
    func updateContact(_ contact: Friend){
        // update copy in memory
        friendStore.updateFriend(contact)
        // update copy in native database
        DispatchQueue.global(qos: .background).async {
            if let mutableContact = contact.toMutableContact(){
                do {
                    let request = CNSaveRequest()
                    request.update(mutableContact)
                    try self.nativeStore.execute(request)
                } catch (let err){
                    print("cannot update contact to native database: \(err)")
                }
            }
        }
        self.delegate?.contactUpdated(contact)
    }
    
    func getContactList()->[String: Friend]{
        return friendStore.friends
    }
    func getContact(key: String) -> Friend? {
        return friendStore.get(key: key)
    }
    

    func getAllContactsFromNative()-> [CNContact]{
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
}

enum FetchError: Error {
    case unauthorized
    case failed
}
