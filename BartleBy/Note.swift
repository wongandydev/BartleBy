//
//  Note.swift
//  BartleBy
//
//  Created by Andy Wong on 12/23/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

class Note: NSObject {
    var date: String
    var note: String
    var dateCreated: String
    var id: String
    var templateType: String
    
    init(date: String, note: String, dateCreated: String, id: String, templateType: String) {
        self.date = date
        self.note = note
        self.dateCreated = dateCreated
        self.id = id
        self.templateType = templateType
    }
}
