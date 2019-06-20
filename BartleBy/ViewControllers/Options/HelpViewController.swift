//
//  HelpViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 12/26/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit
import MessageUI
import Firebase

class HelpViewController: UIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate{
    var ref: DatabaseReference!
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var subjectTexfField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var submitFormButton: UIButton!
    @IBAction func submitFormButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        sendContactForm()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        subjectTexfField.delegate = self
        messageTextView.delegate = self
        
        setupTextView()
        getHelpInformation()
        addKeyboardDoneButton()
//        cancelButton(title: "Cancel", color: .red)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let screenHeight = self.view.frame.height
            let doneToolbar = 10
            
            let screenMiddleY = screenHeight/2
            let newMiddleY = ((screenHeight + 44) - CGFloat(keyboardFrame.cgRectValue.height))/2 - CGFloat(doneToolbar)
            let distance = screenMiddleY-newMiddleY
            self.view.frame.origin.y = -distance
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
                self.view.frame.origin.y = 0
    }
    
    
    func setupTextView() {
        messageTextView.textColor = .placeholderGray
        messageTextView.text = "Enter Message*"
        messageTextView.layer.borderColor = UIColor.lightGray.cgColor
        messageTextView.layer.cornerRadius = 7
        messageTextView.layer.borderWidth = 0.3
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func addKeyboardDoneButton() {
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        nameTextField.inputAccessoryView = toolbar
        emailTextField.inputAccessoryView = toolbar
        subjectTexfField.inputAccessoryView = toolbar
        messageTextView.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    private func sendContactForm() {
        
        var errors: [String] = []
        
        if !emailTextField.text!.isEmpty && messageTextView.textColor != .placeholderGray && isValidEmail(email: emailTextField.text!) && !nameTextField.text!.isEmpty {
            ref.child("messages/\(ref.childByAutoId().key!)").setValue(["email":"\(emailTextField.text!)", "name":"\(nameTextField.text!)","subject":"\(subjectTexfField.text!)","message":"\(messageTextView.text!)"],
                   withCompletionBlock: { error, ref in
                    if error != nil {
                        self.alertMessage(title: "Error", message: "There was an error sending  your message. Please try again. \(error?.localizedDescription)")
                    } else {
                        self.submitFormMessage(title: "Sucess", message: "Your message has sucessfully been sent. We will try our best to get back to you as soon as possible.")
                    }
            })
        } else {
        
            if emailTextField.text!.isEmpty {
                errors.append(" - You forgot to enter an email! Please provide one so we can get back to you!")
            }
            
            if messageTextView.textColor == .placeholderGray {
                errors.append(" - You forgot to tell us what you need help with!")
            }
            
            if !isValidEmail(email: emailTextField.text!) {
                errors.append(" - Your email is not valid. Please try again.")
            }
            
            if nameTextField.text!.isEmpty {
                errors.append(" - You forgot to enter your name! We would like to know our users. Please enter a name. if you are not comfortable at all, just write \"no name\"")
            }
        }
        
        if !errors.isEmpty {
            let message = errors.map { String($0) }
            self.alertMessage(title: "Error", message: message.joined(separator: "\n"))
        }
    }
    
    func isValidEmail(email:String) -> Bool {
        let emailRegEx = "\\A(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+(?:[A-Z]{2}|asia|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum|travel)\\b)\\Z"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func getHelpInformation() {
        ref.child("documents").observe(.value, with: { snapshot in
            if let documents = snapshot.value as? [String: AnyObject] ,
                let allHelp = documents["help"] as? [String: String] {
                for help in allHelp {
                    self.questionLabel.text = help.key
                    self.answerLabel.text = help.value

                }
                
            }
        })
    }
    
    func submitFormMessage(title: String, message: String) {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurView.frame = self.view.frame
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            blurView.removeFromSuperview()
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.view.addSubview(blurView)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension HelpViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderGray {
            textView.textColor = .black
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = .placeholderGray
            textView.text = "Enter Message*"
        }
    }
}


extension UIColor {
    static var placeholderGray = UIColor(red: 178/225, green: 178/225, blue: 178/225, alpha: 1.0)
}
