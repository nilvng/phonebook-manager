//
//  FriendDetailCell.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/2/21.
//

import UIKit

protocol TextEditCellDelegate {
    func textEndEditing(for: FriendEditViewController.FriendTextDetail,newValue: String)
}

class FriendTextEditCell: UITableViewCell, UITextFieldDelegate {
    static let identifier = "TextEditCell"
    var delegate : TextEditCellDelegate? = nil
    private let textfield = UITextField()
    private var attribute: FriendEditViewController.FriendTextDetail? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textfield)
        textfield.delegate = self
    }
    func configure(for attr:  FriendEditViewController.FriendTextDetail,
                   with text: String,
                   placeholder: String){
        
        self.attribute = attr
        textfield.placeholder = placeholder
        textfield.text = text
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.textEndEditing(for: attribute!, newValue: textfield.text ?? "")
        textfield.resignFirstResponder()
        return true

    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        delegate?.textEndEditing(for: attribute!, newValue: textfield.text ?? "")
        textfield.resignFirstResponder()
        return true
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        setupTextfield()
    }
    private func setupTextfield(){
        textfield.layer.cornerRadius = 10
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.backgroundColor = .white
        textfield.isUserInteractionEnabled = true
    
        textfield.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, padding: .init(top: 7, left: 7, bottom: 3, right: 7), size: .init(width: contentView.frame.width-14, height: contentView.frame.height - 10))

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
