//
//  ViewController.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/24/21.
//

import UIKit

class ContactsViewController: UITableViewController {
    // MARK: Properties
    var personStore:PersonStore!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK: Actions
    @IBAction func addContact(sender: UIBarButtonItem){
        
    }
}

// MARK: - UITableViewDataSource
extension ContactsViewController{
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
}

// MARK: - UITableViewDelegate
extension ContactsViewController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

