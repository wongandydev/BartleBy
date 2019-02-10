//
//  UIViewController+Extensions.swift
//  BartleBy
//
//  Created by Andy Wong on 12/28/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

extension UIViewController {
    func alertMessage(title: String, message: String) {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurView.frame = self.view.frame
        blurView.tag = 124
        
        let alertView = UIView(frame: CGRect(x: 20, y: self.view.frame.height/3, width: self.view.frame.width/1.2, height: self.view.frame.height/4))
        alertView.center.x = view.center.x
        alertView.center.y = view.center.y
        alertView.layer.cornerRadius = 10
        alertView.layer.borderColor = UIColor.lightGray.cgColor
        alertView.tag = 123
        alertView.backgroundColor = .alertWhite
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let titleLabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 0, y: 10, width: alertView.frame.width, height: 20))
            label.textAlignment = .center
            label.text = title
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
            return label
        }()
        
        let messageLabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 0, y: titleLabel.center.y + 30, width: alertView.frame.width, height: 50))
            label.textAlignment = .center
            label.font = UIFont(name: "HelveticaNeue-Light", size: 15)
            label.numberOfLines = 5
            label.text = message
            return label
        }()
        
        let okButton: UIButton = {
            let button = UIButton(frame: CGRect(x: 0, y: alertView.frame.height - 50, width: alertView.frame.width, height: 50))
            button.setTitleColor(.black, for: .normal)
            button.setTitle("I got it", for: .normal)
            button.layer.cornerRadius = 10
            button.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            button.showsTouchWhenHighlighted = true
            let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: button.frame.width, height: 1))
            topBorder.backgroundColor = .lightGray
            button.addSubview(topBorder)
            return button
        }()
        
        okButton.addTarget(self, action: #selector(exitAlert(sender:)), for: .touchUpInside)
        
        alertView.addSubview(titleLabel)
        alertView.addSubview(messageLabel)
        alertView.addSubview(okButton)

        self.view.addSubview(blurView)
        self.view.addSubview(alertView)
    }
    
    @objc func exitAlert(sender: UIButton){
        self.view.viewWithTag(124)?.removeFromSuperview()
        self.view.viewWithTag(123)?.removeFromSuperview()
    }
    
    func cancelButton(title: String, color: UIColor) {
        let cancelButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.height-164, width: self.view.frame.width, height: 64))
        cancelButton.setTitle(title, for: .normal)
        cancelButton.backgroundColor = color
        cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        self.view.addSubview(cancelButton)
    }
    
    @objc func dismissVC() {
        self.navigationController?.popViewController(animated: true)
    }
}
