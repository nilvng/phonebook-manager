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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(onEditButtonPressed))
        configure(with: friend)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: FriendDetailViewController.identifier)
        tableView.register(FriendDetailAvatarHeader.self, forHeaderFooterViewReuseIdentifier: FriendDetailAvatarHeader.identifier)
        
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        
    }
    
    @objc func onEditButtonPressed(){
        guard let friend = friend else {return }
        let editViewController = FriendEditViewController(for: friend)
        present(editViewController, animated: true, completion: nil)
    }
    
    public enum FriendDetail: Int, CaseIterable{
        case phonenumber
        
        func displayText(for friend: Friend?) -> String? {
            switch self {
            case .phonenumber:
                return friend?.phoneNumber
            }
        }
        var cellIcon: UIImage?{
            switch self {
            case .phonenumber:
                return UIImage(systemName: "phone")
                }
            }
        }
}

extension FriendDetailViewController{
    static let identifier = "ContactDetailCell"
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FriendDetail.allCases.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendDetailViewController.identifier, for: indexPath)
        let detail = FriendDetail(rawValue: indexPath.row)
        cell.textLabel?.text = detail?.displayText(for: friend)
        cell.imageView?.image = detail?.cellIcon
        return cell
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: FriendDetailAvatarHeader.identifier) as! FriendDetailAvatarHeader
        if let contact = friend, let imageData = contact.avatarData{
            headerView.configure(avatar: imageData,
                                 fullname: "\(contact.firstName) \(contact.lastName)")
            return headerView
        }
        return nil
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        200
    }
}
