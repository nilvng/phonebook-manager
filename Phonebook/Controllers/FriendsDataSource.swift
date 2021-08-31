//
//  FriendsDataSource.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/29/21.
//

// DEPRECATED
import UIKit
class FriendsDataSource: NSObject {
    var friends = [Friend]()
    
}
extension FriendsDataSource : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.identifier,for: indexPath) as! ContactCell
        
        cell.person = friends[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
}
