//
//  AboutViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 12/26/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit
import Firebase

class AboutViewController: UIViewController {
    var ref: DatabaseReference!
    
    private var aboutTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        if Reachability.isConnectedToNetwork() {
            getAboutText()
        }
        
        layoutSubviews()
    }
    
    fileprivate func layoutSubviews() {
        self.view.backgroundColor = .white
        self.edgesForExtendedLayout = .init(rawValue: 0)
        
        aboutTextView = UITextView()
        aboutTextView.contentInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        aboutTextView.scrollIndicatorInsets = aboutTextView.contentInset
        aboutTextView.textAlignment = .justified
        aboutTextView.setContentOffset(.zero, animated: false)
        aboutTextView.text = "BartleBy was created because I felt the need to write my thoughts down everyday. But to do this with a note taking app was cumbersome. I constantly forgot to write my thoughts at the end or the day. I couldn't find a good solution on the app store. So I created BartleBy. BartleBy aims to be an app that helps users with writing down what they are grateful for or their thoughts through free write. The app is customizable so you can write 1 thing you are grateful for or 1000 things you are grateful for .You can also set a time limit for free write. After the time is reached, the note is saved and you can no longer continue writing, giving you the true free writing experience. \n\nI hope you enjoy the app and review it on the app store. You can support me by clicking on the ads or clicking the support page and watch a few ads. All help is greatly appreciated. \n\n\nThank you."
        aboutTextView.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        aboutTextView.isEditable = false
        aboutTextView.isSelectable = false
        
        view.addSubview(aboutTextView)
        aboutTextView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        getAboutText()
    }
    
    func getAboutText() {
        ref.child("documents/about").observe(.value, with: {snapshot in
            if let value = snapshot.value as? [ String] {
                self.aboutTextView.text = value.first
            }
        })
    }
}
