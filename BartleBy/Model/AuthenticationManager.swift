//
//  AuthenticationManager.swift
//  BartleBy
//
//  Created by Andy Wong on 7/10/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthenticationManager {
    static var userAllowsAuthentication: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constants.allowAuthentication)
        }
    }
    
    static func getUserAvailableBiometricType() -> String {
        let context = LAContext()
        if #available(iOS 11, *) {
            let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch(context.biometryType) {
            case .none:
                return ""
            case .touchID:
                return "Touch ID"
            case .faceID:
                return "Face ID"
                
            }
        } else {
            return ""
        }
    }
    
    static func authenticateUser() {
        if userAllowsAuthentication {
            let bioVC = BiometricViewController()
            
            if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
                window.rootViewController?.present(bioVC, animated: true, completion: nil)
            }
            let context = LAContext()
            var error: NSError?
            
            context.localizedCancelTitle = "Cancel"
            
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                print("error; \(error)")
            }
            
            let reason = "Log in to access notes"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
                if success {
                    // Move to the main thread because a state update triggers UI changes.
                    DispatchQueue.main.async {
                        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
                            window.rootViewController?.dismiss(animated: true, completion: { print("Auth Sucessful")})
                        }
                    }
                } else {
                    print(error?.localizedDescription ?? "Failed to authenticate")
                    bioVC.showContent()
                }
            }
        }
    }
    
    static func authenticateUser(_ completion: @escaping (_ isSucess: Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        context.localizedCancelTitle = "Cancel"
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            print("error; \(error)")
        }
        
        let reason = "Log in to access notes"
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
            if success {
                // Move to the main thread because a state update triggers UI changes.
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
