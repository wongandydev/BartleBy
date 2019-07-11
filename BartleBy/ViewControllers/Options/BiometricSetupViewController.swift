//
//  BiometricSetupViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 7/10/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit

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
    
    fileprivate func areYouSureAlert() {
        let alertController = UIAlertController(title: "Are you sure you want to turn off \(AuthenticationManager.getUserAvailableBiometricType())?", message: "Turning off \(AuthenticationManager.getUserAvailableBiometricType()) means your notes will be accessible once the app is opened.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "I'm Sure", style: .default, handler: { action in
            UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: Constants.allowAuthentication), forKey: Constants.allowAuthentication)
            self.toggleAuthSwitch.setOn(UserDefaults.standard.bool(forKey: Constants.allowAuthentication), animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "I changed my mind.", style: .cancel, handler: { action in
            self.toggleAuthSwitch.setOn(UserDefaults.standard.bool(forKey: Constants.allowAuthentication), animated: true)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func toggleAuth() {
        if UserDefaults.standard.bool(forKey: Constants.allowAuthentication) {
            toggleAuthSwitch.setOn(UserDefaults.standard.bool(forKey: Constants.allowAuthentication), animated: true)
            areYouSureAlert()
        } else {
            UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: Constants.allowAuthentication), forKey: Constants.allowAuthentication)
            toggleAuthSwitch.setOn(UserDefaults.standard.bool(forKey: Constants.allowAuthentication), animated: true)
        }
    }
}

