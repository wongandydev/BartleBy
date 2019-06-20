//
//  Constants.swift
//  BartleBy
//
//  Created by Andy Wong on 5/8/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit

class Constants {
    static var inDevelopment = false
    static var googleAdMobBannerId = inDevelopment ? Helper.valueForKey(key: "GoogleADMobBannerTestID"): Helper.valueForKey(key: "GoogleADMobBannerID")
    
    static var applicationAccentColor   = UIColor(red: 225/225, green: 0/225, blue: 45/225, alpha: 1.0) /* #FF002D */
    static var lightestGray             = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)  /* #F4F4F4 */
}
