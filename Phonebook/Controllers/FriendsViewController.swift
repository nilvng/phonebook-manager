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
//        view.rowHeight = UITableView.automaticDimension
//        view.estimatedRowHeight = 108
        view.rowHeight = 70
        view.tableFooterView = UIView() // hide extra lines
        return view
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }



    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Phonebook"
        let rightButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(toggleEditMode))
        
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addContact))
        
        view.addSubview(tableView)

        // set up Table view
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        // set up relationship with Phonebook manager
        PhonebookManager.shared.delegate = self
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("friends list will appear...")
        friendList = PhonebookManager.shared.getContactList().map{ $0.value}
        tableView.reloadData()
        
    }
    
    //MARK: Actions
    @objc func addContact(){
        // add to the store
        PhonebookManager.shared.addContact(Friend(random: true))

    }
    
    @objc func toggleEditMode(){
        if (tableView.isEditing  == true) {
            tableView.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItem?.title = "Edit"

        } else {
            tableView.setEditing(true, animated: true)
            self.navigationItem.rightBarButtonItem?.title = "Done"
        }
    }
}

extension FriendsViewController: PhonebookDelegate{
    
    func contactListRefreshed(contacts: [String : Friend]) {
            // update with the refreshed contact list
        self.friendList = contacts.map{ $0.value}
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func newContactAdded(contact: Friend){
        // update data source
        self.friendList.append(contact)
        let index = self.friendList.count - 1 // add new contact to the end of list
        let indexPath = IndexPath(row: index, section: 0)
        // refresh table
        DispatchQueue.main.async {
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    func contactDeleted(row: Int){
        self.friendList.remove(at: row)
        let indexPath = IndexPath(row: row, section: 0)
        
        DispatchQueue.main.async {
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - UITableViewDataSource
extension FriendsViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.identifier,for: indexPath) as! ContactCell
        cell.configure(with: friendList[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FriendsViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let friend = friendList[indexPath.row]
            PhonebookManager.shared.deleteContact(friend, at: indexPath.row)

        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let friend = friendList[indexPath.row]
        let detailController = FriendDetailViewController(for: friend)
        navigationController?.pushViewController(detailController, animated: true)
    }
}

