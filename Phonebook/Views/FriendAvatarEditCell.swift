//
//  FriendDetailHeader.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/2/21.
//

import UIKit

class FriendAvatarEditCell: UITableViewCell {
    static let identifier = "AvatarEditCell"
    
    private var avatarView : UIImageView = {
       let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle,reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(avatarView)
        backgroundColor = .systemGray5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(avatar data: Data?){
        if let data = data{
            let image = UIImage(data: data)
            avatarView.image = image
        } else {
            avatarView.image = UIImage(named: "default_avatar")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupAvatarView()
    }
    private func setupAvatarView(){
        let avatarConstraints = [
            avatarView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            avatarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 100),
            avatarView.heightAnchor.constraint(equalToConstant: 100)
        ]
        NSLayoutConstraint.activate(avatarConstraints)
    }
    
}

