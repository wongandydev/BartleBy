//
//  EmailLoginViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 6/21/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit
import Mixpanel

class EmailLoginViewController: UIViewController {
    
    //Register
    private var registerView: UIView!
    private var registerEmailTextField: UITextField!
    private var registerPasswordTextField: UITextField!
    private var registerButton: UIButton!
    private var toggleSignInButton: UIButton!
    
    //Login
    private var loginView: UIView!
    private var loginEmailTextField: UITextField!
    private var loginPasswordTextField: UITextField!
    private var signInButton: UIButton!
    private var forgotPasswordButtion: UIButton!
    private var toggleSignUpButton: UIButton!
    
    private var isSignUp: Bool = true {
        didSet {
            switchSignUpLogin()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubview()
        setTapGesture()
    }
    
    fileprivate func setTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(tapGesture)
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
        self.edgesForExtendedLayout = .init(rawValue: 0)
        
        registerView = UIView()
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
        
        registerButton = UIButton()
        registerButton.setTitle("Register", for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        registerButton.setTitleColor(.black, for: .normal)
        registerButton.setTitleColor(.white, for: .highlighted)
        registerButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        
        registerView.addSubview(registerButton)
        registerButton.snp.makeConstraints({ make in
            make.top.equalTo(registerPasswordTextField.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        })
        
        toggleSignInButton = UIButton()
        toggleSignInButton.setTitle("I have an account.", for: .normal)
        toggleSignInButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .light)
        toggleSignInButton.addTarget(self, action: #selector(toggleSignIn), for: .touchUpInside)
        toggleSignInButton.setTitleColor(.black, for: .normal)
        toggleSignInButton.setTitleColor(.white, for: .highlighted)
        
        registerView.addSubview(toggleSignInButton)
        toggleSignInButton.snp.makeConstraints({ make in
            make.bottom.equalToSuperview().offset(-30)
            make.centerX.equalToSuperview()
        })
        
        loginView = UIView()
        loginView.alpha = 0.0
        view.addSubview(loginView)
        loginView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        
        loginEmailTextField = UITextField()
        loginEmailTextField.backgroundColor = .white
        loginEmailTextField.borderStyle = .roundedRect
        loginEmailTextField.placeholder = "user@bartleby.com"
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
        
        let loginWelcomeMessaage = UILabel()
        loginWelcomeMessaage.numberOfLines = 0
        loginWelcomeMessaage.font = UIFont.systemFont(ofSize: 50, weight: .ultraLight)
        loginWelcomeMessaage.text = "Login"
        
        loginView.addSubview(loginWelcomeMessaage)
        loginWelcomeMessaage.snp.makeConstraints({ make in
            make.bottom.equalTo(registerEmailTextField.snp.top).offset(-20)
            make.centerX.equalToSuperview()
        })
        
        loginPasswordTextField = UITextField()
        loginPasswordTextField.backgroundColor = .white
        loginPasswordTextField.borderStyle = .roundedRect
        loginPasswordTextField.placeholder = "Password"
        loginPasswordTextField.keyboardType = .default
        loginPasswordTextField.keyboardAppearance = .dark
        loginPasswordTextField.textAlignment = .center
        loginPasswordTextField.autocapitalizationType = .none
        loginPasswordTextField.delegate = self
        loginPasswordTextField.font = UIFont.systemFont(ofSize: 17 * Constants.typeScale)
        
        loginView.addSubview(loginPasswordTextField)
        loginPasswordTextField.snp.makeConstraints({ make in
            make.height.equalTo(40)
            make.centerY.equalToSuperview().offset(25)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(40)
        })
        
        signInButton = UIButton()
        signInButton.setTitle("Sign in", for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        signInButton.setTitleColor(.black, for: .normal)
        signInButton.setTitleColor(.white, for: .highlighted)
        signInButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        
        loginView.addSubview(signInButton)
        signInButton.snp.makeConstraints({ make in
            make.top.equalTo(loginPasswordTextField.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        })
        
        toggleSignUpButton = UIButton()
        toggleSignUpButton.setTitle("I have an account.", for: .normal)
        toggleSignUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .light)
        toggleSignUpButton.addTarget(self, action: #selector(toggleSignIn), for: .touchUpInside)
        toggleSignUpButton.setTitleColor(.black, for: .normal)
        toggleSignUpButton.setTitleColor(.white, for: .highlighted)
        
        loginView.addSubview(toggleSignUpButton)
        toggleSignUpButton.snp.makeConstraints({ make in
            make.bottom.equalToSuperview().offset(-30)
            make.centerX.equalToSuperview()
        })
    }
    
    fileprivate func loginUser(email: String, password: String) {
        guard let userID = UserDefaults.standard.value(forKey: Constants.userId) as? String else {
            Mixpanel.mainInstance().track(event: "userEmailCreationFailed", properties: ["error": "Could not get userID from UserDefaults"])
            return
        }
        
        if !email.isValidEmail() {
            stockAlertMessage(title: "", message: "Your email is invalid. Please Try Again.")
        }
        
        if !password.isValidPassword() {
            stockAlertMessage(title: "Password Error", message: "Password has to be 8 characters or longer.")
        }
        
        if email.isValidEmail(), password.isValidPassword() {
            Spinner.start(view: self.view)
            FirebaseNetworkingService.loginUserWithEmail(email: email, password: password, { isCompleted in
                if isCompleted {
                    FirebaseNetworkingService.syncCurrentUserDataWithLoginUser(previousUserID: userID, currentFirebaseUID: FirebaseNetworkingService.getCurrentFirebaseUserUID(), { isCompleted in
                        if isCompleted {
                            UserDefaults.standard.set(true, forKey: Constants.userHasLoggedIn)
                            Spinner.stop()
                            self.popVCAfterOK(title: "Success", message: "\(email) is officially connected and all your notes are synced.")
                        } else {
                            Spinner.stop()
                            self.stockAlertMessage(title: "Sync Error", message: "Unable to sync data")
                        }
                    })
                } else {
                    Spinner.stop()
                    self.stockAlertMessage(title: "Login Error", message: "Login Credentials are invalid. Please Try Again.")
                }
            })
        }
    }
    
    fileprivate func signUpUser(email: String, password: String) {
        if !email.isValidEmail() {
            stockAlertMessage(title: "", message: "Your email is invalid. Please Try Again.")
        }
        
        if !password.isValidPassword() {
            stockAlertMessage(title: "Password Error", message: "Password has to be 8 characters or longer.")
        }
        
        if email.isValidEmail(), password.isValidPassword() {
            Spinner.start(view: self.view)
            FirebaseNetworkingService.signUpUserWithEmail(email: email, password: password, { isCompleted in
                if isCompleted {
                    UserDefaults.standard.set(true, forKey: Constants.userHasLoggedIn)
                    Spinner.stop()
                    self.popVCAfterOK(title: "Success", message: "Your account is created for \(email)")
                } else {
                    Spinner.stop()
                    self.stockAlertMessage(title: "Error", message: "Failed to signup user")
                }
            })
        }
    }
    
    @objc func toggleSignIn() {
        isSignUp = !isSignUp
    }
    
    @objc func tap() {
        registerEmailTextField.resignFirstResponder()
        registerPasswordTextField.resignFirstResponder()
        loginEmailTextField.resignFirstResponder()
        loginPasswordTextField.resignFirstResponder()
    }
    
    @objc func login() {
        if let email = loginEmailTextField.text,
            let password = loginPasswordTextField.text {
                loginUser(email: email, password: password)
        }
    }
    
    @objc func signUp() {
        if let email = registerEmailTextField.text,
            let password = registerPasswordTextField.text {
            signUpUser(email: email, password: password)
        }
    }

}

extension EmailLoginViewController: UITextFieldDelegate {
    
}
