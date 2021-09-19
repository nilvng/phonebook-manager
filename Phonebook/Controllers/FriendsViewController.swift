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
        //view.rowHeight = UITableView.automaticDimension
        //view.estimatedRowHeight = 100
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
        
        // set identifier to facilitate UI Test
        view.accessibilityIdentifier = "FriendsView"
        tableView.accessibilityIdentifier = "table-FriendsView"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // populate table
        let contacts = PhonebookManager.shared.getAll()
        self.friendList = contacts.compactMap { $0.value }
        self.tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    //MARK: Actions
    @objc func addContact(){
        // add to the store
        let addView = FriendDetailViewController()
        addView.configure(with: Friend(), isNew: true, changeAction: { friend in
            PhonebookManager.shared.add(friend)
        })
        present(UINavigationController(rootViewController: addView), animated: true, completion: nil)

    }
    
    func refreshViewWith(data: [String:Friend]){
        // refreshing view only when data has been changed
        if self.friendList.count == 0 {
            DispatchQueue.main.async {
                print("Refresh table.")
                self.friendList = data.compactMap { $0.value }
                self.tableView.reloadData()
            }
            return

        }
        for e in self.friendList {
            if data[e.uid] == nil || data[e.uid] != e {
                
                DispatchQueue.main.async {
                    print("Refresh table.")
                    self.friendList = data.compactMap { $0.value }
                    self.tableView.reloadData()
                }
                return

                }
            }
        }
}

extension FriendsViewController: PhonebookManagerDelegate{
    
    func contactListRefreshed(contacts: [String : Friend]) {
        // update with the refreshed contact list
        refreshViewWith(data: contacts)
    }
    func newContactAdded(contact: Friend){
 
        DispatchQueue.main.async {
            // update data source
            self.friendList.append(contact)
            let index = self.friendList.count - 1 // add new contact to the end of list
            let indexPath = IndexPath(row: index, section: 0)
            // refresh table
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    func contactDeleted(_ contact: Friend){
        guard let row = self.friendList.firstIndex(of: contact) else {
            print("Error: contact to delete from table is out of range")
            return
        }
        DispatchQueue.main.async {
            self.friendList.remove(at: row)
            let indexPath = IndexPath(row: row, section: 0)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    func contactUpdated(_ contact: Friend){
        guard let rowToUpdate = friendList.firstIndex(where: {$0.uid == contact.uid}) else {return }
        friendList[rowToUpdate] = contact
        let indexPath = IndexPath(row: rowToUpdate, section: 0)
        
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let friend = friendList[indexPath.row]
        print(friend)
        
        let detailController = FriendDetailViewController()

        detailController.configure(with: friend){ friendToUpdate in
            // only ask Manager to update it truly changed
            if friendToUpdate != friend{
                PhonebookManager.shared.update(friendToUpdate)
            }
        }
        navigationController?.pushViewController(detailController, animated: true)
    }
}

