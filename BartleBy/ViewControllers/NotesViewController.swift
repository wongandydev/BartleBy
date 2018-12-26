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
            self.notesTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseDatabase = Database.database().reference()
        
        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        self.navigationItem.title = "BartleBy"
        
        if #available(iOS 10.0, *) {
            notesTableView.refreshControl = refreshControl
        } else {
            notesTableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshNoteData), for: .valueChanged)
        
        loginUser()
        readNotes()
        addButton()
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
        firebaseDatabase.child("users/\(userUID!)").observe(DataEventType.value , andPreviousSiblingKeyWith: { (snapshot, error) in
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
        })
    }

    func loginUser() {
        self.firebaseDatabase.child("users/\(userUID!)/lastLogin").setValue(Helper.sharedInstance.dateToString(date: Date()))
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
        print("here")
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteCell
        cell.dateLabel.text = notes[indexPath.row].dateCreated.components(separatedBy: " ")[0]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewNoteViewController = storyboard?.instantiateViewController(withIdentifier: "AddViewNotesViewController") as? AddViewNotesViewController{
            viewNoteViewController.notes = [notes[indexPath.row]]
            viewNoteViewController.sameDay = notes[notes.count - 1].dateCreated.components(separatedBy: " ")[0] == Helper.sharedInstance.getCurrentDate().components(separatedBy: " ")[0]
            self.present(viewNoteViewController, animated: true, completion: nil)
        }
        self.notesTableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UIViewController {
    func alertMessage(title: String, message: String) {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurView.frame = self.view.frame
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            blurView.removeFromSuperview()
        }))
        
        self.view.addSubview(blurView)
        self.present(alertController, animated: true, completion: nil)
    }
}
