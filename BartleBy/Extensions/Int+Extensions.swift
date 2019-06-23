//
//  Int+Extensions.swift
//  BartleBy
//
//  Created by Andy Wong on 6/22/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import Foundation

extension Int {
    func currentTimestamp() -> Int {
        return Int(Date().timeIntervalSince1970)
    }
}
