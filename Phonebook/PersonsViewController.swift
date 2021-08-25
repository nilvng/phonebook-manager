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
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK: Actions
    @IBAction func addNativeContact(sender: UIBarButtonItem){
        
        let contactsPicker = CNContactPickerViewController()
        contactsPicker.delegate = self
        
        present(contactsPicker.self,animated: true)
    }

}
// MARK: - CNContactPickerDelegate
extension PersonsViewController : CNContactPickerDelegate{
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]){
        let newContacts = contacts.compactMap{Person(contact: $0)}
        
        for c in newContacts{
            if !personStore.persons.contains(c){
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
        
        if let cell = cell as? ContactCell{
            cell.person = personStore.persons[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            personStore.deletePerson(at:indexPath.row)
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UITableViewDelegate
extension PersonsViewController{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let contact = personStore.persons[indexPath.row].contactValue
        let nativeContactVC = CNContactViewController(forUnknownContact: contact)
        
        navigationController?.pushViewController(nativeContactVC, animated: true)
    }
}

