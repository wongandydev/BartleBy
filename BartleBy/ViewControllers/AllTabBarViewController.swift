//
//  AllTabBarViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 6/20/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit

class AllTabBarViewController: UITabBarController {
    private var firstVC: UIViewController!
    private var secondVC: UIViewController!
    private var listOfTabBars: [UIViewController]!
    private var previousController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        firstVC = UINavigationController(rootViewController: NotesViewController())
        firstVC.tabBarItem = UITabBarItem(title: "Notes", image: UIImage(named: "notes"), selectedImage: UIImage(named: "notes-filled"))
        
        secondVC = UINavigationController(rootViewController: OptionViewController())
        secondVC.tabBarItem = UITabBarItem(title: "Options", image: UIImage(named: "option"), selectedImage: UIImage(named: "option-filled"))
        
        listOfTabBars = [firstVC, secondVC]
        
        viewControllers = listOfTabBars
        
        self.tabBar.isTranslucent = true
        self.tabBar.tintColor = Constants.applicationAccentColor
        self.tabBar.barTintColor = Constants.lightestGray
        self.tabBar.backgroundColor = .white
        self.tabBar.layer.borderWidth = 0.0
        self.tabBar.clipsToBounds = true
    }
    
    
}

extension AllTabBarViewController: UITabBarControllerDelegate {
//    // Called *after* a tab button is tapped
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Scroll to top only if already on selected tab

        if previousController == viewController {
            if let navVC = viewController as? UINavigationController {
                if let notesVC = navVC.viewControllers.first as? NotesViewController {
                    //At Home ViewController
                    if notesVC.notesTableView.visibleCells != nil && (notesVC.view.window != nil) {
                        //Make sure viewcontroller has cells and that there is a view.
                        notesVC.scrollToTop()
                    }
                } else if let optionVC = navVC.viewControllers.first as? OptionViewController {
                    if optionVC.isViewLoaded == true { //Check to make sure view is loaded
                        optionVC.scrollToTop()
                    }
                }
            }
        }

        previousController = viewController
    }
}
