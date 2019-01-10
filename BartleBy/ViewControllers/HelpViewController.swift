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
                        self.view.frame.origin.y = -keyboardFrame.cgRectValue.height+50

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
    
    func sendContactForm() {
        if emailTextField.text!.isEmpty {
            alertMessage(title: "Missing Email", message: "You forgot to enter a email! Without one we can't reply to your message!")
        } else if messageTextView.textColor == .placeholderGray {
            alertMessage(title: "Missing message", message: "You forgot to tell us what your question is!")
        } else if !isValidEmail(email: emailTextField.text!){
            alertMessage(title: "Error", message: "Your email was not valid. Please check again.")
        } else {
            ref.child("messages/\(ref.childByAutoId().key!)").setValue(["email":"\(emailTextField.text!)", "name":"\(nameTextField.text!)","subject":"\(subjectTexfField.text!)","message":"\(messageTextView.text!)"],
                   withCompletionBlock: { error, ref in
                    if error != nil {
                        self.alertMessage(title: "Error", message: "There was an error sending  your message. Please try again. \(error?.localizedDescription)")
                    } else {
                        self.submitFormMessage(title: "Sucess", message: "Your message has sucessful been sent. We will try our best to get back to you as soon as possible.")
                    }
            })
        }
    }
    
    func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
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
