//
//  ContactCell.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/25/21.
//

import UIKit
import Contacts

class ContactCell: UITableViewCell {
    static let identifier = "ContactCell"
    var person : Friend? {
        didSet{
            guard let person = person else { return }
            personNameLabel.text = person.firstName + " " + person.lastName
            defaultPhoneNumberLabel.text = person.phoneNumber
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
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 30
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
        
        accessoryType = .disclosureIndicator

        }
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImage.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, padding: .init(top: 5, left: 5, bottom: 4, right: 5), size: .init(width: 60, height: 60))
        personNameLabel.anchor(top: topAnchor, left: avatarImage.rightAnchor, bottom: nil, right: nil, padding: .init(top: 20, left: 10, bottom: 0, right: 0), size: .init( width: frame.size.width / 2, height: 0))
        defaultPhoneNumberLabel.anchor(top: personNameLabel.bottomAnchor, left: avatarImage.rightAnchor, bottom: nil, right: nil, padding: .init(top: 0, left: 10, bottom: 0, right: 0), size: .init(width: frame.size.width / 2, height: 0))
                
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
