//
//  DetailPersonViewController.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/2/21.
//

import UIKit

class FriendEditViewController: UITableViewController {
    private var friend : Friend?
    
    func configure(with friend: Friend){
        self.friend = friend
    }
    init(for friend: Friend) {
        super.init(nibName: nil, bundle: nil)
        configure(with: friend)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: FriendDetailViewController.identifier)
        
        tableView.tableFooterView = UIView()
    }
    
    
    public enum FriendDetail: Int, CaseIterable{
        case firstname
        case lastname
        case phonenumber
        
        func displayText(for friend: Friend?) -> String? {
            switch self {
            case .firstname:
                return friend?.firstName
            case .lastname:
                return friend?.lastName
            case .phonenumber:
                return friend?.phoneNumber
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

extension FriendEditViewController{
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
}

