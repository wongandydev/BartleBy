//
//  HelpViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 12/26/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseDatabase
import FirebaseAnalytics

class HelpViewController: UIViewController, UITextFieldDelegate{
    var ref: DatabaseReference!
    
    private var questionLabel: UILabel!
    private var answerLabel: UILabel!
    private var formQuestionLabel: UILabel!
    private var nameTextField: UITextField!
    private var emailTextField: UITextField!
    private var subjectTextField: UITextField!
    private var messageTextView: UITextView!
    private var submitFormButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubviews()
        
        ref = Database.database().reference()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)

        nameTextField.delegate = self
        emailTextField.delegate = self
        subjectTextField.delegate = self
        messageTextView.delegate = self

        getHelpInformation()
        addKeyboardDoneButton()
    }
    
    fileprivate func layoutSubviews() {
        self.view.backgroundColor = .backgroundColor
        
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bounces = true
        scrollView.contentSize = self.view.frame.size
        
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints({ make in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
        })
        
        let containerView = UIView()
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints({ make in
            make.top.equalToSuperview()
            make.left.equalTo(self.view).inset(10)
            make.right.equalTo(self.view).inset(10)
            make.bottom.equalTo(scrollView)
        })
        
        questionLabel = UILabel()
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        containerView.addSubview(questionLabel)
        questionLabel.snp.makeConstraints({ make in
            make.top.equalToSuperview().offset(30)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.left.equalToSuperview()
            
        })

        answerLabel = UILabel()
        answerLabel.numberOfLines = 0
        answerLabel.textAlignment = .center
        answerLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)

        containerView.addSubview(answerLabel)
        answerLabel.snp.makeConstraints({ make in
            make.top.equalTo(questionLabel.snp.bottom).offset(10)
            make.width.equalToSuperview()
            make.left.equalToSuperview()
        })

        formQuestionLabel = UILabel()
        formQuestionLabel.numberOfLines = 0
        formQuestionLabel.textAlignment = .center
        formQuestionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        formQuestionLabel.text = "A different question? Submit a form below or click 'Email Support'."

        containerView.addSubview(formQuestionLabel)
        formQuestionLabel.snp.makeConstraints({ make in
            make.top.equalTo(answerLabel.snp.bottom).offset(20)
            make.width.equalToSuperview()
            make.left.equalToSuperview()
        })

        let formStackView = UIStackView()
        formStackView.alignment = .center
        formStackView.axis = .vertical
        formStackView.spacing = 8
        formStackView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(formStackView)
        formStackView.snp.makeConstraints({ make in
            make.top.equalTo(formQuestionLabel.snp.bottom).offset(10)
            make.width.equalToSuperview()
            make.left.equalToSuperview()
        })

        nameTextField = UITextField()
        nameTextField.backgroundColor = .backgroundColor
        nameTextField.borderStyle = .roundedRect
        nameTextField.placeholder = "Your Name*"

        formStackView.addArrangedSubview(nameTextField)
        nameTextField.snp.makeConstraints({ make in
            make.width.equalToSuperview()
        })

        emailTextField = UITextField()
        emailTextField.backgroundColor = .backgroundColor
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.placeholder = "Email*"

        formStackView.addArrangedSubview(emailTextField)
        emailTextField.snp.makeConstraints({ make in
            make.width.equalToSuperview()
        })

        subjectTextField = UITextField()
        subjectTextField.backgroundColor = .backgroundColor
        subjectTextField.borderStyle = .roundedRect
        subjectTextField.placeholder = "Subject"

        formStackView.addArrangedSubview(subjectTextField)
        subjectTextField.snp.makeConstraints({ make in
            make.width.equalToSuperview()
        })

        messageTextView = UITextView()
        messageTextView.textColor = .placeholderGray
        messageTextView.text = "Enter Message*"
        messageTextView.layer.borderColor = UIColor.gray.cgColor
        messageTextView.layer.cornerRadius = 7
        messageTextView.layer.borderWidth = 0.15
        messageTextView.backgroundColor = .backgroundColor
        messageTextView.font = UIFont.systemFont(ofSize: 16, weight: .light)

        formStackView.addArrangedSubview(messageTextView)
        messageTextView.snp.makeConstraints({ make in
            make.width.equalToSuperview()
            make.height.equalTo(100)
        })
        
        submitFormButton = UIButton()
        submitFormButton.setTitle("Send Message", for: .normal)
        submitFormButton.setTitleColor(Constants.applicationAccentColor, for: .normal)
        submitFormButton.setTitleColor(Constants.lightestGray, for: .highlighted)
        submitFormButton.backgroundColor = .clear
        submitFormButton.layer.cornerRadius = 10
        submitFormButton.layer.borderWidth = 2
        submitFormButton.layer.borderColor = Constants.applicationAccentColor.cgColor
        submitFormButton.addTarget(self, action: #selector(submitFormButtonTapped(_:)), for: .touchUpInside)
        
        formStackView.addArrangedSubview(submitFormButton)
        submitFormButton.snp.makeConstraints({ make in
            make.width.equalTo(160)
            make.height.equalTo(44)
        })
        
        let emailSupportButton = UIButton()
        emailSupportButton.setTitle("Email Support", for: .normal)
        emailSupportButton.setTitleColor(Constants.lightestGray, for: .normal)
        emailSupportButton.setTitleColor(Constants.applicationAccentColor, for: .highlighted)
        emailSupportButton.addTarget(self, action: #selector(sendSupportMail), for: .touchUpInside)
        emailSupportButton.backgroundColor = Constants.applicationAccentColor
        emailSupportButton.layer.cornerRadius = 10
        emailSupportButton.layer.borderWidth = 0
        
        containerView.addSubview(emailSupportButton)
        emailSupportButton.snp.makeConstraints({ make in
            make.top.equalTo(formStackView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(40)
        })
    }
    
    @objc func submitFormButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        sendContactForm()
    }
    
    @objc func sendSupportMail() {
        var emailTitle = "Questions, Feedback, App Support"
        var toRecipents = ["bartleby.help@gmail.com"]
        var mailComposeVC: MFMailComposeViewController = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setSubject(emailTitle)
        mailComposeVC.setToRecipients(toRecipents)
        
        self.present(mailComposeVC, animated: true, completion: nil)
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
        subjectTextField.inputAccessoryView = toolbar
        messageTextView.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    private func sendContactForm() {
        
        var errors: [String] = []
        
        if !emailTextField.text!.isEmpty && messageTextView.textColor != .placeholderGray && isValidEmail(email: emailTextField.text!) && !nameTextField.text!.isEmpty {
            ref.child("messages/\(ref.childByAutoId().key!)").setValue(["email":"\(emailTextField.text!)", "name":"\(nameTextField.text!)","subject":"\(subjectTextField.text!)","message":"\(messageTextView.text!)"],
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
        let emailRegEx = "\\A(?:[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+(?:[A-Z]{2}|asia|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum|travel)\\b)\\Z"
        
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
        
        self.questionLabel.text = "Why can I not edit any of my notes after I am done?"
        self.answerLabel.text = "We do not allow editing notes after it is written to keep the integrity of your thoughts at the moment. So when you look back, it is the thought you wrote. Not something edited. This is a feature that separates BartleBy from other note taking apps."
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

extension HelpViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            Analytics.logEvent("sendSupportMail", parameters: ["status": "cancelled"])
            print("Mail cancelled")
        case .failed:
            Analytics.logEvent("sendSupportMail", parameters: ["status": "failed"])
            print("Mail failed")
        case .saved :
            Analytics.logEvent("sendSupportMail", parameters: ["status": "saved"])
            print("Mail saved as draft")
        case .sent:
            Analytics.logEvent("sendSupportMail", parameters: ["status": "sent"])
            print("Mail sent")
        default:
            break
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
