//
//  PersonStore.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/24/21.
//

import UIKit
import Contacts
class BasePersonStore {
    var persons = [String:Person]()
    var contactsUtils = ContactsUtils.sharedInstance
}
protocol PersonStore : BasePersonStore{
    func fetchAllContacts(compilationClosure: @escaping (_  contactsFetched: Bool)->())
    func addPerson(_ person : Person)
    func deletePerson(_ person: Person)
    func contains(_ person:Person) -> Bool
    func get(key: String) -> Person?
}

extension PersonStore{
    func addPerson(_ person: Person) {
        persons[person.uid] = person
    }
    
    func deletePerson(_ person: Person) {
        // remove in-memo
        persons.removeValue(forKey: person.uid)
        // remove in Contacts.app
        DispatchQueue.global(qos: .utility).async {
            do{
                try self.contactsUtils.removeContact(person.storedContactValue!)
            }catch let err{
                print("Failed to delete contact in Contacts native app: ",err)
            }
        }
    }
    func contains(_ person:Person) -> Bool{
        return persons[person.uid] != nil
    }
    func get(key: String) -> Person?{
        return persons[key]
    }
    func fetchAllContacts(compilationClosure: @escaping (_ contactsFetched: Bool)->()){
        DispatchQueue.global(qos: .utility).async {
            self.contactsUtils.requestForAccess{ (accessGranted) in
                if accessGranted{
                    let contacts = self.contactsUtils.fetchData()
                    self.reloadPersons(cnContacts: contacts)
                }
                compilationClosure(accessGranted)
            }
        }
    }
    func reloadPersons(cnContacts:[CNContact]){
        // override current list with cnContacts
        for c in cnContacts{
            persons[c.identifier] = Person(contact: c)
        }
    }
}

class InMemoPersonStore : BasePersonStore, PersonStore{

    override init() {
        super.init()
    }

    @discardableResult func addRandomPerson()->Person{
        let p = Person(random: true)
        addPerson(p)
        return p
    }

}

class PlistPersonStore: BasePersonStore,PersonStore {
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
