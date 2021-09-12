//
//  DetailPersonViewController.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/27/21.
//

import UIKit

class FriendDetailViewController: UIViewController {
    typealias FriendChangeAction = (Friend) -> Void
    private var changeAction : FriendChangeAction?
    
    private var friend : Friend?
    private var tempFriend : Friend?
    private var dataSource : UITableViewDataSource?
    private var tableView : UITableView = {
       let view = UITableView()
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 70
        view.register(UITableViewCell.self, forCellReuseIdentifier: FriendDetailDataSource.identifier)
        view.register(FriendTextEditCell.self, forCellReuseIdentifier: FriendTextEditCell.identifier)
        view.register(FriendDetailAvatarCell.self, forCellReuseIdentifier: FriendDetailAvatarCell.identifier)
        view.register(FriendAvatarEditCell.self, forCellReuseIdentifier: FriendAvatarEditCell.identifier)

        view.tableFooterView = UIView()
        return view
    }()
    
    func configure(with friend: Friend, changeAction: @escaping FriendChangeAction){
        self.friend = friend
        self.changeAction = changeAction
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.layer.bounds
        tableView.delegate = self

        setEditing(false, animated: false)

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = editButtonItem
        
    }
    
    @objc func onEditButtonPressed(){
        if tableView.isEditing {
            self.setEditing(false, animated: true)
        } else {
            self.setEditing(true, animated: true)
        }
    }
    
    override func setEditing(_ isEditing: Bool, animated: Bool){
        super.setEditing(isEditing, animated: animated)
        
        if isEditing {
            transitionToEditMode()
        } else {
            // done editing existing contact
            if let temp = tempFriend {
                self.friend = temp
                self.tempFriend = nil
                self.changeAction?(temp)
            }
            transitionToDetailMode()
        }
        tableView.dataSource = dataSource
        tableView.reloadData()
    }
    
    fileprivate func transitionToDetailMode(){
        dataSource = FriendDetailDataSource(friend: self.friend!)
        tableView.allowsSelection = false
        navigationItem.title = NSLocalizedString("View Contact", comment: "nav title for detail view")
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    fileprivate func transitionToEditMode(){
        dataSource = FriendEditDataSource(friend: self.friend!.copy()){ friend in
            self.tempFriend = friend
        }
        navigationItem.title = NSLocalizedString("Edit Contact", comment: "edit reminder nav title")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTrigger))
    }
    @objc
    func cancelButtonTrigger() {
        tempFriend = nil
        setEditing(false, animated: true)
    }

}

// MARK: EditViewDelegate
extension FriendDetailViewController : EditViewDelegate {
    
    func changesSubmitted(item updatedFriend: Friend){
        self.friend = updatedFriend
        tableView.reloadData()
        PhonebookManager.shared.update(updatedFriend)
    }

}


extension FriendDetailViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }
        return 65
    }
}

