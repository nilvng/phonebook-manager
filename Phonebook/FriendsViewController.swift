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
    var friendStore:FriendStore!{
        didSet{
            friendList = Array(friendStore.friends.values)
        }
    }
    var friendList = [Friend]()
    
    var cellID = "ContactCell"
    var tableView : UITableView = {
        let view = UITableView()
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 45
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tableFooterView = UIView() // hide extra lines
        return view
    }()
    
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
        navigationItem.title = "My Phonebook"

        // set up Table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactCell.self, forCellReuseIdentifier: cellID)
        view.addSubview(tableView)
        // layout table view
        tableView.topAnchor.constraint(equalTo:view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo:view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo:view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo:view.bottomAnchor).isActive = true

        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK: Actions
    @objc func addNativeContact(){
        friendStore.addFriend(Friend(random: true))
        tableView.reloadData()
    }

}
// MARK: - CNContactPickerDelegate
extension FriendsViewController : CNContactPickerDelegate{
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]){
        let newContacts = contacts.compactMap{Friend(contact: $0)}
        
        for c in newContacts{
            if !friendStore.contains(c){
                friendStore.addFriend(c)
            }
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension FriendsViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID,for: indexPath) as! ContactCell
        cell.person = friendList[indexPath.row]
        return cell
    }

}

// MARK: - UITableViewDelegate
extension FriendsViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let friend = friendList[indexPath.row]
            friendStore.deleteFriend(friend)
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let friend = friendList[indexPath.row]
        let detailController = CNContactViewController(for: friend.toCNContact())
        navigationController?.pushViewController(detailController, animated: true)
    }
}

