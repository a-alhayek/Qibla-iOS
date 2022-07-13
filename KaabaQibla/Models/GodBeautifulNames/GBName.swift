//
//  GBName.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 7/12/22.
//

import Foundation
import RealmSwift

class GBNamesResponse: Decodable {
    let data: [GBName]
}

class GBName: Object, Decodable {
    /// numbered from 1 to 99
    @Persisted(primaryKey: true) var number: Int = 0
    @Persisted var name: String? = ""
    @Persisted var transliteration: String? = ""
    @Persisted var en: Translation?
    
    var translation: String {
        en!.meaning!
    }

    var arabicName: String {
        name!
    }

    convenience init(number: Int, name: String, en: Translation) {
        self.init()
        self.number = number
        self.name = name
        self.en = en
        
    }
}
extension GBName: Identifiable {
    
}

class Translation: EmbeddedObject, Decodable {
    @Persisted var meaning: String?
    convenience init(meaning: String) {
        self.init()
        self.meaning = meaning
    }
}
