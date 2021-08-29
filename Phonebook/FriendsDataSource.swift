//
//  FriendsDataSource.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/29/21.
//

import UIKit
class FriendsDataSource: NSObject {
    var friends = [Friend]()
    var cellID = ""
    
    init(cellID: String) {
        self.cellID = cellID
    }
    init(friendsDict: [String:Friend], cellID: String) {
        self.friends = Array(friendsDict.values)
        self.cellID = cellID
    }
}
extension FriendsDataSource : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID,for: indexPath) as! ContactCell
        
        cell.person = friends[indexPath.row]
        return cell
    }
    
}
