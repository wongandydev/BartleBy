//
//  ViewController.swift
//  NoNameYet
//
//  Created by Andy Wong on 12/20/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds
import SnapKit
import Mixpanel

class NotesViewController: UIViewController {
    
    var notesTableView: UITableView!
    private var bannerAdView: GADBannerView!
    
    private let refreshControl = UIRefreshControl()
    
    var ref: DatabaseReference!
    
    var notes: [Note] = [] {
        didSet {
            notes.sort(by: { (note1, note2) in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy' 'hh:mm:ss a"
                dateFormatter.timeZone = NSTimeZone.system

                return dateFormatter.date(from: note1.dateCreated)! > dateFormatter.date(from: note2.dateCreated)!
            })
            self.notesTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        setupNavbar()
        layoutSubviews()
    }
    
    fileprivate func registerCells() {
        notesTableView.register(NoteCell.self, forCellReuseIdentifier: "noteCell")
    }
    
    fileprivate func setupNavbar() {
        self.navigationItem.title = "BartleBy"
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = Constants.applicationAccentColor
        self.navigationController?.navigationBar.barTintColor = Constants.lightestGray
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    fileprivate func setupTableView() {
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesTableView.tableFooterView = UIView()
        registerCells()
    }
    
    fileprivate func layoutSubviews() {
        self.edgesForExtendedLayout = .init(rawValue: 0)
        
        notesTableView = UITableView()
        notesTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        setupTableView()
        //Add Pull to refresh
        if #available(iOS 10.0, *) {
            notesTableView.refreshControl = refreshControl
        } else {
            notesTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshNoteData), for: .valueChanged)
        
        
        self.view.addSubview(notesTableView)
        notesTableView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        
        bannerAdView = GADBannerView()
        bannerAdView.backgroundColor = .black
        setupBannerAd()
        
        self.view.addSubview(bannerAdView)
        bannerAdView.snp.makeConstraints({ make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(320)
            make.height.equalTo(50)
        })
        
        let addButton = UIButton()
        addButton.layer.cornerRadius = 30
        addButton.backgroundColor = .red
        addButton.setImage(UIImage(named: "plus"), for: .normal)
        addButton.tintColor = .white
        addButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        addButton.addTarget(self, action: #selector(addNote), for: .touchUpInside)
        
        self.view.addSubview(addButton)
        addButton.snp.makeConstraints({ make in
            make.right.bottom.equalToSuperview().inset(20)
            make.width.height.equalTo(60)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        readNotes()
    }
    
    func setupBannerAd() {
        self.bannerAdView.adUnitID = Constants.googleAdMobBannerId 
        self.bannerAdView.rootViewController = self;
        let request = GADRequest()
        bannerAdView.load(request)
    }
    
    func setStats() {
        let totalNotes = notes.count
        let today = Helper.sharedInstance.stringToDate(date: Helper.sharedInstance.getCurrentDate().components(separatedBy: " ")[0])
        let latestNote = totalNotes > 1 ? Helper.sharedInstance.stringToDate(date: self.notes[0].dateCreated.components(separatedBy: " ")[0]): Date()
        var currentStreak = 0

        if totalNotes > 1 {
            let diffFromTodayToLastNote: Int = Calendar.current.dateComponents([.day], from: today, to: latestNote).day ?? 0
            //If the difference between today and latest note is more than 0; set as 0
            if diffFromTodayToLastNote < 0 {
                currentStreak = 0
            } else {
                //Include today
                currentStreak += 1
                for noteIndex in 0...totalNotes - 2{
                    let firstDate = Helper.sharedInstance.stringToDate(date: self.notes[noteIndex].dateCreated.components(separatedBy: " ")[0])
                    let secondDate = Helper.sharedInstance.stringToDate(date: self.notes[noteIndex + 1].dateCreated.components(separatedBy: " ")[0])
                    
                    let difference = Calendar.current.dateComponents([.day], from: firstDate, to: secondDate).day ?? 0
                    //If the diffference is today or greater than one don't do anything
                    if  difference < -1 || difference == 0 {
                        //Do not count
                    } else {
                        currentStreak += 1
                    }
                }
            }
        } else {
            if Calendar.current.dateComponents([.day], from: today, to: latestNote).day ?? 0 < -1 || totalNotes == 0{
                currentStreak = 0
            } else {
                currentStreak = abs(Calendar.current.dateComponents([.day], from: today, to: latestNote).day ?? 0) + 1
            }
            
        }
        
        if let userID = UserDefaults.standard.value(forKey: Constants.userId) as? String {
            self.ref.child("users/\(userID)/stats").setValue(["streak": currentStreak, "totalNotes": totalNotes])
        }
    }
    
    func readNotes() {
        if let userID = UserDefaults.standard.value(forKey: Constants.userId) as? String {
            ref.child("users/\(userID)").observeSingleEvent(of: .value , with: { snapshot in
                self.notes.removeAll()
                if let userData = snapshot.value as? [String: AnyObject]{
                    if let notes = userData["notes"] as? [String: AnyObject]{
                        for note in notes {
                            if let value = note.value as? [String: AnyObject],
                                let answerNote = value["note"] as? String,
                                let dateCreated = value["dateCreated"] as? String,
                                let templateType = value["templateType"] as? String{
                                self.notes.append(Note(note: answerNote, dateCreated: dateCreated, id: note.key, templateType: templateType))
                            }
                        }
                        
                    }
                }
                self.setStats()
            })
        }
    }

    
    @objc func addNote() {
        if notes == [] || notes[0].dateCreated.components(separatedBy: " ")[0] != Helper.sharedInstance.getCurrentDate().components(separatedBy: " ")[0] {
            let addNoteViewController = AddViewNotesViewController()
            addNoteViewController.newNote = true
            Mixpanel.mainInstance().track(event: "User created new note")
            self.present(addNoteViewController, animated: true, completion: nil)
        } else {
            alertMessage(title: "Already written note today", message: "Hi, it is great you want to keep writing today. But you already did today. Come back tomorrow to write again!")
            Mixpanel.mainInstance().track(event: "User attempt to create another note")
        }
    }
    
    @objc func refreshNoteData() {
        notes = []
        readNotes()
        self.refreshControl.endRefreshing()
    }
    
}

extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteCell
        cell.dateLabel.text = notes[indexPath.row].dateCreated.components(separatedBy: " ")[0]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.notesTableView.deselectRow(at: indexPath, animated: true)
        
        let viewNoteViewController = AddViewNotesViewController()
        viewNoteViewController.notes = [notes[indexPath.row]]
        viewNoteViewController.sameDay = notes[indexPath.row].dateCreated.components(separatedBy: " ")[0] == Helper.sharedInstance.getCurrentDate().components(separatedBy: " ")[0]
        self.navigationController?.pushViewController(viewNoteViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 83
    }
}
