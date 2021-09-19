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
    private var friend : Friend? {
        didSet{
            guard let person = friend else { return }
            personNameLabel.text = person.firstName + " " + person.lastName
            defaultPhoneNumberLabel.text = person.getPhoneNumber(index: 0) // display first number
            if let avatarData = person.avatarData{
                prepareAvatar(avatarData){ result in
                    switch result{
                        case .success(let image):
                            self.avatarImage.image = image
                    case .failure(_): // hanging..
                        self.avatarImage.image = UIImage(named: "default_avatar")
                    }
                }
            } else {
                self.avatarImage.image = UIImage(named: "default_avatar")
            }
            personNameLabel.accessibilityIdentifier = personNameLabel.text
        } // didSet
    }
    
    private let personNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
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
    
    func configure(with friend: Friend){
        self.friend = friend
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(avatarImage)
        contentView.addSubview(personNameLabel)
        contentView.addSubview(defaultPhoneNumberLabel)
        
        accessoryType = .disclosureIndicator
        
        }
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImage.anchor(top: contentView.topAnchor, left:  contentView.leftAnchor, bottom: nil, right: nil, padding: .init(top: 5, left: 5, bottom: 0, right: 0), size: .init(width: 60, height: 60))
        personNameLabel.anchor(top:  contentView.topAnchor, left: avatarImage.rightAnchor, bottom: nil, right: nil, padding: .init(top: 20, left: 10, bottom: 0, right: 10), size: .init( width: frame.size.width / 2, height: 0))
        defaultPhoneNumberLabel.anchor(top: personNameLabel.bottomAnchor, left: avatarImage.rightAnchor, bottom: contentView.bottomAnchor, right: nil, padding: .init(top: 5, left: 10, bottom: 10, right: 0))
    }
    private func prepareAvatar(_ data: Data,
                               completion: @escaping (Result<UIImage,Error>)->Void){
        guard let image = UIImage(data: data) else {
            completion(.failure(FetchError.failed))
            return
        }
        completion(.success(image))
//        image.prepareThumbnail(of:CGSize(width: 60, height: 60)){ thumbnail in
//            guard let thumbnail = thumbnail else {
//                completion(.failure(FetchError.failed))
//                return
//            }
//            completion(.success(thumbnail))
//        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
