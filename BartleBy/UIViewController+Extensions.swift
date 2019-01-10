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
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            blurView.removeFromSuperview()
        }))
        
        self.view.addSubview(blurView)
        self.present(alertController, animated: true, completion: nil)
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
