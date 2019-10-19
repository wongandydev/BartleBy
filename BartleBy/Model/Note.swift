//
//  Note.swift
//  BartleBy
//
//  Created by Andy Wong on 12/23/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

class Note: NSObject, NSCoding {
    var note: String
    var dateCreated: String
    var id: String
    var templateType: String
    var isLocked: Bool
    
    init(note: String, dateCreated: String, id: String, templateType: String, isLocked: Bool = false) {
        self.note = note
        self.dateCreated = dateCreated
        self.id = id
        self.templateType = templateType
        self.isLocked = isLocked
    }

    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.note, forKey: "note")
        aCoder.encode(self.dateCreated, forKey: "dateCreated")
        aCoder.encode(self.id, forKey: "noteId")
        aCoder.encode(self.templateType, forKey: "noteTemplateType")
        aCoder.encode(self.isLocked, forKey: "noteIsLocked")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let note = aDecoder.decodeObject(forKey: "note") as? String else { return nil }
        guard let dateCreated = aDecoder.decodeObject(forKey: "dateCreated") as? String else { return nil }
        guard let id = aDecoder.decodeObject(forKey: "noteId") as? String else { return nil }
        guard let templateType = aDecoder.decodeObject(forKey: "noteTemplateType") as? String else { return nil }
        guard let isLocked = aDecoder.decodeBool(forKey: "noteIsLocked") as? Bool else { return nil }
        
        self.init(note: note, dateCreated: dateCreated, id: id, templateType: templateType, isLocked: isLocked)
    }
}
