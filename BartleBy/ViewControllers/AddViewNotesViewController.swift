//
//  AddNotesViewController.swift
//  NoNameYet
//
//  Created by Andy Wong on 12/21/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import Firebase
import UIKit

class AddViewNotesViewController: UIViewController {
    @IBOutlet weak var beforeButton: UIButton!
    @IBOutlet weak var nextDoneButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func beforeButtonTapped(_ sender: Any) {
        currentNumber -= 1

        if currentNumber == 1 {
            beforeButton.isEnabled = false
        }
        
        
        nextDoneButton.setTitle("Next", for: .normal)
        questionLabel.text = "\(currentNumber)) What are you grateful for?"
        answerTextView.text = notes[0].note
    }
    
    @IBAction func nextDoneButtonTapped(_ sender: Any) {
        saveNotes(note: self.answerTextView.text, dateCreated: Helper.sharedInstance.getCurrentDate(), id: (ref?.childByAutoId().key)!)
        
        if nextDoneButton.titleLabel?.text == "Done" {
            compileNotes()
            self.dismiss(animated: true, completion: nil)
        } else {
            nextQuestion()
        }
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var ref: DatabaseReference!
    
    let userUID = UIDevice.current.identifierForVendor?.uuidString
    var currentNumber = 1
    var numberOfQuestions = 3
    var newNote: Bool = false
    var templateType: Template = Template(option: .grateful)
    var notes: [Note] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(notes)
        ref = Database.database().reference()
        answerTextView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
        
        if newNote {
            setupQuestions()
        } else {
            readNote()
        }
        
        answerTextView.delegate = self
        
        addKeyboardDoneButton()
    }
    
    func compileNotes(){
        var compiledNote = ""
        
        for note in 0...notes.count-1 {
            compiledNote+="\(note+1)) \(notes[note].note) \n"
        }
        
        if newNote {
            self.ref.child("notes/\(notes[notes.count-1].id)").setValue(["note": compiledNote,
                                                                       "dateCreated": notes[notes.count-1].dateCreated,
                                                                       "id": notes[notes.count-1].id,
                                                                       "templateType": notes[notes.count-1].templateType])

            self.ref.child("users/\(userUID!)/notes/\(notes[notes.count-1].id)").setValue(["note": compiledNote,
                                                                                         "dateCreated": notes[notes.count-1].dateCreated,
                                                                                         "id": notes[notes.count-1].id,
                                                                                         "templateType": notes[notes.count-1].templateType])
        }
    }

    func readNote() {
        answerTextView.text = notes[0].note
        questionLabel.text = "On \(notes[0].dateCreated.components(separatedBy: " ")[0]) you wrote..."
        
        beforeButton.isHidden = true
        nextDoneButton.isHidden = true
        cancelButton.setTitle("Go Back", for: .normal)
    }
    
    func addKeyboardDoneButton() {
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        answerTextView.inputAccessoryView = toolbar
    }

    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    
    func nextQuestion() {
        beforeButton.isEnabled = true
        currentNumber+=1
        
        if (currentNumber) == numberOfQuestions {
            nextDoneButton.setTitle("Done", for: .normal)
        }
        
        answerTextView.text = "Enter Note"
        answerTextView.textColor = .gray
        questionLabel.text = "\(currentNumber)) What are you grateful for?"
    }
    
    
    
    func setupQuestions(){
        beforeButton.isEnabled = false
        questionLabel.text = "\(currentNumber)) What are you grateful for?"
        
        answerTextView.text = "Enter Note"
        answerTextView.textColor = .gray

        
        if numberOfQuestions > 1 {
            nextDoneButton.setTitle("Next", for: .normal)
        } else {
            nextDoneButton.setTitle("Done", for: .normal)
        }
    }
    
    func saveNotes(note: String, dateCreated: String, id: String) {
        notes.append(Note(note: note, dateCreated: dateCreated, id: id, templateType: String(templateType.option.rawValue)))
    }
}

extension AddViewNotesViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .gray {
            textView.text = ""
            textView.textColor = .black
        }
    }
}
