//
//  Networking.swift
//  BartleBy
//
//  Created by Andy Wong on 6/21/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import Firebase
import Mixpanel

class FirebaseNetworkingService {
    static let ref = Database.database().reference()
    
    static func isConnectedToInternet(_ completion: @escaping (_ isConnected: Bool) -> Void) {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool {
                completion(connected)
            } else {
                completion(false)
            }
        })
    }
    
    static func signUpDefaultUser() {
        let userID = UIDevice.current.identifierForVendor?.uuidString
        UserDefaults.standard.set(userID, forKey: Constants.userId)
        
        //sign up user with default
        if let userID = userID {
            Database.database().reference().child("users/\(userID)/stats/streak").setValue(0)
            Database.database().reference().child("users/\(userID)/stats/totalNotes").setValue(0)
            Database.database().reference().child("users/\(userID)/template/templateNumber").setValue(5)
            Database.database().reference().child("users/\(userID)/template/templateType").setValue(Template.grateful.rawValue)
            Database.database().reference().child("users/\(userID)/userId").setValue("\(userID)")
            
            updateLoginActivity(userId: userID)
            
            Analytics.logEvent("newUserCreated", parameters: ["userID": userID])
            Mixpanel.mainInstance().track(event: "newUserCreated", properties: ["userID": userID])
            
            UserDefaults.standard.synchronize()
        }
    }
    
    static func updateLoginActivity(userId: String) {
        let currentTime = Int().currentTimestamp()
        Database.database().reference().child("users/\(userId)/loginActivity").updateChildValues(["\(currentTime)" : ["userDateTime": Helper.sharedInstance.dateToString(date: Date()), "time": currentTime]])
        Database.database().reference().child("users/\(userId)/lastLogin").setValue(currentTime)
    }
    
    static func signUpUserWithEmail(email: String, password: String, _ completion: @escaping (_ isCompleted: Bool) -> Void) {
        guard let userID = UserDefaults.standard.value(forKey: Constants.userId) as? String else {
            Analytics.logEvent("userEmailCreationFailed", parameters: ["error": "Could not get userID from UserDefaults"])
            Mixpanel.mainInstance().track(event: "userEmailCreationFailed", properties: ["error": "Could not get userID from UserDefaults"])
            completion(false)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
            if let error = error {
                print("error signing up user with email")
                Analytics.logEvent("userEmailCreationFailed", parameters: ["error": error.localizedDescription])
                Mixpanel.mainInstance().track(event: "userEmailCreationFailed", properties: ["error": error.localizedDescription])
                completion(false)
            } else {
                postUserEmailFirebaseUID(userID: userID, email: email, firebaseUID: getCurrentFirebaseUserUID(), { isCompleted in
                    if isCompleted {
                        completion(true)
                        Analytics.logEvent("userEmailCreation", parameters: ["email": email, "userId": userID])
                        Mixpanel.mainInstance().track(event: "userEmailCreation", properties: ["email": email, "userId": userID])
                    }
                })
            }
        })
    }
    
    static func postUserEmailFirebaseUID(userID: String, email: String, firebaseUID: String, _ completion: @escaping (_ isCompleted: Bool) -> Void) {
        let postValue = ["email" : email, "firebaseUID": firebaseUID]
        
        ref.child("users/\(userID)").updateChildValues(postValue, withCompletionBlock: { error, ref in
            if let error = error {
                completion(false)
            }
            
            completion(true)
        })
    }
    
    static func loginUserWithEmail(email: String, password: String, _ completion: @escaping (_ isCompleted: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { authResult, error in
            if let error = error {
                completion(false)
                print("login failed. \(email)")
            } else {
                completion(true)
                print("login sucessful. \(email)")
            }
        })
    }
    
    static func forgotPassword(email: String, _ completion: @escaping (_ isSuccess: Bool) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: { error in
            if let error = error {
                print("Error sending message")
                completion(false)
            }
            
            completion(true)
            print("success")
        })

    }
    
    static func getNoteTotal(_ completion: @escaping (_ totalNotes: Int) -> Void) {
        if let userID = UserDefaults.standard.value(forKey: Constants.userId) as? String {
            ref.child("users/\(userID)").observeSingleEvent(of: .value , with: { snapshot in
                if let userData = snapshot.value as? [String: AnyObject]{
                    if let notes = userData["notes"] as? [String: AnyObject]{
                        completion(notes.count)
                    }
                } else {
                    completion(-1)
                }
            })
        }
        
    }
    
    static func syncCurrentUserDataWithLoginUser(previousUserID: String, currentFirebaseUID: String, _ completion: @escaping (_ isCompleted: Bool) -> Void) {
        var previousUserData = [String: AnyObject]()
//        var currentUserData = [String: AnyObject]()
        
        getUserInfo(userId: previousUserID, { userData in
            if let userData = userData {
                if let usertemplate = userData["template"] as? [String: AnyObject],
                    let stats = userData["stats"] as? [String: AnyObject],
                    let loginActivity = userData["loginActivity"] as? [String: AnyObject] {
                    
                    if let notes = userData["notes"] as? [String: AnyObject] {
                        getUserInfoFirebase(uid: currentFirebaseUID, { userData in
                            if let userId = userData?.keys.first as? String {
                                UserDefaults.standard.set(userId, forKey: Constants.userId)
                                ref.child("users/\(userId)/notes").updateChildValues(notes)
                                ref.child("users/\(userId)/loginActivity").updateChildValues(loginActivity)
                                ref.child("users/\(userId)/stats").setValue(stats)
                                ref.child("users/\(userId)/template").setValue(usertemplate)
                                updateLoginActivity(userId: userId)
                                completion(true)
                            } else {
                                completion(false)
                                print("failed to get login user userId")
                            }
                        })
                    } else {
                        //User have no notes
                        getUserInfoFirebase(uid: currentFirebaseUID, { userData in
                            if let userId = userData?.keys.first as? String {
                                UserDefaults.standard.set(userId, forKey: Constants.userId)
                                ref.child("users/\(userId)/loginActivity").updateChildValues(loginActivity)
                                ref.child("users/\(userId)/stats").setValue(stats)
                                ref.child("users/\(userId)/template").setValue(usertemplate)
                                updateLoginActivity(userId: userId)
                                completion(true)
                            } else {
                                completion(false)
                                print("failed to get login user userId")
                            }
                        })
                    }
                }
                
                //Save new userId here
                
            }
        })


    }
    
    static func syncNotes(userId: String, notes: [String: AnyObject]) {
        ref.child("users/\(userId)/notes").updateChildValues(notes)
    }
    
    static func getUserInfo(userId: String, _ completion: @escaping (_ userData: [String: AnyObject]?) -> Void) {
        ref.child("users/\(userId)").observeSingleEvent(of: .value, with: { snapshot in
            guard let userData = snapshot.value as? [String: AnyObject] else {
                completion(nil)
                return
            }
            
            completion(userData)
        })
    }
    
    static func getUserInfoFirebase(uid: String, _ completion: @escaping (_ userData: [String: AnyObject]?) -> Void) {
        ref.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let users = snapshot.value as? [String: AnyObject] else {
                completion(nil)
                return
            }
            
        
            completion(users.filter({ $0.value["firebaseUID"] as? String == uid }))
        })
    }
    
    static func getCurrentFirebaseUserUID() -> String {
        guard let firebaseUID = Auth.auth().currentUser?.uid else { return "" }
        return firebaseUID
    }
}
