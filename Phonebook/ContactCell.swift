//
//  ContactCell.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/25/21.
//

import UIKit
import Contacts

class ContactCell: UITableViewCell {
    
    var person : Friend? {
        didSet{
            guard let person = person else {
                return
            }
            personNameLabel.text = person.firstName + " " + person.lastName
            defaultPhoneNumberLabel.text = person.phoneNumber?.value.stringValue
            avatarImage.image = UIImage(named: person.avatarKey ?? "default_avatar")
        }
    }
    
    private let personNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    private let avatarImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    private let defaultPhoneNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .left
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(avatarImage)
        addSubview(personNameLabel)
        addSubview(defaultPhoneNumberLabel)
        
        avatarImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 70, height: 70, enableInsets: false)
        personNameLabel.anchor(top: topAnchor, left: avatarImage.rightAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width / 2, height: 0, enableInsets: false)
        defaultPhoneNumberLabel.anchor(top: personNameLabel.bottomAnchor, left: avatarImage.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width / 2, height: 0, enableInsets: false)
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
