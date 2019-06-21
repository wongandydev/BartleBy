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
            self.setSelectedNumber(number: number)
            self.numberPicker.selectRow(number-1, inComponent: 0, animated: true)
            self.setLabels()
        })
        
        getTemplateType(completion: { templateType in
            if templateType == Template.Option.grateful.rawValue {
                self.optionSegmentControl.selectedSegmentIndex = 0
            } else {
                self.optionSegmentControl.selectedSegmentIndex = 1
            }
            
            self.setTemplateType(type: templateType)
            self.setLabels()
        })
    }
    
    fileprivate func layoutSubviews() {
        self.view.backgroundColor = .white
        
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bounces = true
        scrollView.contentSize = self.view.frame.size
        
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints({ make in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
        })
        
        let containerView = UIView()
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints({ make in
            make.top.equalToSuperview()
            make.left.equalTo(self.view).inset(10)
            make.right.equalTo(self.view).inset(10)
            make.bottom.equalTo(scrollView)
        })
        
        titleLabel = UILabel()
        titleLabel.text = "What template would you like to use?"
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints({ make in
            make.top.equalToSuperview().offset(15)
            make.left.right.equalToSuperview().inset(10)
        })
        
        optionSegmentControl = UISegmentedControl()
        optionSegmentControl.insertSegment(withTitle: "Grateful", at: 0, animated: false)
        optionSegmentControl.insertSegment(withTitle: "Free Write", at: 1, animated: false)
        optionSegmentControl.tintColor = Constants.applicationAccentColor
        optionSegmentControl.addTarget(self, action: #selector(optionSegmentChanged(_:)), for: .valueChanged)
        
        containerView.addSubview(optionSegmentControl)
        optionSegmentControl.snp.makeConstraints({ make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        })
        
        
        numberPicker = UIPickerView()
        numberPicker.delegate = self
        numberPicker.dataSource = self
        
        containerView.addSubview(numberPicker)
        numberPicker.snp.makeConstraints({ make in
            make.width.equalToSuperview()
            make.height.equalTo(self.view).dividedBy(4)
            make.top.equalTo(optionSegmentControl.snp.bottom).offset(20)
        })
        
        numberLabel = UILabel()
        numberLabel.numberOfLines = 0
        numberLabel.textAlignment = .center
        
        containerView.addSubview(numberLabel)
        numberLabel.snp.makeConstraints({ make in
            make.top.equalTo(numberPicker.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        })
        
        descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .justified
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints({ make in
            make.top.equalTo(numberLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
        })
        
        
        saveButton = UIButton()
        saveButton.backgroundColor = .green
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.green, for: .highlighted)
        saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
        
        containerView.addSubview(saveButton)
        saveButton.snp.makeConstraints({ make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            make.width.equalToSuperview()
            make.height.equalTo(Constants.bottomButtonHeight)
            make.bottom.equalToSuperview()
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
        FirebaseNetworkingService.isConnectedToInternet({ isConnected in
            if isConnected {
                self.ref.child("users/\(UserDefaults.standard.object(forKey: "userUID")!)/template/templateType").observeSingleEvent(of: .value , with: { snapshot in
                    if let templateType = snapshot.value as? String{
                        completion(templateType)
                    } else {
                        completion(Template.Option.grateful.rawValue)
                    }
                })
            } else {
                if let offlineTemplateType = self.getOfflineSelectedTemplateType() {
                    completion(offlineTemplateType)
                }
            }
        })
    }
    
    func getOfflineSelectedTemplateType() -> String? {
        guard let offlineSelectedTemplateType = UserDefaults.standard.value(forKey: "userTemplateType") as? String else { return nil}
        return offlineSelectedTemplateType
    }
    
    func getSelectedNumber(completion: @escaping (Int) -> Void) {
        FirebaseNetworkingService.isConnectedToInternet({ isConnected in
            if isConnected {
                self.ref.child("users/\(UserDefaults.standard.object(forKey: "userUID")!)/template/templateNumber").observeSingleEvent(of: DataEventType.value , with: { snapshot in
                    if let templateNumber = snapshot.value as? Int{
                        completion(templateNumber)
                    } else {
                        completion(1)
                    }
                })
            } else {
                if let offlineNumber = self.getOfflineSelectedNumber() {
                    completion(offlineNumber)
                }
            }
        })
    }
    
    func getOfflineSelectedNumber() -> Int? {
        guard let offlineSelectedNumber = UserDefaults.standard.value(forKey: "userTemplateNumber") as? Int else { return nil}
        return offlineSelectedNumber
    }
    
    func setSelectedNumber(number: Int) {
        self.selectedNumber = number
        if let userUID = UserDefaults.standard.object(forKey: "userUID") {
            self.ref.child("users/\(userUID)/template/templateNumber").setValue(number)
            UserDefaults.standard.setValue(number, forKey: "userTemplateNumber")
        }
    }
    
    func setTemplateType(type: String) {
        
        if let userUID = UserDefaults.standard.object(forKey: "userUID") {
            self.ref.child("users/\(userUID)/template/templateType").setValue(type)
            UserDefaults.standard.setValue(type, forKey: "userTemplateType")
        }
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
