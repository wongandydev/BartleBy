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
}
