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
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveNewTemplateSettings()
    }
    
    @IBAction func optionSegmentChanged(_ sender: Any) {
        setTypeLabel()
    }
    var ref: DatabaseReference!
    var number: [Int] = Array(1...1000)
    var selectedNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberPicker.delegate = self
        numberPicker.dataSource = self
        
        ref = Database.database().reference()
        
        getSelectedNumber(completion: { number in
            self.selectedNumber = number
            self.numberPicker.selectRow(number-1, inComponent: 0, animated: true)
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
    }
    
    func setTypeLabel() {
        switch  optionSegmentControl.selectedSegmentIndex {
        case 0:
            if numberPicker.selectedRow(inComponent: 0) < 1 {
                typeLabel.text = "thing I am grateful for"
            } else {
                typeLabel.text = "things I am grateful for"
            }
            
        case 1:
            if numberPicker.selectedRow(inComponent: 0) < 1 {
                typeLabel.text = "minute of free write"
            } else {
                typeLabel.text = "minutes of free write"
            }
        default:
            break
        }
    }
    
    func getTemplateType(completion: @escaping (String) -> Void) {
        ref.child("users/\(UserDefaults.standard.object(forKey: "userUID")!)/template/templateType").observeSingleEvent(of: .value , with: { snapshot in
            if let templateType = snapshot.value as? String{
                completion(templateType)
            } else {
                self.setTemplateType(type: Template.Option.grateful.rawValue)
                completion(Template.Option.grateful.rawValue)
            }
        })
        
    }
    
    func getSelectedNumber(completion: @escaping (Int) -> Void) {
        ref.child("users/\(UserDefaults.standard.object(forKey: "userUID")!)/template/templateNumber").observeSingleEvent(of: DataEventType.value , with: { snapshot in
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
    
    func setTemplateType(type: String) {
        self.ref.child("users/\(UserDefaults.standard.object(forKey: "userUID")!)/template/templateType").setValue(type)
    }

    func saveNewTemplateSettings() {
        setSelectedNumber(number: selectedNumber)
        switch  optionSegmentControl.selectedSegmentIndex {
            case 0:
                setTemplateType(type: Template.Option.grateful.rawValue)
            case 1:
                setTemplateType(type: Template.Option.freeWrite.rawValue)
            default:
                break
        }
        self.navigationController?.popViewController(animated: true)
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
        setTypeLabel()
    }
    
    
}
