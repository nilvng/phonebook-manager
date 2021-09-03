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
    
    static let shared = ContactsUtils()
    private init(){} // singleton
    
    func removeContact(_ contact: CNMutableContact) throws {
        let saveRequest = CNSaveRequest()
        saveRequest.delete(contact)
        try contactsStore.execute(saveRequest)
    }
    
    func updateContact(_ contact: CNMutableContact) throws {
        let request = CNSaveRequest()
        request.update(contact)
        try contactsStore.execute(request)
    }
    func getAllContacts()-> [CNContact]{
        // fetching all contacts from the Contacts.app
        var results: [CNContact] = []
        var keysToFetch : [CNKeyDescriptor] = [CNContactIdentifierKey,CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey, CNContactImageDataKey] as [CNKeyDescriptor]
        keysToFetch += [CNContactViewController.descriptorForRequiredKeys()]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        do {
            try self.contactsStore.enumerateContacts(with: fetchRequest, usingBlock: {(contact, stopPointer) in
                results.append(contact)
            })
        } catch let err {
            print("Failed to fetch contacts: ",err)
        }
        return results
    }
    
    func accessGranted() -> Bool{
        return CNContactStore.authorizationStatus(for: .contacts) == .authorized
    }
    
    func requestAccess(complitionHandler:@escaping ( _ accessGranted:Bool)->Void)
    {
        // Depricated! :request for access to Contacts.app
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
