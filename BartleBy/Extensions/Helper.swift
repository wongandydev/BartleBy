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
        
        return dateFormatter.string(from: Date()) 
    }
    
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy' 'hh:mm:ss a"
        dateFormatter.timeZone = NSTimeZone.system
        
        return dateFormatter.string(from: date)
    }
    
    func stringToDate(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy'"
        dateFormatter.timeZone = NSTimeZone.system
        
        return dateFormatter.date(from: date) ?? Date()
    }
    
    func stringToTime(time: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = NSTimeZone.system
        
        return dateFormatter.date(from: time) ?? Date()
    }
    
    func timeToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: date)
    }
    
    func convert24toAM(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.string(from: date)
    }
    
    static func valueForKey(key: String) -> String {
        var returnValue: String = ""
        
        if let filePath = Bundle.main.path(forResource: "keys", ofType: "plist") as? String,
            let plist = NSDictionary(contentsOfFile: filePath),
            let value = plist.object(forKey: key) as? String {
                returnValue = value
        }
        
        return returnValue
    }
}
