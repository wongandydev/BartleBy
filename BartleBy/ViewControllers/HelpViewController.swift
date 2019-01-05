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

class HelpViewController: UIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate {
    var ref: DatabaseReference!
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var subjectTexfField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
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
        messageTextField.delegate = self
        
        getHelpInformation()
        cancelButton(title: "Cancel", color: .red)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                        self.view.frame.origin.y = -keyboardFrame.cgRectValue.height+50

        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
                self.view.frame.origin.y = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func sendContactForm() {
        ref.child("messages/\(ref.childByAutoId().key!)").setValue(["email":"\(emailTextField.text!)",
                                                                        "name":"\(nameTextField.text!)",
                                                                        "subject":"\(subjectTexfField.text!)",
                                                                        "message":"\(messageTextField.text!)"],
                                       withCompletionBlock: { error, ref in
                                        if error != nil {
                                            self.alertMessage(title: "Error", message: "There was an error sending  your message. Please try again. \(error?.localizedDescription)")
                                        } else {
                                            self.alertMessage(title: "Sucess", message: "Your message has sucessful been sent. We will try our best to get back to you as soon as possible.")
                                            self.submitFormButton.isEnabled = false
                                        }
                                        })

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
}
