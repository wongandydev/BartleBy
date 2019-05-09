//
//  Constants.swift
//  BartleBy
//
//  Created by Andy Wong on 5/8/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import Foundation

class Constants {
    static var inDevelopment = false
    static var googleAdMobBannerId = inDevelopment ? Helper.valueForKey(key: "GoogleADMobBannerTestID"): Helper.valueForKey(key: "GoogleADMobBannerID")
}
