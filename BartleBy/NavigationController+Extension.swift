//
//  NavigationController+Extension.swift
//  BartleBy
//
//  Created by Andy Wong on 12/29/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

extension UINavigationController {
    func transparentNavBar() {
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
    }
}
