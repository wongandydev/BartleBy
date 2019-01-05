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
    
    @IBOutlet weak var aboutTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        aboutTextView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 65, right: 20)
        aboutTextView.scrollIndicatorInsets = self.aboutTextView.contentInset
        aboutTextView.setContentOffset(.zero, animated: false)
        
        getAboutText()
        
        cancelButton(title: "Go Back", color: .red)
    }
    
    func getAboutText() {
        ref.child("documents/about").observe(.value, with: {snapshot in
            if let value = snapshot.value as? [ String] {
                self.aboutTextView.text = value.first
            }
        })
    }
}
