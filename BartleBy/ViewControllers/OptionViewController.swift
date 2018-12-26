//
//  OptionViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 12/24/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit
import Firebase

class OptionViewController: UIViewController {
    @IBOutlet weak var statsUIView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    
    @IBAction func editButtonTapped(_ sender: Any) {
    
    }
    private let userUID = UIDevice.current.identifierForVendor?.uuidString
    
    var options: [String] = [] {
        didSet {
            self.optionsTableView.reloadData()
        }
    }
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        
        setUsername(username: "testing")
        
        readOptions()
        addEditButton()
    }
    
    func readOptions(){
        ref.child("options").observe(DataEventType.value , andPreviousSiblingKeyWith: { (snapshot, error) in
            if let options = snapshot.value as? [String]{
                for option in options {
                    self.options.append(option)
                }
            }
        })
    }
    
    func addEditButton() {
        let editButton = UIButton(frame: CGRect(x: (self.view.frame.width/2) - 30, y: 120, width: 60, height: 35))
        editButton.backgroundColor = .red
        editButton.layer.cornerRadius = 15
        editButton.setTitle("Edit", for: .normal)
        editButton.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        self.view.addSubview(editButton)
    }

   @objc func editAction() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurView.frame = self.view.frame
    
        let alertController = UIAlertController(title: "Edit username", message: "Enter a new username", preferredStyle: .alert)
    

        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Enter Username"
        })
    
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let enteredUsername = alertController.textFields?.first?.text {
                self.setUsername(username: enteredUsername)
            }
            blurView.removeFromSuperview()
        }))
    
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            blurView.removeFromSuperview()
        }))
    
        self.view.addSubview(blurView)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setUsername(username:String) {
        self.ref.child("users/\(userUID!)/username").setValue(username)
    }
}

extension OptionViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell") as! OptionCell
        cell.optionLabel.text = options[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "gotoconfigVC", sender: nil)
            case 1:
                performSegue(withIdentifier: "gotoNotificationVC", sender: nil)
            case 2:
               performSegue(withIdentifier: "gotoHelpVC", sender: nil)
            case 3:
                performSegue(withIdentifier: "gotoAboutVC", sender: nil)
            default:
                print("defaulted")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
