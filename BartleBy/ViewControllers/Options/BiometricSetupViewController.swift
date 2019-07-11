//
//  BiometricSetupViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 7/10/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit
import LocalAuthentication

class BiometricSetupViewController: UIViewController {
    var titleLabel: UILabel!
    var toggleAuthLabel: UILabel!
    var toggleAuthSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubviews()
    }
    
    fileprivate func layoutSubviews() {
        self.view.backgroundColor = .white
        
        let allStackView = UIStackView()
        allStackView.alignment = .center
        allStackView.axis = .vertical
        allStackView.spacing = 40
        
        self.view.addSubview(allStackView)
        allStackView.snp.makeConstraints({ make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().inset(20)
        })
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.text = "Secure your notes"
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .light)
        
        allStackView.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints({ make in
            make.width.equalToSuperview()
        })
        
        let firstRowStackView = UIStackView()
        firstRowStackView.alignment = .center
        firstRowStackView.axis = .horizontal
        firstRowStackView.spacing = 20
        
        allStackView.addArrangedSubview(firstRowStackView)
        firstRowStackView.snp.makeConstraints({ make in
            make.width.equalToSuperview()
        })
        
        toggleAuthLabel = UILabel()
        toggleAuthLabel.numberOfLines = 0
        toggleAuthLabel.textAlignment = .right
        toggleAuthLabel.text = "\(AuthenticationManager.getUserAvailableBiometricType())"
        toggleAuthLabel.font = UIFont.systemFont(ofSize: 20, weight: .light)
        
        
        firstRowStackView.addArrangedSubview(toggleAuthLabel)
 
        toggleAuthSwitch = UISwitch()
        toggleAuthSwitch.isOn = AuthenticationManager.userAllowsAuthentication
        toggleAuthSwitch.onTintColor = .applicationAccentColor
        toggleAuthSwitch.addTarget(self, action: #selector(toggleAuth), for: .touchUpInside)
        
        firstRowStackView.addArrangedSubview(toggleAuthSwitch)
    }
    
    @objc func toggleAuth() {
        UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: Constants.allowAuthentication), forKey: Constants.allowAuthentication)
    }
}

class BiometricViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubviews()
    }
    
    func showContent() {
        DispatchQueue.main.async {
            self.view.backgroundColor = .red
        }
    }
    
    fileprivate func layoutSubviews() {
        self.view.backgroundColor = .white
    }
}

class AuthenticationManager {
    static let userAllowsAuthentication = UserDefaults.standard.bool(forKey: Constants.allowAuthentication)
    
    static func getUserAvailableBiometricType() -> String {
        var context = LAContext()
        if #available(iOS 11, *) {
            let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch(context.biometryType) {
            case .none:
               return ""
            case .touchID:
                return "Touch ID"
            case .faceID:
                return "Face ID"

            }
        } else {
            return ""
        }
    }
    
    
    static func authenticateUser() {
        if userAllowsAuthentication {
            let bioVC = BiometricViewController()
            
            if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
                window.rootViewController?.present(bioVC, animated: true, completion: nil)
            }
            var context = LAContext()
            var error: NSError?
            
            context.localizedCancelTitle = "Cancel."
            
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                print("error; \(error)")
            }
            
            let reason = "Log in to access notes"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
                
                if success {
                    // Move to the main thread because a state update triggers UI changes.
                    
                    DispatchQueue.main.async {
                        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
                            window.rootViewController?.dismiss(animated: true, completion: { print("FaceID Completed | LaController dismissed")})
                        }
                    }
                } else {
                    print(error?.localizedDescription ?? "Failed to authenticate")
                    bioVC.showContent()
                }
            }
        }
    }
}
