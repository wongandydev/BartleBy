//
//  String+Extensions.swift
//  BartleBy
//
//  Created by Andy Wong on 6/22/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import Foundation

extension String {
    func isValidPassword() -> Bool {
        return self.count >= 8
    }
    
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "\\A(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+(?:[A-Z]{2}|asia|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum|travel|edu)\\b)\\Z"
            , options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
        
        
    }
}
