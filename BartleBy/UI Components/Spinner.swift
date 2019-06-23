//
//  Spinner.swift
//  BartleBy
//
//  Created by Andy Wong on 6/23/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit

open class Spinner {
    internal static var backgroundView = UIView(frame: .zero)
    internal static var spinner: UIActivityIndicatorView?
    
    public static var spinnerStyle: UIActivityIndicatorView.Style = .whiteLarge
    public static var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
    public static var color: UIColor = .white
    
    public static func start(view: UIView, allowUserInteration: Bool = true) {
        if spinner == nil, let window = UIApplication.shared.keyWindow {
            
            var frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            frame.origin.x = view.frame.size.width/2 - frame.size.width/2
            frame.origin.y = view.frame.size.height/2 - frame.size.height/2
            
            spinner = UIActivityIndicatorView(frame: frame)
            spinner!.backgroundColor = backgroundColor
            spinner!.style = spinnerStyle
            spinner?.layer.cornerRadius = 10
            spinner?.color = color
            spinner!.startAnimating()
            
            if !allowUserInteration { //Do not allow user interation
                backgroundView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height)
                backgroundView.addSubview(spinner!)
                window.addSubview(backgroundView)
            } else {
                window.addSubview(spinner!)
            }
            
            
        }
    }
    
    public static func stop() {
        if spinner != nil {
            spinner!.stopAnimating()
            spinner!.removeFromSuperview()
            backgroundView.removeFromSuperview()
            spinner = nil
        }
    }
    
}

