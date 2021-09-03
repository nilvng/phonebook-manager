//
//  DetailPersonViewController.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/2/21.
//

import UIKit

class FriendEditViewController: UITableViewController {

    private var editedFriend : Friend = .init(random: false)
    
    init(for friend: Friend?) {
        super.init(nibName: nil, bundle: nil)
        if let friend = friend {
            editedFriend = friend.copy()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.register(FriendTextEditCell.self, forCellReuseIdentifier: FriendTextEditCell.identifier)
        
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
    }
    
    
    public enum FriendTextDetail: Int, CaseIterable{
        case firstname
        case lastname
        case phonenumber
        
        func displayText(for friend: Friend) -> String? {
            guard (friend != nil) else {
                return self.displayPlaceholder()
            }
            switch self {
            case .firstname:
                return friend.firstName
            case .lastname:
                return friend.lastName
            case .phonenumber:
                return friend.phoneNumber
            }
        }
        func displayPlaceholder() -> String?{
            switch self {
            case .firstname:
                return "First name"
            case .lastname:
                return "Last name"
            case .phonenumber:
                return "Phone number"
            }
        }
        
        func setValue(for friend: Friend, newValue: String){
            switch self {
            case .firstname:
                friend.firstName = newValue
            case .lastname:
                friend.lastName = newValue
            case .phonenumber:
                friend.phoneNumber = newValue

            }
        }
        var cellIcon: UIImage?{
            switch self {
            case .firstname:
                return UIImage(systemName: "person")
            case .phonenumber:
                return UIImage(systemName: "phone")
            case .lastname:
                return nil
                }
            }
        }
}
// MARK: - UITableViewDataSource
extension FriendEditViewController{
    static let identifier = "ContactEditDetailCell"
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FriendTextDetail.allCases.count + 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendTextEditCell.identifier, for: indexPath) as! FriendTextEditCell
        guard let detail = FriendTextDetail(rawValue: indexPath.row) else {return UITableViewCell()}
        
        let text = detail.displayText(for: editedFriend) ?? ""
        cell.delegate = self
        cell.configure(for: detail, with: text, isPlaceholder: false)
        return cell
    }
}


extension FriendEditViewController: TextEditCellDelegate {
    func textEndEditing(for attr: FriendTextDetail, newValue: String) {
        print("set this attr \(attr): \(newValue).")
        attr.setValue(for: editedFriend, newValue: newValue)
    }
}
