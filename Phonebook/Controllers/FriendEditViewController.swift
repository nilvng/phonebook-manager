//
//  DetailPersonViewController.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/2/21.
//

import UIKit

protocol EditViewDelegate {
    func changesSubmitted(item: Friend)
}

class FriendEditViewController: UITableViewController {

    typealias FriendChangeAction = (Friend) -> Void
    
    private var editedFriend : Friend = .init(random: false)
    private var isNew : Bool = false
    var delegate : EditViewDelegate?
    var friendAddAction : FriendChangeAction?
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.setTitle("Submit", for: .normal)
        button.tintColor = .white
        return button
    }()
    
    init(for friend: Friend?) {
        super.init(nibName: nil, bundle: nil)
        if let friend = friend {
            editedFriend = friend.copy()
        }
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(onSubmitChanges))
 
    }
    
    func configure(for friend: Friend, addAction: FriendChangeAction? = nil){
        self.editedFriend = friend
        self.friendAddAction = addAction
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.register(FriendTextEditCell.self, forCellReuseIdentifier: FriendTextEditCell.identifier)
        

        tableView.rowHeight = 65
        tableView.separatorStyle = .none
    }
    
    @objc func onSubmitChanges(){
        delegate?.changesSubmitted(item: editedFriend)
        navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion:nil)
            
    }
    
    public enum FriendTextDetail: Int, CaseIterable{
        case firstname
        case lastname
        case phonenumber
        
        func displayText(for friend: Friend) -> String? {
            switch self {
            case .firstname:
                return friend.firstName
            case .lastname:
                return friend.lastName
            case .phonenumber:
                return friend.phoneNumbers.first
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
                friend.phoneNumbers[0] = newValue

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
        let placeholder = detail.displayPlaceholder() ?? ""
        cell.selectionStyle = .none
        cell.backgroundColor = .systemGray
        return cell
    }
}

