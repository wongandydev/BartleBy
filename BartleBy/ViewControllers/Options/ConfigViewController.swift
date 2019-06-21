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
    /* Manage Type of Writing */
    
    private var titleLabel: UILabel!
    private var optionSegmentControl: UISegmentedControl!
    private var numberPicker: UIPickerView!
    private var numberLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var saveButton: UIButton!
    
    @objc func saveButtonTapped(_ sender: Any) {
        saveNewTemplateSettings()
    }
    
    @objc func optionSegmentChanged(_ sender: Any) {
        setLabels()
    }
    
    var ref: DatabaseReference!
    var number: [Int] = Array(1...1000)
    var selectedNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubviews()
        
        ref = Database.database().reference()
        
        getSelectedNumber(completion: { number in
            self.selectedNumber = number
            self.numberPicker.selectRow(number-1, inComponent: 0, animated: true)
            self.setLabels()
        })
        
        getTemplateType(completion: { templateType in
            if templateType == Template.Option.grateful.rawValue {
                self.optionSegmentControl.selectedSegmentIndex = 0
            } else {
                self.optionSegmentControl.selectedSegmentIndex = 1
            }
            
            self.setLabels()
        })
    }
    
    fileprivate func layoutSubviews() {
        self.view.backgroundColor = .white
        
        titleLabel = UILabel()
        titleLabel.text = "What template would you like to use?"
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints({ make in
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(10)
        })
        
        optionSegmentControl = UISegmentedControl()
        optionSegmentControl.insertSegment(withTitle: "Grateful", at: 0, animated: false)
        optionSegmentControl.insertSegment(withTitle: "Free Write", at: 1, animated: false)
        optionSegmentControl.tintColor = Constants.applicationAccentColor
        optionSegmentControl.addTarget(self, action: #selector(optionSegmentChanged(_:)), for: .valueChanged)
        
        self.view.addSubview(optionSegmentControl)
        optionSegmentControl.snp.makeConstraints({ make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        })
        
        
        numberPicker = UIPickerView()
        numberPicker.delegate = self
        numberPicker.dataSource = self
        
        self.view.addSubview(numberPicker)
        numberPicker.snp.makeConstraints({ make in
            make.width.equalToSuperview()
            make.height.equalToSuperview().dividedBy(4)
            make.top.equalTo(optionSegmentControl.snp.bottom).offset(20)
        })
        
        numberLabel = UILabel()
        numberLabel.numberOfLines = 0
        numberLabel.textAlignment = .center
        
        self.view.addSubview(numberLabel)
        numberLabel.snp.makeConstraints({ make in
            make.top.equalTo(numberPicker.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        })
        
        saveButton = UIButton()
        saveButton.backgroundColor = .green
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.green, for: .highlighted)
        saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
        
        self.view.addSubview(saveButton)
        saveButton.snp.makeConstraints({ make in
            make.width.equalToSuperview()
            make.height.equalTo(Constants.bottomButtonHeight)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
        })
        
        descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .justified
        
        self.view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints({ make in
            make.top.equalTo(numberLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(saveButton.snp.top)
        })
    }
    
    func setLabels() {
        switch  optionSegmentControl.selectedSegmentIndex {
        case 0:
            numberLabel.text = selectedNumber > 1 ? "I want to write \(selectedNumber) things I am grateful for." : "I want to write \(selectedNumber) thing I am grateful for."
            descriptionLabel.text = "By setting grateful writing, you are listing out what you grateful for."
            break
        case 1:
            numberLabel.text = selectedNumber > 1 ? "I want to write \(selectedNumber) minutes of free write." : "I want to write \(selectedNumber) minute of free write."
            descriptionLabel.text = "By setting free write, you are writing for a certain amount of time. The note will immediately stop after the time is depleated. Don't worry, you can leave the app and the timer will pause. You can also finish early if you'd like."
            break
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
        setLabels()
    }
    
    
}
