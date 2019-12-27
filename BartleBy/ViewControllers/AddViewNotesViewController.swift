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
    private var beforeButton: UIButton!
    private var nextDoneButton: UIButton!
    private var questionLabel: UILabel!
    private var answerTextView: UITextView!
    private var cancelButton: UIButton!
    
    var ref: DatabaseReference!
    
    var currentNumber = 0
    var numberOfQuestions = 0
    var numberOfMinutes = 0
    var sameDay: Bool = true
    var newNote: Bool = false
    var templateType: Template = Template.grateful
    var notes: [Note] = []
    var seconds: Int = 0
    var timer: Timer?
    var handle: UInt!
    
    let placeHolderText = "Enter Note"
    let placeHolderColor: UIColor = .placeholderGray
    
    weak var delegate: AddViewNotesViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        layoutSubviews()
        
        FirebaseNetworkingService.isConnectedToInternet({ isConnected in
            if isConnected {
                self.getTemplateType(completion: { templateType in
                    if templateType == Template.grateful.rawValue {
                        self.templateType = Template.grateful
                    } else {
                        self.templateType = Template.freeWrite
                    }
                    
                    if self.newNote {
                        self.getSelectedNumber(completion: { selectedNumber in
                            if self.templateType == Template.grateful {
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
            } else {
                guard let offlineSelectedTemplateType = UserDefaults.standard.value(forKey: "userTemplateType") as? String else { return }
                if offlineSelectedTemplateType == Template.grateful.rawValue {
                    self.templateType = Template.grateful
                } else {
                    self.templateType = Template.freeWrite
                }
                
                if self.newNote {
                    self.alertLeaveMessage(title: "Not connected to internet", message: "You are not connected to the internet, you cannot at a note at the moment.", cancel: false)
                } else {
                    self.readNote()
                }
            }
        })
        
        if let note = notes.first {
            if note.isLocked {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unlock Note", style: .done, target: self, action: #selector(toggleNoteLock))
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lock Note", style: .done, target: self, action: #selector(toggleNoteLock))
            }
        }
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func layoutSubviews() {
        self.view.backgroundColor = .backgroundColor
        
        beforeButton = UIButton()
        beforeButton.setTitle("Back", for: .normal)
        beforeButton.isHidden = true
        beforeButton.setTitleColor(.red, for: .normal)
        beforeButton.setTitleColor(.black, for: .highlighted)
        beforeButton.addTarget(self, action: #selector(beforeButtonTapped(_:)), for: .touchUpInside)
        
        self.view.addSubview(beforeButton)
        beforeButton.snp.makeConstraints({ make in
            make.width.equalToSuperview().dividedBy(2.2)
            make.height.equalTo(66)
            make.left.equalToSuperview().inset(10)
            make.top.equalTo(topLayoutGuide.snp.bottom)
        })
        
        nextDoneButton = UIButton()
        nextDoneButton.setTitleColor(.blue, for: .normal)
        nextDoneButton.setTitleColor(.black, for: .highlighted)
        nextDoneButton.addTarget(self, action: #selector(nextDoneButtonTapped(_:)), for: .touchUpInside)
        
        self.view.addSubview(nextDoneButton)
        nextDoneButton.snp.makeConstraints({ make in
//            make.width.equalToSuperview().dividedBy(2.2)
            make.height.equalTo(66)
            make.right.equalToSuperview().inset(10)
            make.left.equalTo(beforeButton.snp.right).inset(5)
            make.top.equalTo(topLayoutGuide.snp.bottom)
        })
        
        questionLabel = UILabel()
        
        self.view.addSubview(questionLabel)
        questionLabel.snp.makeConstraints({ make in
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(nextDoneButton.snp.bottom).offset(10)
        })
        
        cancelButton = UIButton()
        cancelButton.backgroundColor = Constants.applicationAccentColor
        cancelButton.setTitle("I want to work on this later.", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        
        cancelButton.isHidden = !(self.navigationController == nil)
        
        self.view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints({ make in
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.width.equalToSuperview()
            make.height.equalTo(Constants.bottomButtonHeight)
        })
        
        answerTextView = UITextView()
        answerTextView.delegate = self
        answerTextView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
        answerTextView.font = UIFont.systemFont(ofSize: 16, weight: .light)
        
        self.view.addSubview(answerTextView)
        answerTextView.snp.makeConstraints({ make in
            make.bottom.equalTo(cancelButton.snp.top)
            make.top.equalTo(questionLabel.snp.bottom).offset(20)
            make.width.equalToSuperview()
        })
        
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            self.view.frame.origin.y = -keyboardFrame.cgRectValue.height+50
            self.answerTextView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: keyboardFrame.cgRectValue.height, right: 10)
            self.answerTextView.scrollIndicatorInsets = self.answerTextView.contentInset
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
//        self.view.frame.origin.y = 0
        self.answerTextView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
        self.answerTextView.scrollIndicatorInsets = self.answerTextView.contentInset
    }
    
    @objc func toggleNoteLock() {
        if AuthenticationManager.getUserAvailableBiometricType() != "" { //nil
            if let note = notes.first {
                if note.isLocked {
                    if AuthenticationManager.userAllowsAuthentication {
                        note.isLocked = false
                        if let userId = UserDefaults.standard.value(forKey: Constants.userId) as? String {
                            FirebaseNetworkingService.postDataToFirebase(path: "users/\(userId)/notes/\(note.id)", value: ["isLocked": false])
                        }
                        
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lock Note", style: .done, target: self, action: #selector(toggleNoteLock))
                        self.stockAlertMessage(title: "", message: "Note not secured")
                    } else {
                        self.alertMessage(title: "FaceID not on.", message: "We cannot lock note unless \(AuthenticationManager.getUserAvailableBiometricType()) is on.")
                    }
                } else {
                    if AuthenticationManager.userAllowsAuthentication {
                        note.isLocked = true
                        
                        if let userId = UserDefaults.standard.value(forKey: Constants.userId) as? String {
                            FirebaseNetworkingService.postDataToFirebase(path: "users/\(userId)/notes/\(note.id)", value: ["isLocked": true])
                        }
                        
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unlock Note", style: .done, target: self, action: #selector(toggleNoteLock))
                        self.stockAlertMessage(title: "", message: "Note Secured")
                    } else {
                        self.alertMessage(title: "FaceID not on.", message: "We cannot lock note unless \(AuthenticationManager.getUserAvailableBiometricType()) is on.")
                    }
                }
            }
        }
    }

    func getSelectedNumber(completion: @escaping (Int) -> Void) {
        if let userId = UserDefaults.standard.value(forKey: Constants.userId) as? String {
            ref.child("users/\(userId)/template/templateNumber").observeSingleEvent(of: .value, with: { snapshot in
                if let templateNumber = snapshot.value as? Int{
                    completion(templateNumber)
                } else {
                    completion(1)
                }
            })
        }
    }
    
    func getTemplateType(completion: @escaping (String) -> Void) {
        if let userId = UserDefaults.standard.value(forKey: Constants.userId) as? String {
            ref.child("users/\(userId)/template/templateType").observeSingleEvent(of: .value , with: { snapshot in
                if let templateType = snapshot.value as? String{
                    completion(templateType)
                } else {
                    completion(Template.grateful.rawValue)
                }
            })
        }
        
    }
    
    func compileNotes(){
        var compiledNote = ""
        
        if templateType == Template.grateful {
            for note in 0...notes.count-1 {
                compiledNote+="\(note+1)) \(notes[note].note) \n"
            }
        } else {
            compiledNote = notes[notes.count - 1].note
        }
        
        if let userId = UserDefaults.standard.value(forKey: Constants.userId) as? String {
            if newNote {
                self.ref.child("notes/\(notes[notes.count-1].id)").setValue(["note": compiledNote,
                                                                           "dateCreated": notes[notes.count-1].dateCreated,
                                                                           "id": notes[notes.count-1].id,
                                                                           "templateType": notes[notes.count-1].templateType])

                self.ref.child("users/\(userId)/notes/\(notes[notes.count-1].id)").setValue(["note": compiledNote,
                                                                                             "dateCreated": notes[notes.count-1].dateCreated,
                                                                                             "id": notes[notes.count-1].id,
                                                                                             "templateType": notes[notes.count-1].templateType])
                
                delegate?.completedNote()
            } else {
                self.ref.child("notes/\(notes[notes.count-1].id)").setValue(["note": notes[notes.count-1].note,
                                                                             "dateCreated": notes[notes.count-1].dateCreated,
                                                                             "id": notes[notes.count-1].id,
                                                                             "templateType": notes[notes.count-1].templateType])
                
                self.ref.child("users/\(userId)/notes/\(notes[notes.count-1].id)").setValue(["note": notes[notes.count-1].note,
                                                                                               "dateCreated": notes[notes.count-1].dateCreated,
                                                                                               "id": notes[notes.count-1].id,
                                                                                               "templateType": notes[notes.count-1].templateType])
                
                delegate?.completedNote()
            }
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
    
    /***
        - Checks if the note was already appended, if not append it and save the notes. It also checks to make sure the answer textview text is not the placeholder text, if it is, it saves an empty string.
     */
    
    fileprivate func addNote() {
        let note = self.answerTextView.text == placeHolderText ? "" : self.answerTextView.text ?? "no notes"
        
        notes.indices.contains(currentNumber) ? notes[currentNumber].note = note : saveNotes(note: note, dateCreated: Helper.sharedInstance.getCurrentDate(), id: (ref?.childByAutoId().key)!)
    }
    
    
    func nextQuestion() {
        hideBeforeButton(false)
        
        //dismiss keyboard
        answerTextView.resignFirstResponder()
        
        addNote()
        
        currentNumber+=1
        
        if (currentNumber + 1) == numberOfQuestions {
            nextDoneButton.setTitle("Done", for: .normal)
        }
        
        answerTextView.text = notes.indices.contains(currentNumber) &&  notes[currentNumber].note != "" ? notes[currentNumber].note : placeHolderText
        answerTextView.textColor = notes.indices.contains(currentNumber) &&  notes[currentNumber].note != ""  ?  .black : placeHolderColor
        questionLabel.text = "\(currentNumber + 1)) What are you grateful for?"
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
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
        hideBeforeButton(true)
        
        if templateType == Template.grateful {
            questionLabel.text = "\(currentNumber + 1)) What are you grateful for?"
        } else {
            questionLabel.text = "Free Write for \(numberOfMinutes) minutes"
            startTimer()
        }
    
        answerTextView.text = placeHolderText
        answerTextView.textColor = placeHolderColor

        if numberOfQuestions > 1 {
            nextDoneButton.setTitle("Next", for: .normal)
        } else {
            nextDoneButton.setTitle("Done", for: .normal)
        }
    }
    
    func saveNotes(note: String, dateCreated: String, id: String) {
        notes.append(Note(note: note, dateCreated: dateCreated, id: id, templateType: templateType.rawValue))
    }
    
    /**
     Dimisses the VC if it is presented after 'Okay' button is tapped.
     */
    
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
    
    fileprivate func hideBeforeButton(_ hide: Bool) {
        if hide {
            beforeButton.isEnabled = false
            beforeButton.isHidden = true
        } else {
            beforeButton.isEnabled = true
            beforeButton.isHidden = false
        }
       
    }
    
    
    @objc func beforeButtonTapped(_ sender: Any) {
        //dismiss keyboard
        answerTextView.resignFirstResponder()
        
        addNote()
        
        currentNumber -= 1
        
        if currentNumber == 0 {
            hideBeforeButton(true)
        }
        
        nextDoneButton.setTitle("Next", for: .normal)
        questionLabel.text = "\(currentNumber + 1)) What are you grateful for?"
        answerTextView.text = notes[currentNumber].note == "" ? placeHolderText : notes[currentNumber].note
        answerTextView.textColor = notes[currentNumber].note == "" ? placeHolderColor : .black
    }
    
    @objc func nextDoneButtonTapped(_ sender: Any) {
        if nextDoneButton.titleLabel?.text == "Done" {
            if self.templateType == Template.grateful && self.answerTextView.text != "" && self.answerTextView.text != placeHolderText && !notes.contains(where: { $0.note.isEmpty}) {
                addNote()
                compileNotes()
                self.dismiss(animated: true, completion: {
                    // if has not seen the view alert.
                    
                    UserDefaults.standard.setValue(false, forKey: Constants.hasSeenReviewAlert)
                    if !UserDefaults.standard.bool(forKey: Constants.hasSeenReviewAlert) {
                        let randomNumber = Int.random(in: 1...10)
                        print(randomNumber)
                        print(randomNumber % 3 == 0)
                        // and the random number is a divisible by 3; 3,6,9 then
                        if randomNumber % 3 == 0 {
                            // show alert
                            let window = UIApplication.shared.keyWindow
                            
                            if let rootVC = window?.rootViewController as? UIViewController {
                                rootVC.showRatingsReviewAlert()
                            }
                        }
                    }
                })
            } else {
                alertMessage(title: "Empty Note", message: "Your note is empty!")
            }
            
        } else {
            nextQuestion()
        }
    }
    
    @objc func cancelButtonTapped(_ sender: Any) {
        if cancelButton.titleLabel?.text == "I want to work on this later."{
            alertLeaveMessage(title: "WAIT!!!", message: "Are you sure you want to do this later? All your progress will not be saved!", cancel: true)
            timer?.invalidate()
        } else {
            if notes[0].note != answerTextView.text {
                notes[0].note = answerTextView.text
                compileNotes()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension AddViewNotesViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        addKeyboardDoneButton()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == placeHolderColor {
            textView.text = ""
            textView.textColor = .backgroundColorReversed
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolderText
            textView.textColor = placeHolderColor
        }
    }
}

protocol AddViewNotesViewControllerDelegate: class {
    func completedNote()
}
