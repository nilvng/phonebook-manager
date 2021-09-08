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

        func setValue(newValue: String, for contact: Friend){

            switch self {
            case .avatar:
                fatalError()
            case .firstname:
                contact.firstName = newValue
            case .lastname:
                contact.lastName = newValue
            case .phonenumber:
                contact.phoneNumbers[0] = newValue
            }

        }
        func getValue(for friend: Friend) -> String? {
            switch self {
            case .avatar:
                return nil
            case .firstname:
                return friend.firstName
            case .lastname:
                return friend.lastName
            case .phonenumber:
                return friend.phoneNumbers[0]
            }
        }
        
        func getPlaceholder(for friend: Friend) -> String? {
            switch self {
            case .avatar:
                return nil
            case .firstname:
                return "First name"
            case .lastname:
                return "Last name"
            case .phonenumber:
                return "Phone number"
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
        if indexPath.row == 0 {
            // first cell is contact avatar
            let cell = tableView.dequeueReusableCell(withIdentifier: FriendAvatarEditCell.identifier, for: indexPath) as! FriendAvatarEditCell
           
            cell.configure(avatar: friend.avatarData)
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: FriendTextEditCell.identifier) as! FriendTextEditCell
        let detail = ContactDetail.init(rawValue: indexPath.row)!
        cell.configure(with: detail.getValue(for: self.friend) ?? "",
                       placeholder: detail.getPlaceholder(for: self.friend) ?? ""){ value in
            detail.setValue(newValue: value, for: self.friend)
            self.changeAction?(self.friend)
        }
        return cell
    }
    
    
}
