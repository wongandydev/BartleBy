//
//  EmailLoginViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 6/21/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit
import Mixpanel
import FirebaseAnalytics

class EmailLoginViewController: UIViewController {
    
    //Register
//    private var registerView: UIView!
    private var welcomeMessage: UILabel!
    private var registerEmailTextField: UITextField!
    private var registerPasswordTextField: UITextField!
    private var registerButton: UIButton!
    private var toggleSignInButton: UIButton!
    private var forgotPasswordButtion: UIButton!
    private var toggleSecureTextButton: UIButton!
    
    private var keyboardHeight = CGFloat(0)
    private var defaultY = CGFloat(0)
    
    private var isSignUp: Bool = true {
        didSet {
            switchSignUpLogin()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubview()
        setupKeyboardNotification()
        setTapGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        remoteKeyboardNotification()
        Spinner.stop()
    }
    
    fileprivate func setupKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func remoteKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func setTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func switchSignUpLogin() {
        if isSignUp {
            registerButton.setTitle("Register", for: .normal)
            welcomeMessage.text = "Sign Up"
            forgotPasswordButtion.isHidden = true
        } else {
            registerButton.setTitle("Sign In", for: .normal)
            welcomeMessage.text = "Sign In"
            forgotPasswordButtion.isHidden = false
        }
    }
    
    fileprivate func layoutSubview() {
        self.view.backgroundColor = .white
        self.edgesForExtendedLayout = .init(rawValue: 0)
        defaultY = self.view.frame.origin.y
        
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
        
        self.view.addSubview(registerEmailTextField)
        registerEmailTextField.snp.makeConstraints({ make in
            make.height.equalTo(40)
            make.centerY.equalToSuperview().offset(-25)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(40)
        })
        
        welcomeMessage = UILabel()
        welcomeMessage.numberOfLines = 0
        welcomeMessage.font = UIFont.systemFont(ofSize: 50, weight: .ultraLight)
        welcomeMessage.text = "Sign Up"
        
        self.view.addSubview(welcomeMessage)
        welcomeMessage.snp.makeConstraints({ make in
            make.bottom.equalTo(registerEmailTextField.snp.top).offset(-20)
            make.centerX.equalToSuperview()
        })
        
        registerPasswordTextField = UITextField()
        registerPasswordTextField.backgroundColor = .white
        registerPasswordTextField.borderStyle = .roundedRect
        registerPasswordTextField.placeholder = "Password"
        registerPasswordTextField.keyboardType = .default
        registerPasswordTextField.isSecureTextEntry = true
        registerPasswordTextField.keyboardAppearance = .dark
        registerPasswordTextField.textAlignment = .center
        registerPasswordTextField.autocapitalizationType = .none
        registerPasswordTextField.delegate = self
        registerPasswordTextField.font = UIFont.systemFont(ofSize: 17 * Constants.typeScale)
        
        self.view.addSubview(registerPasswordTextField)
        registerPasswordTextField.snp.makeConstraints({ make in
            make.height.equalTo(40)
            make.centerY.equalToSuperview().offset(25)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(40)
        })
        
        toggleSecureTextButton = UIButton()
        toggleSecureTextButton.setImage(registerPasswordTextField.isSecureTextEntry ? UIImage(named: "secured") : UIImage(named: "unsecured"), for: .normal)
        toggleSecureTextButton.setTitleColor(.applicationAccentColor, for: .normal)
        toggleSecureTextButton.tintColor = .applicationAccentColor
        toggleSecureTextButton.addTarget(self, action: #selector(toggleSecureText), for: .touchUpInside)
        
        self.view.addSubview(toggleSecureTextButton)
        toggleSecureTextButton.snp.makeConstraints({ make in
            make.right.equalTo(registerPasswordTextField.snp.right).inset(10)
            make.top.equalTo(registerPasswordTextField.snp.top)
            make.bottom.equalTo(registerPasswordTextField.snp.bottom)
        })
        
        registerButton = UIButton()
        registerButton.setTitle("Register", for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        registerButton.setTitleColor(.black, for: .normal)
        registerButton.setTitleColor(.white, for: .highlighted)
        registerButton.addTarget(self, action: #selector(signUpSignIn), for: .touchUpInside)
        
        self.view.addSubview(registerButton)
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
        
        self.view.addSubview(toggleSignInButton)
        toggleSignInButton.snp.makeConstraints({ make in
            make.bottom.equalToSuperview().offset(-30)
            make.centerX.equalToSuperview()
        })
        
        forgotPasswordButtion = UIButton()
        forgotPasswordButtion.setTitle("Forgot Password.", for: .normal)
        forgotPasswordButtion.isHidden = true
        forgotPasswordButtion.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .light)
        forgotPasswordButtion.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        forgotPasswordButtion.setTitleColor(.black, for: .normal)
        forgotPasswordButtion.setTitleColor(.white, for: .highlighted)
        self.view.addSubview(forgotPasswordButtion)
        forgotPasswordButtion.snp.makeConstraints({ make in
            make.top.equalTo(registerButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        })
    }
    
    fileprivate func loginUser(email: String, password: String) {
        guard let userID = UserDefaults.standard.value(forKey: Constants.userId) as? String else {
            Analytics.logEvent("userEmailCreationFailed", parameters: ["error": "Could not get userID from UserDefaults"])
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
                            
                            FirebaseNetworkingService.postDataToFirebase(path:"users/\(userID)/depreciated", value: ["newUser": UserDefaults.standard.value(forKey: Constants.userId) ?? "", "email": email])
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
    
    fileprivate func forgotPassword() {
        forgotPasswordAlert(title: "Forgot Password?", message: "Enter your email below, we will send you a email to reset your password.")
    }
    
    @objc func toggleSignIn() {
        isSignUp = !isSignUp
    }
    
    @objc func tap() {
        registerEmailTextField.resignFirstResponder()
        registerPasswordTextField.resignFirstResponder()
    }
    
    @objc func toggleSecureText() {
        registerPasswordTextField.isSecureTextEntry = !registerPasswordTextField.isSecureTextEntry
        toggleSecureTextButton.setImage(registerPasswordTextField.isSecureTextEntry ? UIImage(named: "secured") : UIImage(named: "unsecured"), for: .normal)
    }
    
    @objc func forgotPasswordTapped() {
        forgotPassword()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // Get keyboard animation options
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            if (CGFloat(keyboardRectangle.height) > self.keyboardHeight) {
                self.keyboardHeight = keyboardRectangle.height // so UI doesn't wiggle between uitextfields
            }
            let keyboardAnimationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int
            let keyboardAnimationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]) as! Double
        }
        
        let screenMiddleY = self.view.frame.height/2
        let newMiddleY = (CGFloat(self.view.frame.height+Constants.topPadding+45)-CGFloat(self.keyboardHeight))/2
        let distance = screenMiddleY-newMiddleY
        
        UIView.animate(withDuration: TimeInterval(0.3), delay: 0.0 , animations: {
            self.defaultY = self.defaultY > 0 ? self.defaultY : self.view.frame.origin.y
            self.view.frame.origin.y = (self.defaultY+44)-distance
            
        }, completion: {(finished: Bool) in
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        UIView.animate(withDuration: TimeInterval(0.3), delay: 0.0, animations: {
            self.view.frame.origin.y = self.defaultY
        }, completion: {(finished: Bool) in
            
        })
    }
    
    @objc func signUpSignIn() {
        if let email = registerEmailTextField.text,
            let password = registerPasswordTextField.text {
            if isSignUp {
                signUpUser(email: email, password: password)
            } else {
                loginUser(email: email, password: password)
            }
        }
    }

}

extension EmailLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == registerEmailTextField {
            textField.resignFirstResponder()
            registerPasswordTextField.becomeFirstResponder()
        } else if textField == registerPasswordTextField {
            registerPasswordTextField.resignFirstResponder()
            signUpSignIn()
        }
        return false
    }
}
