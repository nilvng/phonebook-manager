//
//  PhonebookManager.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/27/21.
//

import Foundation
protocol PhonebookDelegate {
    func contactListRefreshed(contacts: [String: Friend])
    func newContactAdded(contact: Friend)
    func contactDeleted(contact: Friend)
}
class PhonebookManager {
    var store: FriendStore = InMemoFriendStore.shared
    let contactsUtils: ContactsUtils = ContactsUtils.shared
    
    var delegate: PhonebookDelegate?
    
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
        let granted = self.contactsUtils.accessGranted()
        if granted {
            DispatchQueue.global(qos: .utility).async {
                // pull data
                let cnContacts = self.contactsUtils.getAllContacts()
                // merge data
                contacts = self.store.reloadData(cnContacts: cnContacts)
                // inform table view
                print(self.delegate ?? "no delegate")
                self.delegate?.contactListRefreshed(contacts: contacts)
                complilationHandler(.success("Sync data is completed"))
                }
        } else{
            complilationHandler(.failure(FetchError.unauthorized))
        }
    }
    func addContact(_ contact: Friend){
        
    }
    func deleteContact(_ contact: Friend){
        
    }
}

enum FetchError: Error {
    case unauthorized
    case failed
}
