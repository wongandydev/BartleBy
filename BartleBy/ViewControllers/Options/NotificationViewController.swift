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
    
    private let userNotificationCenter = UNUserNotificationCenter.current()
    private var currentNotificationSettingLabel: UILabel!
    private var changeNotifcationDatePicker: UIDatePicker!
    private var saveButton: UIButton!
    
    let notificationCenter = UNUserNotificationCenter.current()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavbar()
        layoutSubviews()
        
        userNotificationCenter.getNotificationSettings(completionHandler: { settings in
            guard let status = settings.authorizationStatus as? UNAuthorizationStatus else { return }
            switch status {
                case .authorized:
                    break
                case .notDetermined:
                    self.navigationController?.popViewController(animated: true)
                    break
                case .denied:
                    self.navigationController?.popViewController(animated: true)
                    break
                case .provisional:
                    break
            }
        })
        

        changeNotifcationDatePicker.datePickerMode = .time
        currentNotificationSettingLabel.text = "No Notification"
        
        if let currentNotification = UserDefaults.standard.object(forKey: "notificationSetting") as? String {
            changeNotifcationDatePicker.date = Helper.sharedInstance.stringToTime(time: currentNotification)
            currentNotificationSettingLabel.text = currentNotification
        }
    }
    
    fileprivate func setupNavbar() {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = Constants.applicationAccentColor
        self.navigationController?.navigationBar.barTintColor = Constants.lightestGray
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Remove Notification", style: .plain, target: self, action: #selector(resetBarButtonItemTapped(_:)))
    }
    
    fileprivate func layoutSubviews() {
        self.view.backgroundColor = .white
        
        currentNotificationSettingLabel = UILabel()
        currentNotificationSettingLabel.textAlignment = .center
        
        self.view.addSubview(currentNotificationSettingLabel)
        currentNotificationSettingLabel.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(40)
        })
        
        changeNotifcationDatePicker = UIDatePicker()
        
        self.view.addSubview(changeNotifcationDatePicker)
        changeNotifcationDatePicker.snp.makeConstraints({ make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
        })
        
        saveButton = UIButton()
        saveButton.backgroundColor = .green
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.black, for: .highlighted)
        saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
        
        self.view.addSubview(saveButton)
        saveButton.snp.makeConstraints({ make in
            make.width.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(Constants.bottomButtonHeight)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
        })
    }
    
    @objc func resetBarButtonItemTapped(_ sender: Any) {
        notificationCenter.removeAllPendingNotificationRequests()
        currentNotificationSettingLabel.text = "No Notifcation"
        UserDefaults.standard.removeObject(forKey: "notificationSetting")
        UserDefaults.standard.synchronize()
    }
    
    @objc func saveButtonTapped(_ sender: Any) {
        let content = UNMutableNotificationContent()
        
        content.title = "Another day of writing!"
        content.subtitle = "This is daily message"
        content.body = "Have a good day"
        content.sound = UNNotificationSound.default
        
        let setTime = Helper.sharedInstance.timeToString(date: changeNotifcationDatePicker.date)
        var date = DateComponents()
        date.hour = Int(setTime.components(separatedBy: ":")[0])
        date.minute = Int(setTime.components(separatedBy: ":")[1])
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.add(request)
        UserDefaults.standard.set(Helper.sharedInstance.convert24toAM(date: changeNotifcationDatePicker.date), forKey: "notificationSetting")
        currentNotificationSettingLabel.text = UserDefaults.standard.object(forKey: "notificationSetting") as? String
    }
    
    
    
}
