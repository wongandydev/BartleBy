//
//  IntroNotificationViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 7/17/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit

class IntroNotificationViewController: UIViewController {
    var verticalSpacing: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubviews()
    }
    
    fileprivate func layoutSubviews() {
        self.view.backgroundColor = .white
        
        let dimissButton = UIButton()
        dimissButton.setImage(UIImage(named: "dismiss"), for: .normal)
        dimissButton.tintColor = .applicationAccentColor
        dimissButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        self.view.addSubview(dimissButton)
        dimissButton.snp.makeConstraints({ make in
            make.top.equalToSuperview().offset(50)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(33)
        })
        
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .gray
        descriptionLabel.font = UIFont.systemFont(ofSize: 20, weight: .light)
        descriptionLabel.textAlignment = .natural
        descriptionLabel.text = "Turn on notifications to get daily reminders at the time of your choice to write. We only send notifications that you set. We may occasionally send reminders to update the app, but aside from that, we do not send notifications you do not know about."
        
        self.view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints({ make in
            make.width.equalToSuperview().inset(20)
            make.center.equalToSuperview()
        })
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .gray
        titleLabel.font = UIFont.systemFont(ofSize: 40, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.text = "Turn Notifications On."
        
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints({ make in
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-verticalSpacing)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20)
        })
        

        
        let turnOnNotificationButton = UIButton()
        turnOnNotificationButton.setTitle("Turn Notifications ON", for: .normal)
        turnOnNotificationButton.setTitleColor(.applicationAccentColor, for: .normal)
        turnOnNotificationButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        turnOnNotificationButton.layer.cornerRadius = 8
        turnOnNotificationButton.layer.borderWidth = 0.2
        turnOnNotificationButton.layer.borderColor = UIColor.darkGray.cgColor
        turnOnNotificationButton.backgroundColor = .alertWhite
        turnOnNotificationButton.addTarget(self, action: #selector(setNotification), for: .touchUpInside)
        
        self.view.addSubview(turnOnNotificationButton)
        turnOnNotificationButton.snp.makeConstraints({ make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(verticalSpacing)
            make.width.equalTo(220)
            make.centerX.equalToSuperview()
        })
    }
    
    @objc func setNotification() {
        BartleByNotificationCenter.stockAskForNotificationPermission { granted in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
