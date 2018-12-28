//
//  HelpViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 12/26/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton()
    }
    
    func cancelButton() {
        let cancelButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.height-94, width: self.view.frame.width, height: 64))
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = .red
        cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        self.view.addSubview(cancelButton)
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
