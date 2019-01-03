//
//  NotificationViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 12/25/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var currentNotificationSettingLabel: UILabel!
    @IBOutlet weak var changeNotifcationDatePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let content = UNMutableNotificationContent()

        content.title = "Another day of writing!"
        content.subtitle = "This is daily message"
        content.body = "Have a good day"
        content.sound = UNNotificationSound.default

        let setTime = Helper.sharedInstance.convertAMto24(date: changeNotifcationDatePicker.date)
        var date = DateComponents()
        date.hour = Int(setTime.components(separatedBy: ":")[0])
        date.minute = Int(setTime.components(separatedBy: ":")[1])

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.add(request)
        UserDefaults.standard.set(Helper.sharedInstance.convert24toAM(date: changeNotifcationDatePicker.date), forKey: "notificationSetting")
        currentNotificationSettingLabel.text = UserDefaults.standard.object(forKey: "notificationSetting") as? String
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        changeNotifcationDatePicker.datePickerMode = .time
        
        if let currentNotification = UserDefaults.standard.object(forKey: "notificationSetting") {
            changeNotifcationDatePicker.date = Helper.sharedInstance.stringToTime(time: currentNotification as! String)
            
        }
        
        currentNotificationSettingLabel.text = UserDefaults.standard.object(forKey: "notificationSetting") == nil ? "No Notification": UserDefaults.standard.object(forKey: "notificationSetting") as! String
        
    }
}
