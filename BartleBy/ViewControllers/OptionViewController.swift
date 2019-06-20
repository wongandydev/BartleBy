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
    private var bannerAdView: GADBannerView!
    private let userUID = UIDevice.current.identifierForVendor?.uuidString
    
    var options: [String] = ["Manage type of writing", "Manage Notifications", "Stats", "Help", "About"]
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "No Preferred Name Set"
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Light", size: 17.0)
        return label
    }()
    
    let optionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "optionCell")
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        layoutSubviews()
        getUsername()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.transparentNavBar()
        
    }
    
    private func layoutSubviews() {
        self.view.backgroundColor = .white
        
        view.addSubview(usernameLabel)
        usernameLabel.snp.makeConstraints({ make in
            make.width.equalToSuperview().offset(20)
            make.height.equalTo(35)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view).offset(Constants.topPadding)
        })
        
        let editButton = UIButton(frame: CGRect(x: (self.view.frame.width/2) - 30, y: 150, width: 60, height: 35))
        editButton.backgroundColor = .red
        editButton.layer.cornerRadius = 15
        editButton.setTitle("Edit", for: .normal)
        editButton.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        
        self.view.addSubview(editButton)
        editButton.snp.makeConstraints({ make in
            make.width.equalTo(60)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.top.equalTo(usernameLabel.snp.bottom).offset(10)
        })
        
        optionsCollectionView.delegate = self
        optionsCollectionView.dataSource = self
        
        view.addSubview(optionsCollectionView)
        optionsCollectionView.snp.makeConstraints({ make in
            make.width.equalToSuperview()
            make.height.equalTo(self.view.frame.height - 354)
            make.center.equalToSuperview()
        })
        
        bannerAdView = GADBannerView()
        bannerAdView.backgroundColor = .black
        setupBannerAd()
        
        view.addSubview(bannerAdView)
        bannerAdView.snp.makeConstraints({ make in
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
            make.width.equalTo(320)
            make.height.equalTo(50)
        })
    }
    
    func setupBannerAd() {
        self.bannerAdView.adUnitID = Constants.googleAdMobBannerId
        self.bannerAdView.rootViewController = self;
        let request = GADRequest()
//        request.testDevices = [kGADSimulatorID]
        bannerAdView.load(request)
    }
    
    func getUsername(){
        ref.child("users/\(userUID!)/username").observeSingleEvent(of: .value , with: { snapshot in
            if let serverUsername = snapshot.value as? String {
                self.usernameLabel.text = serverUsername
            }
        })
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

extension OptionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionCell", for: indexPath)
//        //Create Lavel
        let label: UILabel = {
            let aLabel = UILabel()
            aLabel.frame = CGRect(x: 10, y: cell.layer.frame.height/2 - 30, width: cell.layer.frame.width - 10, height: cell.layer.frame.height)
            return aLabel
        }()

        label.text = options[indexPath.row]
        cell.addSubview(label)
        cell.layer.masksToBounds = false
        cell.layer.cornerRadius = 5
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowOpacity = 1
        cell.layer.shadowRadius = 5
        cell.backgroundColor = .white
        

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

        self.optionsCollectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 30, height: 60)
    }
}
