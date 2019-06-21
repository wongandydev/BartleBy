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
        
        layoutSubviews()
    }
    
    fileprivate func layoutSubviews() {
        self.view.backgroundColor = .white
        
        aboutTextView = UITextView()
        aboutTextView.contentInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        aboutTextView.scrollIndicatorInsets = aboutTextView.contentInset
        aboutTextView.setContentOffset(.zero, animated: false)
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
