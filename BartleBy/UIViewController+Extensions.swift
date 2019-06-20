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
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.frame = self.view.frame
        blurView.tag = 124
        
        let alertView = UIView(frame: CGRect(x: 20, y: self.view.frame.height/3, width: self.view.frame.width/1.2, height: 300))
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
            let label = UILabel(frame: CGRect(x: 10, y: titleLabel.center.y + 30, width: alertView.frame.width-20, height: 170))
            label.textAlignment = .center
            label.font = UIFont(name: "HelveticaNeue-Light", size: 15)
            label.numberOfLines = 10
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
