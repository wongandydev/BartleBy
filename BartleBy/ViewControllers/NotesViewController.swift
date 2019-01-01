//
//  ViewController.swift
//  NoNameYet
//
//  Created by Andy Wong on 12/20/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit
import Firebase

class NotesViewController: UIViewController {
    
    @IBOutlet weak var notesTableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    private let userUID = UIDevice.current.identifierForVendor?.uuidString
    var firebaseDatabase: DatabaseReference!
    
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
        firebaseDatabase = Database.database().reference()
        
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesTableView.tableFooterView = UIView()
        
        self.navigationItem.title = "BartleBy"
        
        if #available(iOS 10.0, *) {
            notesTableView.refreshControl = refreshControl
        } else {
            notesTableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshNoteData), for: .valueChanged)
        addButton()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        readNotes()
    }
    
    func setStats() {
        let totalNotes = notes.count
        let today = Helper.sharedInstance.stringToDate(date: Helper.sharedInstance.getCurrentDate().components(separatedBy: " ")[0])
        let latestNote = Helper.sharedInstance.stringToDate(date: self.notes[0].dateCreated.components(separatedBy: " ")[0])
        var currentStreak = 0

        if totalNotes > 0 {
            let diffFromTodayToLastNote: Int = Calendar.current.dateComponents([.day], from: today, to: latestNote).day ?? 0
            if diffFromTodayToLastNote < -1 {
                currentStreak = 0
                print("has been \(abs(diffFromTodayToLastNote)) days since last note")
            } else {
                currentStreak += 1
                for noteIndex in 0...totalNotes - 2{
                    print(noteIndex)
                    let firstDate = Helper.sharedInstance.stringToDate(date: self.notes[noteIndex].dateCreated.components(separatedBy: " ")[0])
                    let secondDate = Helper.sharedInstance.stringToDate(date: self.notes[noteIndex + 1].dateCreated.components(separatedBy: " ")[0])
                    print(firstDate)
                    print(secondDate)
                    
                    let difference = Calendar.current.dateComponents([.day], from: firstDate, to: secondDate).day ?? 0
                    print("diff\(difference)")
                    if  difference < -1 {
                        print("here")
                        break
                    } else {
                        currentStreak += 1
                    }
                    print("new\(currentStreak)")
                }
            }
        } else {
            currentStreak = 0
        }
        
        print("currentStreak\(currentStreak)")
        
        self.firebaseDatabase.child("users/\(self.userUID!)/stats").setValue(["streak": currentStreak, "totalNotes": totalNotes])

    }
    
    
    func addButton() {
        let addButton = UIButton(frame: CGRect(x: self.view.frame.width - 70, y: self.view.frame.height - 150, width: 60, height: 60))
        addButton.layer.cornerRadius = 30
        addButton.backgroundColor = .red
        addButton.setTitle("Add", for: .normal)
        addButton.titleLabel?.textColor = .white
        addButton.addTarget(self, action: #selector(addNote), for: .touchUpInside)
        
        self.view.addSubview(addButton)
    }

    func readNotes() {
        firebaseDatabase.child("users/\(userUID!)").observeSingleEvent(of: .value , with: { snapshot in
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

    
    @objc func addNote() {
        if notes == [] || notes[notes.count - 1].dateCreated.components(separatedBy: " ")[0] != Helper.sharedInstance.getCurrentDate().components(separatedBy: " ")[0] {
            if let addNoteViewController = storyboard?.instantiateViewController(withIdentifier: "AddViewNotesViewController") as? AddViewNotesViewController {
                addNoteViewController.newNote = true
                self.present(addNoteViewController, animated: true, completion: nil)
            }
        } else {
            alertMessage(title: "Already written note today", message: "Hi, it is great you want to keep writing today. But you already did today. Come back tomorrow to write again!")
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
        if let viewNoteViewController = storyboard?.instantiateViewController(withIdentifier: "AddViewNotesViewController") as? AddViewNotesViewController{
            viewNoteViewController.notes = [notes[indexPath.row]]
            viewNoteViewController.sameDay = notes[indexPath.row].dateCreated.components(separatedBy: " ")[0] == Helper.sharedInstance.getCurrentDate().components(separatedBy: " ")[0]
            self.present(viewNoteViewController, animated: true, completion: nil)
        }
        self.notesTableView.deselectRow(at: indexPath, animated: true)
    }
}
