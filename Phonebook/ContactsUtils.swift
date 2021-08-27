//
//  ContactsUtils.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/26/21.
//

import UIKit
import Contacts
import ContactsUI
class ContactsUtils {
    let contactsStore = CNContactStore()
    
    static let sharedInstance : ContactsUtils = {
        let instance = ContactsUtils()
        return instance
    }()
    private init(){} // singleton
    
    func removeContact(_ contact: CNMutableContact) throws {
        let saveRequest = CNSaveRequest()
        saveRequest.delete(contact)
        try contactsStore.execute(saveRequest)
    }
    func fetchData()-> [CNContact]{
        // fetching all contacts from the Contacts.app
        var results: [CNContact] = []
        let keysToFetch = [CNContactGivenNameKey, CNContactMiddleNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as [CNKeyDescriptor])
        do {
            try self.contactsStore.enumerateContacts(with: fetchRequest, usingBlock: {(contact, stopPointer) in
                results.append(contact)
            })
        } catch let err {
            print("Failed to fetch contacts: ",err)
        }
        return results
    }
    
    func requestForAccess(complitionHandler:@escaping ( _ accessGranted:Bool)->Void)
    {
        // request for access to Contacts.app if it has not been granted
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authorizationStatus
        {
            case .authorized:
                complitionHandler(true)
            case .notDetermined,.denied:
                self.contactsStore.requestAccess(for: .contacts  ) { (access, accessError) in
                    if access{
                        complitionHandler(access)
                    }else{
                        if authorizationStatus == .denied{
                            let message="Permission denied, user can change this decision through Settings app"
                            DispatchQueue.main.async{
                                print(message)
                            }
                        }
                    }
            }
            default:
            complitionHandler(false)
        }
    }
}
