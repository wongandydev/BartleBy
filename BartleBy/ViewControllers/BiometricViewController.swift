//
//  BiometricViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 7/10/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit

class BiometricViewController: UIViewController {
    var retryButton: UIButton!
    var retryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubviews()
    }
    
    func showContent() {
        DispatchQueue.main.async {
            self.retryButton.isHidden = false
            self.retryLabel.isHidden = false
        }
    }
    
    fileprivate func layoutSubviews() {
        self.view.backgroundColor = .white
        
        retryButton = UIButton()
        retryButton.setTitle("Retry Face ID", for: .normal)
        retryButton.backgroundColor = .lighterGray
        retryButton.backgroundColor?.withAlphaComponent(0.7)
        retryButton.setTitleColor(.gray, for: .normal)
        retryButton.setTitleColor(.lighterGray, for: .highlighted)
        retryButton.layer.borderWidth = 0
        retryButton.layer.cornerRadius = 10
        retryButton.isHidden = true
        retryButton.addTarget(self, action: #selector(retryFaceID), for: .touchUpInside)
        
        self.view.addSubview(retryButton)
        retryButton.snp.makeConstraints({ make in
            make.center.equalToSuperview()
            make.width.equalTo(180)
            make.height.equalTo(50)
        })
        
        retryLabel = UILabel()
        retryLabel.text = "Retry \(AuthenticationManager.getUserAvailableBiometricType())"
        retryLabel.font = UIFont.systemFont(ofSize: 40, weight: .light)
        retryLabel.isHidden = true
        retryLabel.textColor = .gray
        retryLabel.numberOfLines = 0
        
        self.view.addSubview(retryLabel)
        retryLabel.snp.makeConstraints({ make in
            make.centerX.equalTo(retryButton)
            make.bottom.equalTo(retryButton.snp.top).offset(-30)
        })
        
    }
    
    @objc func retryFaceID() {
        AuthenticationManager.authenticateUser()
    }
}
