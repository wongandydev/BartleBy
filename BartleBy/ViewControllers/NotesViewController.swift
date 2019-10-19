//
//  ViewController.swift
//  NoNameYet
//
//  Created by Andy Wong on 12/20/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseDatabase
import GoogleMobileAds
import SnapKit
import Mixpanel

class NotesViewController: UIViewController {
    
    var notesCollectionView: UICollectionView!
    private var bannerAdView: GADBannerView!
    
//    private let refreshControl = UIRefreshControl()
    
    var ref: DatabaseReference!
    
    var notes: [Note] = [] {
        didSet {
            notes.sort(by: { (note1, note2) in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy' 'hh:mm:ss a"
                dateFormatter.timeZone = NSTimeZone.system
                
                return dateFormatter.date(from: note1.dateCreated)! > dateFormatter.date(from: note2.dateCreated)!
            })
            
            let monthYearFormatter = DateFormatter()
            monthYearFormatter.dateFormat = "MM/dd/yy' 'hh:mm:ss a"
            monthYearFormatter.timeZone = NSTimeZone.system
            
            notes.forEach({ note in
                if let noteDate = monthYearFormatter.date(from: note.dateCreated) as? Date {
                    let calendar = Calendar.current
                    let componenets = calendar.dateComponents([.month, .year], from: noteDate)
                    
                    if let noteMonthYear = calendar.date(from: componenets) {
                        if !monthsOfNotes.contains(noteMonthYear) {
                            monthsOfNotes.append(noteMonthYear)
                        }
                    }
                }
            })
            
            UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: notes), forKey: "offlineNotes")
        }
    }
    
    var sortedNotes: [[Note]] = [[]]
    
    var monthsOfNotes: [Date] = [] {
        didSet {
            monthsOfNotes.sort(by: { (date1, date2) in
                date1 > date2
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        if let isFirstLaunch = UserDefaults.standard.bool(forKey: Constants.isFirstLaunch) as? Bool {
            if !isFirstLaunch {
                let alertController = UIAlertController(title: "Welcome", message: "By default, the app recommends 5 things to be grateful for. You can change this in Options > Manage type of writing.", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                alertController.addAction(UIAlertAction(title: "Let's change it.", style: .default, handler: { action in
                    self.tabBarController?.selectedIndex = 1
                    if let currentTabVC = self.tabBarController,
                        let currentNavVC = currentTabVC.selectedViewController as? UINavigationController,
                        let currentVC = currentNavVC.viewControllers.first as? OptionViewController {
                        
                        let configVC = ConfigViewController()
                        currentVC.navigationController?.pushViewController(configVC, animated: true)
                        
                    }
                    
                }))
                
                self.present(alertController, animated: true, completion: nil)
                
                UserDefaults.standard.set(true, forKey: Constants.isFirstLaunch)
            }
        }
        
        setupNavbar()
        self.navigationItem.title = "BartleBy"
        layoutSubviews()
    }
    
    fileprivate func registerCells() {
        notesCollectionView.register(NoteCell.self, forCellWithReuseIdentifier: "noteCell")
        notesCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "notesHeader")
    }
    
    fileprivate func setupTableView() {
        notesCollectionView.delegate = self
        notesCollectionView.dataSource = self
        registerCells()
    }
    
    fileprivate func sortNotes() {
        let monthYearFormatter = DateFormatter()
        monthYearFormatter.dateFormat = "MM/dd/yy' 'hh:mm:ss a"
        monthYearFormatter.timeZone = NSTimeZone.system
        
        sortedNotes = [[]]
        
        for note in notes {
            if let noteDate = monthYearFormatter.date(from: note.dateCreated) as? Date {
                let calendar = Calendar.current
                let componenets = calendar.dateComponents([.month, .year], from: noteDate)
                
                if let noteMonthYear = calendar.date(from: componenets),
                    let indexFromMonthOfNotes = monthsOfNotes.index(of: noteMonthYear) {
                    
                    //If the array doesn't have that index, add it.
                    if !sortedNotes.indices.contains(indexFromMonthOfNotes) {
                        sortedNotes.append([])
                    }
                    
                    //add notes based on month index.
                    sortedNotes[indexFromMonthOfNotes].append(note)
                }
            }
        }
        
        Spinner.stop()
        self.notesCollectionView.reloadData()
    }
    
    fileprivate func layoutSubviews() {
        self.view.backgroundColor = .backgroundColor
        
        notesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        notesCollectionView.backgroundColor = .clear
        
        notesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        setupTableView()
        
//        //Add Pull to refresh
//        if #available(iOS 10.0, *) {
//            notesTableView.refreshControl = refreshControl
//        } else {
//            notesTableView.addSubview(refreshControl)
//        }
//        refreshControl.addTarget(self, action: #selector(refreshNoteData), for: .valueChanged)
    
        bannerAdView = GADBannerView()
        setupBannerAd()
        
        self.view.addSubview(bannerAdView)
        bannerAdView.snp.makeConstraints({ make in
            make.bottom.equalToSuperview().inset(Constants.tabBarHeight + Constants.bottomPadding)
            make.centerX.equalToSuperview()
            make.width.equalTo(320)
            make.height.equalTo(50)
        })
        
        self.view.addSubview(notesCollectionView)
        notesCollectionView.snp.makeConstraints({ make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(bannerAdView.snp.top)
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
            make.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(Constants.tabBarHeight + Constants.bottomPadding + 20)
            make.width.height.equalTo(60)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if notes.isEmpty {
            readNotes()
        }
    }
    
    func setupBannerAd() {
        self.bannerAdView.adUnitID = Constants.googleAdMobBannerId
        self.bannerAdView.rootViewController = self;
        let request = GADRequest()
//        request.testDevices = [kGADSimulatorID]
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
            if diffFromTodayToLastNote < -1 {
                currentStreak = 0
            } else {
                //Include today
                currentStreak += 1
                for noteIndex in 0...totalNotes - 2{
                    let firstDate = Helper.sharedInstance.stringToDate(date: self.notes[noteIndex].dateCreated.components(separatedBy: " ")[0])
                    let secondDate = Helper.sharedInstance.stringToDate(date: self.notes[noteIndex + 1].dateCreated.components(separatedBy: " ")[0])
                    
                    let difference = Calendar.current.dateComponents([.day], from: firstDate, to: secondDate).day ?? 0
                    //If greater than one break
                    if  difference < -1 {
                        //Do not count
                        break
                    //If the diffference is today
                    } else if difference == 0 {
                        //Do nothing
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
    
    private func addBackgroundView() {
        let backgroundLabel = UILabel()
        backgroundLabel.text = "Add a note to get started on jotting down your thoughts!"
        backgroundLabel.textAlignment = .center
        backgroundLabel.textColor = Constants.applicationAccentColor
        backgroundLabel.numberOfLines = 0
        backgroundLabel.font = UIFont.systemFont(ofSize: 22)
        
        self.notesCollectionView.backgroundView = backgroundLabel
        
        backgroundLabel.snp.makeConstraints({ make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-25)
            make.height.equalTo(200)
        })
        
    }
    
    fileprivate func readNotes() {
        Spinner.start(view: self.view)
        if let noteData = UserDefaults.standard.value(forKey: "offlineNotes") as? Data,
            let noteObject = NSKeyedUnarchiver.unarchiveObject(with: noteData) as? [Note] {
            
            self.notes = noteObject
            self.sortNotes()
        }
        
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
                                
                                if let isLocked = value["isLocked"] as? Bool {
                                    self.notes.append(Note(note: answerNote, dateCreated: dateCreated, id: note.key, templateType: templateType, isLocked: isLocked))
                                } else {
                                    self.notes.append(Note(note: answerNote, dateCreated: dateCreated, id: note.key, templateType: templateType))
                                }
                                
                            }
                        }
                    }
                }
                self.setStats()
                self.sortNotes()
            })
        }
    }

    
    @objc func addNote() {
        if notes == [] || notes[0].dateCreated.components(separatedBy: " ")[0] != Helper.sharedInstance.getCurrentDate().components(separatedBy: " ")[0] {
            if !Reachability.isConnectedToNetwork() {
                stockAlertMessage(title: "Not connected to the internet", message: "You are not connected to the internet. Please try again.")
            } else {
                let addNoteViewController = AddViewNotesViewController()
                addNoteViewController.modalPresentationStyle = .fullScreen
                addNoteViewController.newNote = true
                addNoteViewController.delegate = self
                
                Analytics.logEvent("User created new note", parameters: nil)
                Mixpanel.mainInstance().track(event: "User created new note")
                self.present(addNoteViewController, animated: true, completion: nil)
            }
        } else {
            alertMessage(title: "Already written note today", message: "Hi, it is great you want to keep writing today. But you already did today. Come back tomorrow to write again!")
            Analytics.logEvent("User attempted to create another note", parameters: nil)
            Mixpanel.mainInstance().track(event: "User attempted to create another note")
        }
    }
    
//    @objc func refreshNoteData() {
//        notes = []
//        readNotes()
//        self.refreshControl.endRefreshing()
//    }
    
}

