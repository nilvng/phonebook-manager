//
//  ViewController.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/24/21.
//

import UIKit
import ContactsUI
import Contacts

class PersonsViewController: UITableViewController {
    // MARK: Properties
    var personStore:PersonStore!
    
    // MARK: Lifecycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        navigationItem.rightBarButtonItem = editButtonItem
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        personStore.fetchAllContacts{ (fetched) in
            if fetched{
                print("from Contacts.")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else{
                print("from local.")
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK: Actions
    @IBAction func addNativeContact(sender: UIBarButtonItem){
        personStore.addPerson(Person(random: true))
    }

}
// MARK: - CNContactPickerDelegate
extension PersonsViewController : CNContactPickerDelegate{
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]){
        let newContacts = contacts.compactMap{Person(contact: $0)}
        
        for c in newContacts{
            if !personStore.contains(c){
                personStore.addPerson(c)
            }
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension PersonsViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personStore.persons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell",for: indexPath)
        
        let keys = Array(personStore.persons.keys)
        if let cell = cell as? ContactCell{
            cell.person = personStore.get(key:keys[indexPath.row])
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let keys = Array(personStore.persons.keys)
            guard let person = personStore.get(key: keys[indexPath.row]) else { return } // TODO: cannot get person
            personStore.deletePerson(person)
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UITableViewDelegate
extension PersonsViewController{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let keys = Array(personStore.persons.keys)
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let person = personStore.get(key: keys[indexPath.row]) else { return }// TODO: cannot get person from the contact list
        let contact = person.toCNContact()
        let nativeContactVC = CNContactViewController(forUnknownContact: contact)
        nativeContactVC.allowsEditing = false
        nativeContactVC.allowsActions = false

        navigationController?.pushViewController(nativeContactVC, animated: true)
    }
}

