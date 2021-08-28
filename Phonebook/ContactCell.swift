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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCell(){
        
        let formatter = CNContactFormatter()
        formatter.style = .fullName
        
        if let person = person{
            let fullname = person.firstName + " " + person.lastName
            textLabel?.text = fullname
            detailTextLabel?.text = person.phoneNumber?.value.stringValue
        }
    }
    
}
