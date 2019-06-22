//
//  EmailLoginViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 6/21/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit

class EmailLoginViewController: UIViewController {
    
    //Register
    private var registerView: UIView!
    private var registerEmailTextField: UITextField!
    private var registerPasswordTextField: UITextField!
    private var registerButton: UIButton!
    
    //Login
    private var loginView: UIView!
    private var loginEmailTextField: UITextField!
    private var loginPasswordTextField: UITextField!
    private var signInButton: UIButton!
    private var forgotPasswordButtion: UIButton!
    
    private var isSignUp: Bool = true {
        didSet {
            switchSignUpLogin()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubview()
    }
    
    fileprivate func switchSignUpLogin() {
        if isSignUp {
            loginView.alpha = 0.0
            registerView.alpha = 1.0
        } else {
            loginView.alpha = 1.0
            registerView.alpha = 0.0
        }
    }
    
    fileprivate func layoutSubview() {
        self.view.backgroundColor = .white
        
        registerView = UIView()
        registerView.backgroundColor = .red
        view.addSubview(registerView)
        registerView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        
        
        
        registerEmailTextField = UITextField()
        registerEmailTextField.backgroundColor = .white
        registerEmailTextField.borderStyle = .roundedRect
        registerEmailTextField.placeholder = "user@bartleby.com"
        registerEmailTextField.keyboardType = .emailAddress
        registerEmailTextField.keyboardAppearance = .dark
        registerEmailTextField.textAlignment = .center
        registerEmailTextField.autocapitalizationType = .none
        registerEmailTextField.delegate = self
        registerEmailTextField.font = UIFont.systemFont(ofSize: 17 * Constants.typeScale)
        
        
        registerView.addSubview(registerEmailTextField)
        registerEmailTextField.snp.makeConstraints({ make in
            make.height.equalTo(40)
            make.centerY.equalToSuperview().offset(-25)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(40)
        })
        
        let welcomeMessage = UILabel()
        welcomeMessage.numberOfLines = 0
        welcomeMessage.font = UIFont.systemFont(ofSize: 50, weight: .ultraLight)
        welcomeMessage.text = "Sign Up"
        
        registerView.addSubview(welcomeMessage)
        welcomeMessage.snp.makeConstraints({ make in
            make.bottom.equalTo(registerEmailTextField.snp.top).offset(-20)
            make.centerX.equalToSuperview()
        })
        
        registerPasswordTextField = UITextField()
        registerPasswordTextField.backgroundColor = .white
        registerPasswordTextField.borderStyle = .roundedRect
        registerPasswordTextField.placeholder = "Password"
        registerPasswordTextField.keyboardType = .default
        registerPasswordTextField.keyboardAppearance = .dark
        registerPasswordTextField.textAlignment = .center
        registerPasswordTextField.autocapitalizationType = .none
        registerPasswordTextField.delegate = self
        registerPasswordTextField.font = UIFont.systemFont(ofSize: 17 * Constants.typeScale)
        
        registerView.addSubview(registerPasswordTextField)
        registerPasswordTextField.snp.makeConstraints({ make in
            make.height.equalTo(40)
            make.centerY.equalToSuperview().offset(25)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(40)
        })
        
        loginView = UIView()
        loginView.alpha = 0.0
        loginView.backgroundColor = .green
        view.addSubview(loginView)
        loginView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        
        loginEmailTextField = UITextField()
        loginEmailTextField.backgroundColor = .white
        loginEmailTextField.borderStyle = .roundedRect
        loginEmailTextField.placeholder = "Email"
        loginEmailTextField.keyboardType = .emailAddress
        loginEmailTextField.keyboardAppearance = .dark
        loginEmailTextField.textAlignment = .center
        loginEmailTextField.autocapitalizationType = .none
        loginEmailTextField.delegate = self
        loginEmailTextField.font = UIFont.systemFont(ofSize: 17 * Constants.typeScale)
        
        
        loginView.addSubview(loginEmailTextField)
        loginEmailTextField.snp.makeConstraints({ make in
            make.height.equalTo(40)
            make.centerY.equalToSuperview().offset(-25)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(40)
        })
    }

}

extension EmailLoginViewController: UITextFieldDelegate {
    
}
