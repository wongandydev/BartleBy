//
//  Template.swift
//  BartleBy
//
//  Created by Andy Wong on 12/24/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

class Template {
    enum Option:String {
        case grateful
        case freeWrite
    }
    
    var option: Option
    
    init(option: Option) {
        self.option = option
    }
}
