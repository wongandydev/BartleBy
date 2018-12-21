//
//  SignupSetupViewController.swift
//  NoNameYet
//
//  Created by Andy Wong on 12/21/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import Foundation
import UIKit

class SignupSetupViewController: UIViewController {
    @IBAction func buttonTapped(_ sender: Any) {
        let loggedInStoryBoard = UIStoryboard(name: "LoggedIn", bundle: nil)
        if let tabbar = loggedInStoryBoard.instantiateViewController(withIdentifier: "LoggedInTabBarController") as? UITabBarController {
            self.present(tabbar, animated: true, completion: nil)
        }
    }
    
}
