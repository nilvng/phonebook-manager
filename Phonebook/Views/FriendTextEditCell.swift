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
                   isPlaceholder: Bool=false){
        
        self.attribute = attr
        if isPlaceholder {
            textfield.placeholder = text
        } else{
            textfield.text = text
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        delegate?.textEndEditing(for: attribute!, newValue: textfield.text ?? "")
        return true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupTextfield()
    }
    private func setupTextfield(){
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.isUserInteractionEnabled = true
        textfield.backgroundColor = .white
        textfield.frame.size.width = 200
        textfield.frame.size.height = 20
        textfield.topAnchor.constraint(
            equalTo: topAnchor,
            constant: 40).isActive = true
        textfield.centerXAnchor.constraint(
            equalTo: centerXAnchor).isActive = true
        textfield.widthAnchor.constraint(
            equalToConstant: 300).isActive = true
        textfield.heightAnchor.constraint(
            equalToConstant: 40).isActive = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
