//
//  Note.swift
//  BartleBy
//
//  Created by Andy Wong on 12/23/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

class Note: NSObject {
    var note: String
    var dateCreated: String
    var id: String
    var templateType: String
    
    init(note: String, dateCreated: String, id: String, templateType: String) {
        self.note = note
        self.dateCreated = dateCreated
        self.id = id
        self.templateType = templateType
    }
}
