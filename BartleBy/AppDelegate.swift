//
//  AppDelegate.swift
//  NoNameYet
//
//  Created by Andy Wong on 12/20/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import UserNotifications
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var blurView = UIVisualEffectView()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GADMobileAds.configure(withApplicationID: Helper.valueForKey(key: "GoogleADMobAppID"))
        Mixpanel.initialize(token: "7fefd65f0da68515af4a5ffb099eb1d8")
        
        if let userId = UserDefaults.standard.value(forKey: Constants.userId) as? String {
            FirebaseNetworkingService.updateLoginActivity(userId: userId)
        } else {
            FirebaseNetworkingService.signUpDefaultUser()
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        if let window = self.window {
            let main = AllTabBarViewController()
//            let emailVC = EmailLoginViewController()
            
            let navController: UIViewController = main

            window.rootViewController = navController
            window.makeKeyAndVisible()
        }
        
        AuthenticationManager.authenticateUser()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //If blurview doesn't exist and user allow authenticiation
        if !self.blurView.isDescendant(of: self.window!) && AuthenticationManager.userAllowsAuthentication {
            let blurEffect = UIBlurEffect(style: .light)
            self.blurView = UIVisualEffectView(effect: blurEffect)
            self.blurView.frame = (self.window?.bounds)!
            self.window?.addSubview(self.blurView)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        AuthenticationManager.authenticateUser()
        blurView.removeFromSuperview()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        blurView.removeFromSuperview()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "BartleBy")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

