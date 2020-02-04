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
    private var bannerAdView = GADBannerView()
    private let userUID = UIDevice.current.identifierForVendor?.uuidString
    
    var options: [String] = ["Manage type of writing", "Manage Notifications", "Stats","Remove Ads", "Help", "About", "\(AuthenticationManager.userAllowsAuthentication ? "Turn off" : "Turn on") \(AuthenticationManager.getUserAvailableBiometricType())", "Sign Up/Sign In"]
    
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
        
        setupNavbar()
        layoutSubviews()
        getUsername()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if UserDefaults.standard.bool(forKey: Constants.noAdIdentifier) == true { // no ads purchased
//            bannerAdView.isHidden = true
            
            bannerAdView.snp.remakeConstraints({ make in
                make.bottom.equalTo(bottomLayoutGuide.snp.top)
                make.centerX.equalToSuperview()
                make.width.equalTo(320)
                make.height.equalTo(0)
            })
        }
    }
    
    private func layoutSubviews() {
        self.view.backgroundColor = .backgroundColor
        
//        usernameLabel.alpha = 0.0
//
//        view.addSubview(usernameLabel)
//        usernameLabel.snp.makeConstraints({ make in
//            make.width.equalToSuperview().offset(20)
//            make.height.equalTo(35)
//            make.centerX.equalToSuperview()
//            make.top.equalTo(topLayoutGuide.snp.bottom).offset(10)
//        })
//
//        let editButton = UIButton()
//        editButton.alpha = 0.0
//        editButton.setTitle("Edit", for: .normal)
//        editButton.setTitleColor(Constants.applicationAccentColor, for: .normal)
//        editButton.setTitleColor(.black, for: .highlighted)
//        editButton.addTarget(self, action: #selector(editAction), for: .touchUpInside)
//
//        self.view.addSubview(editButton)
//        editButton.snp.makeConstraints({ make in
//            make.width.equalTo(60)
//            make.height.equalTo(40)
//            make.centerX.equalToSuperview()
//            make.top.equalTo(usernameLabel.snp.bottom).offset(5)
//        })
        
        setupBannerAd()
        
        view.addSubview(bannerAdView)
        bannerAdView.snp.makeConstraints({ make in
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
            make.width.equalTo(320)
            make.height.equalTo(50)
        })
        
        optionsCollectionView.delegate = self
        optionsCollectionView.dataSource = self
        
        view.addSubview(optionsCollectionView)
        optionsCollectionView.snp.makeConstraints({ make in
            make.width.equalToSuperview()
            make.bottom.equalTo(bannerAdView.snp.top)
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(15)
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
            aLabel.textColor = .backgroundColor
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
        cell.backgroundColor = .backgroundColorReversed
        

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
            case 0:
                let configVC = ConfigViewController()
                self.navigationController?.pushViewController(configVC, animated: true)
                break
            case 1:
                BartleByNotificationCenter.getUserAuthorizationStatus { status in
                    if status == .notDetermined {
                        DispatchQueue.main.async {

                            let introNotificationVC = IntroNotificationViewController()
                            self.present(introNotificationVC, animated: true, completion: nil)
                        }
                    } else if status == .denied {
                        self.goTosettingsmessage(title: "Notifications off", message: "Notifications are turned off for BartleBy. Go to settings to turn it back on?")
                    } else {
                        DispatchQueue.main.async {
                            let notificationVC = NotificationViewController()
                            self.navigationController?.pushViewController(notificationVC, animated: true)
                        }
                    }
                }
            case 2:
                let statsVC = StatsViewController()
                self.navigationController?.pushViewController(statsVC, animated: true)
                break
            case 3:
                let removeAdStoreVC = StoreViewController()
                self.navigationController?.pushViewController(removeAdStoreVC, animated: true)
//                self.stockAlertMessage(title: "Coming Soon..", message: "You will be able to purchase items on this app to enhnace your experience.")
                break
            case 4:
                let helpVC = HelpViewController()
                self.navigationController?.pushViewController(helpVC, animated: true)
                break
            case 5:
                let aboutVC = AboutViewController()
                self.navigationController?.pushViewController(aboutVC, animated: true)
                break
            case 6:
                let bioVC = BiometricSetupViewController()
                self.navigationController?.pushViewController(bioVC, animated: true)
                break
            case 7:
                if let hasLoggedIn = UserDefaults.standard.bool(forKey: Constants.userHasLoggedIn) as? Bool {
                    if hasLoggedIn {
                        stockAlertMessage(title: "", message: "You have already logged in.")
                    } else {
                        let emailVC = EmailLoginViewController()
                        self.navigationController?.pushViewController(emailVC, animated: true)
                    }
                }
                break
            default:
                print("default")
                break
        }

        self.optionsCollectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 30, height: 60)
    }
}
