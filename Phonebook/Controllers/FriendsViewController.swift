//
//  ViewController.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/24/21.
//

import UIKit
import ContactsUI
import Contacts

class FriendsViewController : UIViewController {
    // MARK: Properties
    private var friendList = [Friend]()
    private var manager = PhonebookManager.shared
    
    var tableView : UITableView = {
        let view = UITableView()
        view.register(ContactCell.self, forCellReuseIdentifier: ContactCell.identifier)
        // styling
        view.rowHeight = 70
        view.tableFooterView = UIView() // hide extra lines
        return view
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addContact))
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "My Phonebook"
        
        view.addSubview(tableView)

        // set up Table view
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        // set up relationship with Phonebook manager
       // PhonebookManager.shared.delegate = self
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        friendList = PhonebookManager.shared.getContactList().map{ $0.value}
    }
    
    //MARK: Actions
    @objc func addContact(){
        // add to the store
        manager.addContact(Friend(random: true))

    }
}

extension FriendsViewController: PhonebookDelegate{
    func contactListRefreshed(contacts: [String : Friend]) {
        DispatchQueue.main.async {
            //print(contacts)
            self.friendList = contacts.map{ $0.value}
            self.tableView.reloadData()
        }
    }
    func newContactAdded(contact: Friend){
        // update table view
        if let index = friendList.firstIndex(of: contact){
            let indexPath = IndexPath(row: index, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    func contactDeleted(contact: Friend){
        
    }
}

// MARK: - UITableViewDataSource
extension FriendsViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.identifier,for: indexPath) as! ContactCell
        cell.person = friendList[indexPath.row]
        return cell
    }

}

// MARK: - UITableViewDelegate
extension FriendsViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let friend = friendList[indexPath.row]
            friendList.remove(at: indexPath.row)
            manager.deleteContact(friend)
            tableView.deleteRows(at: [indexPath], with: .automatic)

        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let friend = friendList[indexPath.row]
        let detailController = CNContactViewController(for: friend.toCNContact())
        navigationController?.pushViewController(detailController, animated: true)
    }
}

