//
//  ContactCell.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/25/21.
//

import UIKit
import Contacts

class ContactCell: UITableViewCell {
    
//    @IBOutlet private weak var nameLabel : UILabel!
//    @IBOutlet private weak var phoneNumberLabel : UILabel!
    
    var person : Person? {
        didSet{
            configureCell()
        }
    }
    
    private func configureCell(){
        
        let formatter = CNContactFormatter()
        formatter.style = .fullName
        
        guard let person = person,
              let fullname = formatter.string(from: person.contactValue) else { return }
        
        textLabel?.text = fullname
        // TODO: design things
        detailTextLabel?.text = "Contact number..."
    }
}
