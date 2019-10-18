//
//  CustomNavigationController.swift
//  BartleBy
//
//  Created by Andy Wong on 10/18/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = Constants.applicationAccentColor
        self.navigationController?.navigationBar.barTintColor = .backgroundColor
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}
