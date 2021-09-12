//
//  FriendEditDataSource.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/8/21.
//

import UIKit

class FriendEditDataSource : NSObject {
    typealias FriendChangeAction = (Friend) -> Void
    private var changeAction : FriendChangeAction?

    private var isNew : Bool = false
    private var friend : Friend
    
    public enum ContactDetail: Int, CaseIterable{
        case avatar
        case firstname
        case lastname
        case phonenumber
        
        func getCellId() -> String {
            switch self {
            case .avatar:
                return FriendAvatarEditCell.identifier
            case .firstname:
                return FriendTextEditCell.identifier
            case .lastname:
                return FriendTextEditCell.identifier
            case .phonenumber:
                return FriendTextEditCell.identifier
            }
        }
        
    }

    init( friend: Friend, isNew : Bool = false ,changeAction: @escaping FriendChangeAction) {
        self.friend = friend
        self.changeAction = changeAction
        self.isNew = isNew
        super.init()
    }

}
extension FriendEditDataSource : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactDetail.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let detail = ContactDetail.init(rawValue: indexPath.row) else {
            fatalError("friend detail is out of range.")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: detail.getCellId(), for: indexPath)
        
        switch detail {
        case .avatar:
            // first cell is contact avatar
            if let avatarCell = cell as? FriendAvatarEditCell{
                avatarCell.configure(avatar: friend.avatarData)
            }
        case .firstname:
            if let fnameCell = cell as? FriendTextEditCell{
                fnameCell.configure(with: friend.firstName, placeholder: "First name"){ value in
                    self.friend.firstName = value
                    self.changeAction?(self.friend)
                }
            }
        case .lastname:
            if let lnameCell = cell as? FriendTextEditCell{
                lnameCell.configure(with: self.friend.lastName, placeholder: "Last name"){ lastname in
                    self.friend.lastName = lastname
                    self.changeAction?(self.friend)
                }
            }
        case .phonenumber:
            if let phoneNumberCell = cell as? FriendTextEditCell{
                phoneNumberCell.configure(with: self.friend.getPhoneNumber(index: 0), placeholder: "Phone number"){ value in
                    self.friend.setPhoneNumber(value, at: 0)
                    self.changeAction?(self.friend)

                }
            }
        }
        return cell
    }
    
    
}
