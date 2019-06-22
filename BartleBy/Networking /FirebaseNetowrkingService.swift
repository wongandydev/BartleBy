//
//  Networking.swift
//  BartleBy
//
//  Created by Andy Wong on 6/21/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import Firebase

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
        let userUID = UIDevice.current.identifierForVendor?.uuidString
        UserDefaults.standard.set(userUID, forKey: "userUID")
        
        //sign up user with default
        Database.database().reference().child("users/\(userUID!)/stats/streak").setValue(0)
        Database.database().reference().child("users/\(userUID!)/stats/totalNotes").setValue(0)
        Database.database().reference().child("users/\(UserDefaults.standard.object(forKey: "userUID")!)/template/templateNumber").setValue(5)
        Database.database().reference().child("users/\(UserDefaults.standard.object(forKey: "userUID")!)/template/templateType").setValue(Template.Option.grateful.rawValue)
        
        UserDefaults.standard.synchronize()
    }
}
