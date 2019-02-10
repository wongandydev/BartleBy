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
    
    let aTextView: UITextView = {
        let textView = UITextView()
        textView.contentInset = UIEdgeInsets(top: 10, left: 5, bottom: 65, right: 5)
        textView.scrollIndicatorInsets = textView.contentInset
        textView.setContentOffset(.zero, animated: false)
        textView.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        aTextView.frame = CGRect(x: 0, y: navigationController?.navigationBar.layer.frame.height ?? 200, width: view.frame.width, height: view.frame.height)
        view.addSubview(aTextView)
        getAboutText()
    }
    
    func getAboutText() {
        ref.child("documents/about").observe(.value, with: {snapshot in
            if let value = snapshot.value as? [ String] {
                self.aTextView.text = value.first
            }
        })
    }
}
