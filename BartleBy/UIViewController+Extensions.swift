//
//  UIViewController+Extensions.swift
//  BartleBy
//
//  Created by Andy Wong on 12/28/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

extension UIViewController {
    func stockAlertMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func forgotPasswordAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Enter email"
        })
        
        alertController.addAction(UIAlertAction(title: "Send Email", style: .default, handler: { action in
            if let enteredEmail = alertController.textFields?.first?.text {
                FirebaseNetworkingService.forgotPassword(email: enteredEmail) { isSuccess in
                    if isSuccess {
                        self.stockAlertMessage(title: "Email Sent", message: "Your password reset email is on its way.")
                    } else {
                        self.stockAlertMessage(title: "Email Invalid", message: "Your email is not correct please try again.")
                    }
                    
                }
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func popVCAfterOK(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        }))
            
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alertMessage(title: String, message: String) {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.tag = 124
        
        let alertView = UIView()
        alertView.layer.cornerRadius = 10
        alertView.layer.borderColor = UIColor.lightGray.cgColor
        alertView.tag = 123
        alertView.backgroundColor = .alertWhite
        
        let titleLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.text = title
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
            return label
        }()
        
        let messageLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont(name: "HelveticaNeue-Light", size: 15)
            label.numberOfLines = 10
            label.text = message
            return label
        }()
        
        let okButton: UIButton = {
            let button = UIButton()
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
        titleLabel.snp.makeConstraints({ make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(20)
        })
        
        alertView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints({ make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        })
        
        alertView.addSubview(okButton)
        okButton.snp.makeConstraints({ make in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
        })

        self.view.addSubview(blurView)
        blurView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        
        self.view.addSubview(alertView)
        alertView.snp.makeConstraints({ make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.2)
            make.height.equalTo(300)
        })
    }
    
    @objc func exitAlert(sender: UIButton){
        self.view.viewWithTag(124)?.removeFromSuperview()
        self.view.viewWithTag(123)?.removeFromSuperview()
    }
    
    func cancelButton(title: String, color: UIColor) {
        let cancelButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.height-164, width: self.view.frame.width, height: 64))
        cancelButton.setTitle(title, for: .normal)
        cancelButton.backgroundColor = color
        cancelButton.addTarget(self, action: #selector(dismissNavVC), for: .touchUpInside)
        
        self.view.addSubview(cancelButton)
    }
    
    func scrollToTop() {
        func scrollToTop(view: UIView?) {
            guard let view = view else { return }
            
            switch view {
            case let scrollView as UIScrollView:
                if scrollView.scrollsToTop == true {
                    scrollView.setContentOffset(CGPoint(x: -scrollView.contentInset.left, y: -max(scrollView.contentInset.top, view.safeAreaInsets.top)), animated: true)
                    return
                }
            default:
                break
            }
            
            for subView in view.subviews {
                scrollToTop(view: subView)
            }
        }
        
        scrollToTop(view: self.view)
    }
    
    func scrollToTopNoNavBar() {
        //Don't cant about scrollview top of safe area top. Just set to 0.
        func scrollToTop(view: UIView?) {
            guard let view = view else { return }
            
            switch view {
            case let scrollView as UIScrollView:
                if scrollView.scrollsToTop == true {
                    scrollView.setContentOffset(CGPoint(x: -scrollView.contentInset.left, y: 0), animated: true)
                    return
                }
            default:
                break
            }
            
            for subView in view.subviews {
                scrollToTop(view: subView)
            }
        }
        
        scrollToTop(view: self.view)
    }
    
    @objc func dismissNavVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
//    @objc func dismissVC() {
//        self.dismiss(animated: true, completion: nil)
//    }
}
