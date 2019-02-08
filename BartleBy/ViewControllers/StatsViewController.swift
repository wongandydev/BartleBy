//
//  StatsViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 12/28/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit
import Firebase

class StatsViewController: UIViewController {
    var ref: DatabaseReference!
    private let userUID = UIDevice.current.identifierForVendor?.uuidString
    @IBOutlet weak var streakNumberLabel: UILabel!
    @IBOutlet weak var totalNumberLabel: UILabel!
    @IBOutlet weak var totalNotesLabel: UILabel!
    @IBOutlet weak var totalDaysLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        getStats()
        
//        cancelButton(title: "Go Back", color: .red)
    }
    
    func getStats() {
        ref.child("users/\(userUID!)/stats").observeSingleEvent(of: .value , with: { snapshot in
            if let stat = snapshot.value as? [String: Int] {
                if let streak = stat["streak"] as? Int {
                    if let totalNotes = stat["totalNotes"] as? Int {
                        self.streakNumberLabel.text = String(streak)
                        self.totalNumberLabel.text = String(totalNotes)
                        
                        if streak > 1 {
                            self.totalDaysLabel.text = "days in a row"
                        } else {
                            self.totalDaysLabel.text = "day in a row"
                        }
                        
                        if totalNotes > 1 {
                            self.totalNotesLabel.text = "notes in total"
                        } else {
                            self.totalNotesLabel.text = "note in total"
                        }
                    }
                }
            }
        })
    }
}
