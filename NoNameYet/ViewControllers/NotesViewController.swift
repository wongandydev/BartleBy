//
//  ViewController.swift
//  NoNameYet
//
//  Created by Andy Wong on 12/20/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {

    @IBOutlet weak var notesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "No Name Yet"
        addButton()
    }
    
    func addButton() {
        let addButton = UIButton(frame: CGRect(x: self.view.frame.width - 70, y: self.view.frame.height - 150, width: 60, height: 60))
        addButton.layer.cornerRadius = 30
        addButton.backgroundColor = .red
        addButton.setTitle("Add", for: .normal)
        addButton.titleLabel?.textColor = .white
        addButton.addTarget(self, action: #selector(addNote), for: .touchUpInside)
        
        self.view.addSubview(addButton)
    }
    
    @objc func addNote() {
        
        print("button tapped")
        if let addNoteViewController = storyboard?.instantiateViewController(withIdentifier: "AddNotesViewController") as? UIViewController {
            self.present(addNoteViewController, animated: true, completion: nil)
        }
    }
}

