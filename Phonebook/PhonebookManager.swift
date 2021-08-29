//
//  PhonebookManager.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/27/21.
//

import Foundation
class PhonebookManager {
    var store: FriendStore
    var contactUtils: ContactsUtils
    
    init(store: FriendStore, contactsUtils: ContactsUtils) {
        self.store = store
        self.contactUtils = contactsUtils
    }
    func fetchData(){
        store.fetchAllContacts{ (fetched) in
            if fetched{
                print("from Contacts.")
                // notify ViewController to update the table
            } else{
                print("from local.")
            }
        }
    }
}