extension NotesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sortedNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if notes.count == 0 {
            addBackgroundView()
        } else {
            self.notesCollectionView.backgroundView = nil
        }
        
        
        return sortedNotes[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var title = ""
        let aView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "notesHeader", for: indexPath) as! UICollectionReusableView
        
        
        if let sectionLatestNote = sortedNotes[indexPath.section].first?.dateCreated,
            let sectionLatestNoteDateStrng = sectionLatestNote.components(separatedBy: " ").first as? String,
            let sectionLatestNoteDate = Helper.sharedInstance.stringToDate(date: sectionLatestNoteDateStrng) as? Date {
            let calendar = Calendar.current
            let componenets = calendar.dateComponents([.month, .year], from: sectionLatestNoteDate)

            //Converting string date to just month year format.
            if let date = calendar.date(from: componenets) {
                title = Helper.sharedInstance.setMonthYearToString(date: date)
            }

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.numberOfLines = 0
            
            aView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints({ make in
                make.top.left.bottom.equalToSuperview().inset(10)
            })
            
        }
        
        return aView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noteCell", for: indexPath) as! NoteCell
        cell.dateLabel.text = sortedNotes[indexPath.section][indexPath.row].dateCreated.components(separatedBy: " ")[0]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.notesCollectionView.deselectItem(at: indexPath, animated: true)
        
        var note = sortedNotes[indexPath.section][indexPath.row]
        
        let viewNoteViewController = AddViewNotesViewController()
        viewNoteViewController.notes = [note]
        viewNoteViewController.sameDay = sortedNotes[indexPath.section][indexPath.row].dateCreated.components(separatedBy: " ")[0] == Helper.sharedInstance.getCurrentDate().components(separatedBy: " ")[0]
        viewNoteViewController.delegate = self
        
        if note.isLocked && AuthenticationManager.userAllowsAuthentication {
            AuthenticationManager.authenticateUser({ isSucess in
                if isSucess {
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(viewNoteViewController, animated: true)
                    }
                }
            })
        } else {
            self.navigationController?.pushViewController(viewNoteViewController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 20, height: 83)
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let note =  self.sortedNotes[indexPath.section][indexPath.row]
//        var lockAction: UITableViewRowAction!
//
//        if AuthenticationManager.getUserAvailableBiometricType() != "" { //nil
//            if note.isLocked {
//                lockAction = UITableViewRowAction(style: .normal, title: "Unlock", handler: { action, indexPath in
//                    if AuthenticationManager.userAllowsAuthentication {
//                        note.isLocked = false
//                        if let userId = UserDefaults.standard.value(forKey: Constants.userId) as? String {
//                            FirebaseNetworkingService.postDataToFirebase(path: "users/\(userId)/notes/\(note.id)", value: ["isLocked": false])
//                        }
//                        self.stockAlertMessage(title: "", message: "Unlocked Note")
//                    } else {
//                        self.alertMessage(title: "FaceID not on.", message: "We cannot lock note unless \(AuthenticationManager.getUserAvailableBiometricType()) is on.")
//                    }
//
//                })
//            } else {
//                lockAction = UITableViewRowAction(style: .normal, title: "Lock", handler: { action, indexPath in
//                    if AuthenticationManager.userAllowsAuthentication {
//                        note.isLocked = true
//                        if let userId = UserDefaults.standard.value(forKey: Constants.userId) as? String {
//                            FirebaseNetworkingService.postDataToFirebase(path: "users/\(userId)/notes/\(note.id)", value: ["isLocked": true])
//                        }
//                        self.stockAlertMessage(title: "", message: "Locked Note")
//                    } else {
//                        self.alertMessage(title: "FaceID not on.", message: "We cannot lock note unless \(AuthenticationManager.getUserAvailableBiometricType()) is on.")
//                    }
//
//                })
//            }
//
//
//            return [lockAction]
//        } else {
//            return nil
//        }
//    }
}

extension NotesViewController: AddViewNotesViewControllerDelegate {
    func completedNote() {
         readNotes()
    }
}
