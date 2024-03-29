//
//  SecurityCodeView.swift
//  Event Scanner
//
//  Created by Ateeth Sai Kosuri on 8/22/19.
//  Copyright © 2019 American Express. All rights reserved.
//

import UIKit
import EasyPeasy

class SecurityCodeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK:- View Setup
    
    private func setupView() {
        self.addSubview(signInButton)
        self.addSubview(headerLabel)
        self.addSubview(emailField)
        self.addSubview(emailDivider)
//        self.addSubview(passwordField)
//        self.addSubview(passwordDivider)
        signInButton.easy.layout([Height(50), Bottom(25).to(self, .bottom), Left(30).to(self, .left), Right(30).to(self, .right)])
        headerLabel.easy.layout([Top(30).to(self, .top), Left(30).to(self, .left), Right(30).to(self, .right)])
        emailField.easy.layout([Top(30).to(headerLabel, .bottom), Left(30).to(self, .left), Right(30).to(self, .right)])
        emailDivider.easy.layout([Height(2.5), Top(12).to(emailField, .bottom), Left(30).to(self, .left), Right(30).to(self, .right)])
//        passwordField.easy.layout([Top(50).to(emailDivider, .top), Left(30).to(self, .left), Right(30).to(self, .right)])
//        passwordDivider.easy.layout([Height(2.5), Top(12).to(passwordField, .bottom), Left(30).to(self, .left), Right(30).to(self, .right)])
    }
    
    // MARK:- View Elements
    
    lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Verify", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = primaryBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)
        button.tag = 3
        button.layer.cornerRadius = 5.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter the verification code sent to your email here."
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        label.textColor = darkGrayText
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var emailField: UITextField = {
        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString(string: "Code",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1.0)])
        field.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.medium)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = UITextAutocorrectionType.no
        return field
    }()
    
    var emailDivider: UIView = {
        let view = UIView()
        view.backgroundColor = lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

}
