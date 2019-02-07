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
    @IBOutlet weak var bannerAdView: GADBannerView!
    private let userUID = UIDevice.current.identifierForVendor?.uuidString
    
    var options: [String] = [] {
        didSet {
//            self.optionsTableView.reloadData()
        }
    }
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "No Preferred Name Set"
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Light", size: 17.0)
        return label
    }()
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        usernameLabel.frame = CGRect(x: 10, y: 100, width: view.frame.width - 20, height: 35)
        view.addSubview(usernameLabel)
        
//        optionsTableView.delegate = self
//        optionsTableView.dataSource = self
//        optionsTableView.tableFooterView = UIView()
//        optionsTableView.separatorStyle = .none
        
//        usernameLabel.text = "No Preferred Name"
        getUsername()
        readOptions()
        addEditButton()
        setupBannerAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.transparentNavBar()
        
    }
    
    func setupBannerAd() {
        self.bannerAdView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        self.bannerAdView.rootViewController = self;
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerAdView.load(request)
    }
    
    func getUsername(){
        ref.child("users/\(userUID!)/username").observeSingleEvent(of: .value , with: { snapshot in
            if let serverUsername = snapshot.value as? String {
                self.usernameLabel.text = serverUsername
            }
        })
    }
    
    func readOptions(){
        ref.child("options").observeSingleEvent(of:.value , with: { snapshot in
            if let options = snapshot.value as? [String]{
                for option in options {
                    self.options.append(option)
                }
            }
        })
    }
    
    func addEditButton() {
        let editButton = UIButton(frame: CGRect(x: (self.view.frame.width/2) - 30, y: 150, width: 60, height: 35))
        editButton.backgroundColor = .red
        editButton.layer.cornerRadius = 15
        editButton.setTitle("Edit", for: .normal)
        editButton.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        self.view.addSubview(editButton)
    }

   @objc func editAction() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurView.frame = self.view.frame
    
        let alertController = UIAlertController(title: "Edit username", message: "Enter a new username. This user name is really a name you prefer to place on this app to be known as, No one will know about it but you. Just to maek this app a bit more personal", preferredStyle: .alert)
    

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
        getUsername()
    }
}

extension OptionViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell") as! OptionCell
        cell.optionLabel.text = options[indexPath.row]
        cell.layer.cornerRadius = 5
        cell.layer.borderWidth = 1
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "gotoConfigVC", sender: nil)
            case 1:
                performSegue(withIdentifier: "gotoNotificationVC", sender: nil)
            case 2:
                performSegue(withIdentifier: "gotoStatsVC", sender: nil)
            case 3:
                performSegue(withIdentifier: "gotoHelpVC", sender: nil)
            case 4:
                performSegue(withIdentifier: "gotoAboutVC", sender: nil)
            default:
                print("defaulted")
        }
        
//        self.optionsTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
