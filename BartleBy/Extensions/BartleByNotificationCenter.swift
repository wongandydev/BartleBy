//
//  File.swift
//  BartleBy
//
//  Created by Andy Wong on 6/23/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit
import UserNotifications

class BartleByNotificationCenter {
    static let userNotificationCenter = UNUserNotificationCenter.current()
    
    static func getUserAuthorizationStatus(_ completion: @escaping (_ status: UNAuthorizationStatus) -> Void){
        userNotificationCenter.getNotificationSettings(completionHandler: { settings in
            guard let status = settings.authorizationStatus as? UNAuthorizationStatus else {
                completion(.notDetermined)
                return
            }
           
            completion(status)
        })
    }
    
    static func stockAskForNotificationPermission() {
        self.userNotificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            
        }
    }
}
