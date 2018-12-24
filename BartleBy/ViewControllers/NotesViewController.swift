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
    
    let userUID = UIDevice.current.identifierForVendor?.uuidString
    var firebaseDatabase: DatabaseReference!
    
    var notes: [Note] = [] {
        didSet {
            self.notesTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseDatabase = Database.database().reference()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "BartleBy"
        addButton()
        loginUser()
//        writeNotes()
        readNotes()
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
                        print(note.key)
                    }
                }
            }
        })
    }
    
    
    func writeNotes() {
        let noteID = firebaseDatabase.childByAutoId().key
        self.firebaseDatabase.child("notes/\(noteID)").setValue(["date": Helper.sharedInstance.dateToString(date: Date()), "note": "testidfasdfng it out"])
        self.firebaseDatabase.child("users/\(userUID!)/notes/\(noteID)").setValue(["date": Helper.sharedInstance.dateToString(date: Date()), "note": "testsdafasdfing it out"])
    }
    
    
    func loginUser() {
        self.firebaseDatabase.child("users/\(userUID!)/lastLogin").setValue(Helper.sharedInstance.dateToString(date: Date()))
    }
    
    @objc func addNote() {
        if let addNoteViewController = storyboard?.instantiateViewController(withIdentifier: "AddNotesViewController") as? UIViewController {
            self.present(addNoteViewController, animated: true, completion: nil)
        }
    }
    
    
}

extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteCell
        cell.dateLabel.text = "Testing Date"
        return cell
    }
    
    
}

