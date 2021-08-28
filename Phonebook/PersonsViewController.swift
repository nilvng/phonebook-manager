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
    var cellID = "ContactCell"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNativeContact))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ContactCell.self, forCellReuseIdentifier: cellID)
        
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
    @objc func addNativeContact(){
        personStore.addPerson(Person(random: true))
        tableView.reloadData()
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID,for: indexPath) as! ContactCell
        let keys = Array(personStore.persons.keys)
        
        cell.person = personStore.get(key:keys[indexPath.row])
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
        let detailController = CNContactViewController(for: person.toCNContact())
        navigationController?.pushViewController(detailController, animated: true)
    }
}

