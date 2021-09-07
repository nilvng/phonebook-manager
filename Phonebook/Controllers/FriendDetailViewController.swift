//
//  DetailPersonViewController.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/27/21.
//

import UIKit

class FriendDetailViewController: UITableViewController {
    private var friend : Friend?
    
    func configure(with friend: Friend){
        self.friend = friend
    }
    init(for friend: Friend) {
        super.init(nibName: nil, bundle: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(onEditButtonPressed))
        configure(with: friend)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: FriendDetailViewController.identifier)
        
        tableView.register(FriendDetailAvatarCell.self, forCellReuseIdentifier: FriendDetailAvatarCell.identifier)
        
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        
        navigationItem.largeTitleDisplayMode = .never
        
    }
    
    @objc func onEditButtonPressed(){
        guard let f = friend else {return }
        let stackView = EditStackViewController(for: f)
        stackView.delegate = self
        navigationController?.pushViewController(stackView, animated: true)
//        let editViewController = FriendEditViewController(for: friend)
//        editViewController.delegate = self
//        navigationController?.pushViewController(editViewController, animated: true)
        //present(editViewController, animated: true, completion: nil)
    }
    
}

// MARK: EditViewDelegate
extension FriendDetailViewController : EditViewDelegate {
    
    func changesSubmitted(item updatedFriend: Friend){
        self.friend = updatedFriend
        tableView.reloadData()
        PhonebookManager.shared.updateContact(updatedFriend)
    }

}

// MARK: - FriendDetailView

extension FriendDetailViewController{
    static let identifier = "ContactDetailCell"
    
    public enum FriendDetail: Int, CaseIterable{
        case avatar
        case phonenumber
        
        func displayText(for friend: Friend?) -> String? {
            switch self {
            case .phonenumber:
                return friend?.phoneNumbers[0]
            case .avatar:
                return nil
            }
        }
        var cellIcon: UIImage?{
            switch self {
            case .phonenumber:
                return UIImage(systemName: "phone")
            case .avatar:
                return nil
                }
            }
        }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FriendDetail.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // first cell is contact avatar
            let cell = tableView.dequeueReusableCell(withIdentifier: FriendDetailAvatarCell.identifier, for: indexPath) as! FriendDetailAvatarCell
            if let contact = friend{
                cell.configure(avatar: contact.avatarData,
                               fullname: "\(contact.firstName) \(contact.lastName)")
                return cell
            } else {
                return UITableViewCell()
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendDetailViewController.identifier, for: indexPath)
        let detail = FriendDetail(rawValue: indexPath.row)
        cell.textLabel?.text = detail?.displayText(for: self.friend)
        cell.imageView?.image = detail?.cellIcon
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 200 // height for avatar cell
        }
        return 65
    }
}
