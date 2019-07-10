//
//  Constants.swift
//  BartleBy
//
//  Created by Andy Wong on 5/8/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit

class Constants {
    static let inDevelopment = false //PRODUCTION!!! Set to false when shipping 
    static var googleAdMobBannerId      = inDevelopment ? Helper.valueForKey(key: "GoogleADMobBannerTestID") : Helper.valueForKey(key: "GoogleADMobBannerID")
    
    static let applicationAccentColor   = UIColor(red: 225/225, green: 0/225, blue: 45/225, alpha: 1.0) /* #FF002D */
    static let lightestGray             = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)  /* #F4F4F4 */
    static let snowWhite                = UIColor(red: 255/255, green: 250/255, blue: 250/255, alpha: 1.0)  /* #FFFAFA */
    
    static let topPadding               = CGFloat(UIApplication.shared.windows[0].safeAreaInsets.top)
    static var bottomPadding            = CGFloat(UIApplication.shared.windows[0].safeAreaInsets.bottom)
    static let tabBarHeight             = CGFloat(49.0)
    
    static let screenWidth = UIScreen.main.bounds.width
    
    static let typeScale: CGFloat = {
        if screenWidth < 375.0  { return 320.0/375.0 }     // iPhone 5/5S/5SE
        if screenWidth >= 414.0 { return 414.0/375.0 }     // iPhone 6+/7+/8+, XR, Xs Max
        return 1.0                                         // iPhone X/Xs
    }()
    
    static let bottomButtonHeight       = 60
    
    static let userId                   = "userId"
    static let userHasLoggedIn          = "userHasLoggedIn"
    static let isFirstLaunch            = "isFirstLaunch"
}
