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

        if currentNumber == 0 {
            beforeButton.isEnabled = false
        }
        
        nextDoneButton.setTitle("Next", for: .normal)
        questionLabel.text = "\(currentNumber + 1)) What are you grateful for?"
        answerTextView.text = notes[currentNumber].note
    }
    
    @IBAction func nextDoneButtonTapped(_ sender: Any) {
        if nextDoneButton.titleLabel?.text == "Done" {
            saveNotes(note: self.answerTextView.text, dateCreated: Helper.sharedInstance.getCurrentDate(), id: (ref?.childByAutoId().key)!)
            compileNotes()
            timer?.invalidate()
            self.dismiss(animated: true, completion: nil)
        } else {
            nextQuestion()
        }
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if cancelButton.titleLabel?.text == "I want to work on this later."{
            alertLeaveMessage(title: "WAIT!!!", message: "Are you sure you want to do this later? All your progress will not be saved!", cancel: true)
        } else {
            if notes[0].note != answerTextView.text {
                notes[0].note = answerTextView.text
                compileNotes()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    var ref: DatabaseReference!
    
    let userUID = UIDevice.current.identifierForVendor?.uuidString
    var currentNumber = 0
    var numberOfQuestions = 0
    var numberOfMinutes = 0
    var sameDay: Bool = true
    var newNote: Bool = false
    var templateType: Template = Template(option: .grateful)
    var notes: [Note] = []
    var seconds: Int = 0
    var timer: Timer?
    var handle: UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        answerTextView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
        cancelButton.setTitle("I want to work on this later.", for: .normal)
        answerTextView.delegate = self
        addKeyboardDoneButton()
        
        getTemplateType(completion: { templateType in
            if templateType == Template.Option.grateful.rawValue {
                self.templateType = Template(option: .grateful)
            } else {
                self.templateType = Template(option: .freeWrite)
            }
            
            if self.newNote {
                self.getSelectedNumber(completion: { selectedNumber in
                    if self.templateType.option == Template.Option.grateful {
                        self.numberOfQuestions = selectedNumber
                    } else {
                        self.numberOfMinutes = selectedNumber
                        self.seconds = selectedNumber * 60
                    }
                    self.setupQuestions()
                })
            } else {
                self.readNote()
            }
        })
    }

    func getSelectedNumber(completion: @escaping (Int) -> Void) {
        ref.child("users/\(UserDefaults.standard.object(forKey: "userUID")!)/template/templateNumber").observeSingleEvent(of: .value, with: { snapshot in
            if let templateNumber = snapshot.value as? Int{
                completion(templateNumber)
            } else {
                completion(1)
            }
        })

        
    }
    
    func getTemplateType(completion: @escaping (String) -> Void) {
        ref.child("users/\(UserDefaults.standard.object(forKey: "userUID")!)/template/templateType").observeSingleEvent(of: .value , with: { snapshot in
            if let templateType = snapshot.value as? String{
                completion(templateType)
            } else {
                completion(Template.Option.grateful.rawValue)
            }
        })
        
    }
    
    func compileNotes(){
        var compiledNote = ""
        
        if templateType.option == Template.Option.grateful {
            for note in 0...notes.count-1 {
                compiledNote+="\(note+1)) \(notes[note].note) \n"
            }
        } else {
            compiledNote = notes[notes.count - 1].note
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
        } else {
            self.ref.child("notes/\(notes[notes.count-1].id)").setValue(["note": notes[notes.count-1].note,
                                                                         "dateCreated": notes[notes.count-1].dateCreated,
                                                                         "id": notes[notes.count-1].id,
                                                                         "templateType": notes[notes.count-1].templateType])
            
            self.ref.child("users/\(userUID!)/notes/\(notes[notes.count-1].id)").setValue(["note": notes[notes.count-1].note,
                                                                                           "dateCreated": notes[notes.count-1].dateCreated,
                                                                                           "id": notes[notes.count-1].id,
                                                                                           "templateType": notes[notes.count-1].templateType])
        }
    }

    func readNote() {
        answerTextView.text = notes[0].note
        answerTextView.isEditable = false
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
        
        notes.indices.contains(currentNumber) ? notes[currentNumber].note = answerTextView.text : saveNotes(note: self.answerTextView.text, dateCreated: Helper.sharedInstance.getCurrentDate(), id: (ref?.childByAutoId().key)!)
        
        currentNumber+=1
        
        if (currentNumber + 1) == numberOfQuestions {
            nextDoneButton.setTitle("Done", for: .normal)
        }
        
        answerTextView.text = notes.indices.contains(currentNumber) ? notes[currentNumber].note : "Enter Note"
        answerTextView.textColor = .gray
        questionLabel.text = "\(currentNumber + 1)) What are you grateful for?"
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        print(seconds)
        if seconds < 1 {
            timer?.invalidate()
            alertLeaveMessage(title: "Times up!", message: "Time is up for your free write! You can no longer edit this message!", cancel: false)
            saveNotes(note: answerTextView.text, dateCreated: Helper.sharedInstance.getCurrentDate(), id: ref.childByAutoId().key!)
            compileNotes()
        } else {
            seconds-=1
        }
    }
    
    func setupQuestions(){
        beforeButton.isEnabled = false
        
        if templateType.option == Template.Option.grateful {
            questionLabel.text = "\(currentNumber + 1)) What are you grateful for?"
        } else {
            questionLabel.text = "Free Write for \(numberOfMinutes) minutes"
            startTimer()
            beforeButton.isHidden = true
        }
    
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
    
    func alertLeaveMessage(title: String, message: String, cancel: Bool) {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurView.frame = self.view.frame
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            blurView.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
        }))
        
        if cancel {
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                blurView.removeFromSuperview()
            }))
        }
        
        self.view.addSubview(blurView)
        self.present(alertController, animated: true, completion: nil)
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
