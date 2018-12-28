//
//  ConfigViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 12/25/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit
import Firebase

class ConfigViewController: UIViewController {
    @IBOutlet weak var optionSegmentControl: UISegmentedControl!
    @IBOutlet weak var numberPicker: UIPickerView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBAction func optionSegmentChanged(_ sender: Any) {
        setTypeLabel()
    }
    var ref: DatabaseReference!
    var number: [Int] = Array(0...1000)
    var selectedNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberPicker.delegate = self
        numberPicker.dataSource = self
        
        ref = Database.database().reference()
        
        getSelectedNumber(completion: { number in
            self.selectedNumber = number
            self.numberPicker.selectRow(number, inComponent: 0, animated: true)
            self.numberLabel.text = String(number)
        })
        
        getTemplateType(completion: { templateType in
            if templateType == Template.Option.grateful.rawValue {
                self.optionSegmentControl.selectedSegmentIndex = 0
            } else {
                self.optionSegmentControl.selectedSegmentIndex = 1
            }
            
            self.setTypeLabel()
        })
    
        
        saveButton()
        cancelButton()
    }
    
    func setTypeLabel() {
        switch  optionSegmentControl.selectedSegmentIndex {
        case 0:
            typeLabel.text = "things I am grateful for"
        case 1:
            typeLabel.text = "minutes of free write"
        default:
            break
        }
    }
    
    func setTemplateType(type: String) {
        self.ref.child("users/\(UserDefaults.standard.object(forKey: "userUID")!)/template/templateType").setValue(type)
    }
    
    func getTemplateType(completion: @escaping (String) -> Void) {
        ref.child("users/\(UserDefaults.standard.object(forKey: "userUID")!)/template/templateType").observe(DataEventType.value , andPreviousSiblingKeyWith: { (snapshot, error) in
            if let templateType = snapshot.value as? String{
                completion(templateType)
            } else {
                self.setTemplateType(type: Template.Option.grateful.rawValue)
                completion(Template.Option.grateful.rawValue)
            }
        })
        
    }
    
    func getSelectedNumber(completion: @escaping (Int) -> Void) {
        ref.child("users/\(UserDefaults.standard.object(forKey: "userUID")!)/template/templateNumber").observe(DataEventType.value , andPreviousSiblingKeyWith: { (snapshot, error) in
            if let templateNumber = snapshot.value as? Int{
                completion(templateNumber)
            } else {
                self.setSelectedNumber(number: 1)
                completion(1)
            }
        })

    }
    
    func setSelectedNumber(number: Int) {
        self.ref.child("users/\(UserDefaults.standard.object(forKey: "userUID")!)/template/templateNumber").setValue(number)
    }
    
    func saveButton() {
        let saveButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.height-164, width: self.view.frame.width, height: 64))
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor =  UIColor(red:0.18, green:1.00, blue:0.44, alpha:1.0)
        saveButton.addTarget(self, action: #selector(saveNewTemplateSettings), for: .touchUpInside)
        
        self.view.addSubview(saveButton)
    }
    
    func cancelButton() {
        let cancelButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.height-94, width: self.view.frame.width, height: 64))
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = .red
        cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        self.view.addSubview(cancelButton)
    }
    
    @objc func saveNewTemplateSettings() {
        setSelectedNumber(number: selectedNumber)
        switch  optionSegmentControl.selectedSegmentIndex {
            case 0:
                setTemplateType(type: Template.Option.grateful.rawValue)
            case 1:
                setTemplateType(type: Template.Option.freeWrite.rawValue)
            default:
                break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ConfigViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return number.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(number[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedNumber = number[row]
        numberLabel.text = String(number[row])
    }
    
    
}
