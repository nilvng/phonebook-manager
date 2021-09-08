//
//  EditStackViewController.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/2/21.
//

import UIKit
import Foundation

class EditStackViewController: UIViewController {
    
    typealias FriendChangeAction = (Friend) -> Void
    private var isNew : Bool = false

    private var contact : Friend!
    var delegate : EditViewDelegate?
    var friendAddAction : FriendChangeAction?

    
    private let stackView : UIStackView = {
        let view = UIStackView()
        view.axis          = .vertical
        view.alignment     = .fill
        view.distribution  = .fill
        view.spacing       = 10
        return view

    }()
    private let scrollView : UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor  = .white
        view.layoutMargins    = .zero
        return view
    }()
    
    private var stackSubViews : [UITextField] = []
    
    public enum ContactDetail: Int, CaseIterable{
        case firstname
        case lastname
        case phonenumber
        
        func getView(for contact: Friend) -> UIView{
            switch self {
            case .firstname:
                return self.customTextField(text: contact.firstName, placeholder: "First name")
            case .lastname:
                return self.customTextField(text: contact.lastName, placeholder: "Last name")
            case .phonenumber:
                return self.customTextField(text: contact.phoneNumbers[0], placeholder: "Phone number")
            }
        }
        func customTextField(text: String, placeholder: String) -> UITextField{
            let textfield = UITextField()
            textfield.layer.cornerRadius                        = 5
            textfield.backgroundColor                           = .white
            textfield.isUserInteractionEnabled                  = true
            
            textfield.borderStyle = UITextField.BorderStyle.roundedRect
            var frameRect =  textfield.frame
            frameRect.size.height = 70
            textfield.frame = frameRect
            
            textfield.text = text
            textfield.placeholder = placeholder
            
            return textfield
        }
        func setValue(newValue: String, for contact: Friend){
            switch self {
            case .firstname:
                contact.firstName = newValue
            case .lastname:
                contact.lastName = newValue
            case .phonenumber:
                contact.phoneNumbers[0] = newValue
            }

        }
        
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(onSubmitChanges))
 

    }
    func configure(for friend: Friend, isNew: Bool = false, addAction: FriendChangeAction? = nil){
        self.contact = friend
        self.isNew = isNew
        self.friendAddAction = addAction
    }

    
    @objc func onSubmitChanges(){
        for i in 0..<stackSubViews.count {
            guard let detail = ContactDetail.init(rawValue: i),
                  let newValue =  stackSubViews[i].text else {continue}
            detail.setValue(newValue: newValue, for: self.contact)
        }
        if isNew {
            dismiss(animated: true){
                self.friendAddAction?(self.contact)
            }
            return
        }
        delegate?.changesSubmitted(item: self.contact)
        navigationController?.popViewController(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        setupScrollView()
        setupStackView()


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func setupScrollView(){
        scrollView.anchor(top: view.topAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor)
    }

    private func setupStackView(){
        stackView.anchor(top: scrollView.topAnchor,
                         left: scrollView.leftAnchor,
                         bottom: scrollView.bottomAnchor,
                         right: scrollView.rightAnchor,
                         padding: .init(top: 10, left: 0, bottom: 0, right: 0))
        
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        configureStack()
    }
    
    private func configureStack(){
        guard let c = contact else {
            return
        }
        for field in ContactDetail.allCases{
            let fview = field.getView(for: c)
            stackSubViews.append(fview as! UITextField)
            stackView.addArrangedSubview(fview)

        }
        
    }
    
    
    
}
