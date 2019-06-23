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
    private var userID: String!
    private var titleLabel: UILabel!
    private var totalDaysLabel: UILabel!
    private var totalDaysTextLabel: UILabel!
    private var totalNotesLabel: UILabel!
    private var totalNotesTextLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getStats()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        if let userId =  UserDefaults.standard.string(forKey: Constants.userId) as? String {
            self.userID = userId
        }
        layoutSubviews()
    }
    
    fileprivate func layoutSubviews() {
        self.view.backgroundColor = .white
        
        let fullStackView = UIStackView()
        fullStackView.alignment = .center
        fullStackView.axis = .vertical
        fullStackView.spacing = 20
        
        self.view.addSubview(fullStackView)
        fullStackView.snp.makeConstraints({ make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
        })
    
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.text = "You have written... "
        titleLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        
        fullStackView.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints({ make in
            make.width.equalTo(self.view)
        })
        
        let firstHorizontalStackView = UIStackView()
        firstHorizontalStackView.alignment = .center
        firstHorizontalStackView.axis = .horizontal
        firstHorizontalStackView.spacing = 15
        
        fullStackView.addArrangedSubview(firstHorizontalStackView)
        firstHorizontalStackView.snp.makeConstraints({ make in
//            make.width.equalTo(self.view)
        })
        
        totalDaysLabel = UILabel()
        totalDaysLabel.font = UIFont.systemFont(ofSize: 50, weight: .semibold)
        
        firstHorizontalStackView.addArrangedSubview(totalDaysLabel)
        totalDaysLabel.snp.makeConstraints({ make in
            
        })
        
        totalDaysTextLabel = UILabel()
        totalDaysTextLabel.font = UIFont.systemFont(ofSize: 17, weight: .light)
        
        firstHorizontalStackView.addArrangedSubview(totalDaysTextLabel)
        totalDaysTextLabel.snp.makeConstraints({ make in
            
        })
        
        let secondHorizontalStackView = UIStackView()
        secondHorizontalStackView.alignment = .center
        secondHorizontalStackView.axis = .horizontal
        secondHorizontalStackView.spacing = 15
        
        fullStackView.addArrangedSubview(secondHorizontalStackView)
        secondHorizontalStackView.snp.makeConstraints({ make in
//            make.width.equalTo(self.view)
        })
        
        totalNotesLabel = UILabel()
        totalNotesLabel.font = UIFont.systemFont(ofSize: 50, weight: .semibold)
        
        
        secondHorizontalStackView.addArrangedSubview(totalNotesLabel)
        totalNotesLabel.snp.makeConstraints({ make in
            
        })
        
        totalNotesTextLabel = UILabel()
        totalNotesTextLabel.font = UIFont.systemFont(ofSize: 17, weight: .light)
        
        secondHorizontalStackView.addArrangedSubview(totalNotesTextLabel)
        totalNotesTextLabel.snp.makeConstraints({ make in
            
        })
    }
    
    func offlineStats() {
        if let totalDays = UserDefaults.standard.value(forKey: "stat_streak") as? Int,
            let totalNotes = UserDefaults.standard.value(forKey: "stat_totalNotes") as? Int {
            self.totalDaysLabel.text = String(totalDays)
            self.totalNotesLabel.text = String(totalNotes)
            
            if totalDays > 1 {
                self.totalDaysTextLabel.text = "days in a row"
            } else {
                self.totalDaysTextLabel.text = "day in a row"
            }
            
            if totalNotes > 1 {
                self.totalNotesTextLabel.text = "notes in total"
            } else {
                self.totalNotesTextLabel.text = "note in total"
            }
        }
    }
    
    func getStats() {
        if let userId = userID {
            ref.child("users/\(userID!)/stats").observeSingleEvent(of: .value , with: { snapshot in
                if let stat = snapshot.value as? [String: Int] {
                    if let streak = stat["streak"] as? Int {
                        if let totalNotes = stat["totalNotes"] as? Int {
                            self.totalDaysLabel.text = String(streak)
                            UserDefaults.standard.set(streak, forKey: "stat_streak")
                            self.totalNotesLabel.text = String(totalNotes)
                            UserDefaults.standard.set(totalNotes, forKey: "stat_totalNotes")
                            
                            if streak > 1 {
                                self.totalDaysTextLabel.text = "days in a row"
                            } else {
                                self.totalDaysTextLabel.text = "day in a row"
                            }
                            
                            if totalNotes > 1 {
                                self.totalNotesTextLabel.text = "notes in total"
                            } else {
                                self.totalNotesTextLabel.text = "note in total"
                            }
                        }
                    }
                }
            })
        }
        offlineStats()
    }
}
