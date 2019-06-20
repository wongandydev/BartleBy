//
//  Constants.swift
//  BartleBy
//
//  Created by Andy Wong on 5/8/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit

class Constants {
    static let inDevelopment = false
    static var googleAdMobBannerId      = inDevelopment ? Helper.valueForKey(key: "GoogleADMobBannerTestID"): Helper.valueForKey(key: "GoogleADMobBannerID")
    
    static let applicationAccentColor   = UIColor(red: 225/225, green: 0/225, blue: 45/225, alpha: 1.0) /* #FF002D */
    static let lightestGray             = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)  /* #F4F4F4 */
    
    static let topPadding               = CGFloat(UIApplication.shared.windows[0].safeAreaInsets.top)
    static var bottomPadding            = CGFloat(UIApplication.shared.windows[0].safeAreaInsets.bottom)
    static let tabBarHeight             = CGFloat(49.0)
    
    static let bottomButtonHeight       = 60
}
