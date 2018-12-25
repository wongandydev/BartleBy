//
//  Helper.swift
//  FirebaseCore
//
//  Created by Andy Wong on 12/23/18.
//

import Foundation
import UIKit

class Helper {
    static let sharedInstance = Helper()
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy' 'hh:mm:ss a"
        dateFormatter.timeZone = NSTimeZone.system
        
        return dateFormatter.string(from: Date()) ?? "Did not get date"
    }
    
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy' 'hh:mm:ss a"
        dateFormatter.timeZone = NSTimeZone.system
        
        return dateFormatter.string(from: date)
    }
}
