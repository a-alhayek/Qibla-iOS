//
//  PrayerTimeMehod.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/19/22.
//

import Foundation
import RealmSwift
import SwiftUI

class PrayerMethod: Object {
    @Persisted(primaryKey: true) var rawValue: Int
    @Persisted var isSelected: Bool

    init(rawValue: Int) {
        super.init()
        self.rawValue = rawValue
        isSelected = false
    }

    override init() {
        super.init()
    }
}

enum PrayerTimeMehod: Int, Identifiable, CaseIterable {
    var id: Int {
         self.rawValue
    }
    
    case SIA = 0
    case UISK
    case ISNA
    case MWL
    case UQU
    case EGAS
    case IGUT
    case GR
    case KUWAIT
    case QATAR
    case MUIS
    case UQIF
    case DIBT
    case SAMR
    case MCW
    

    var textRepresentation: LocalizedStringKey {
        switch self {
        case .SIA:
            return "Shia Ithna-Ashari"
        case .UISK:
            return "University of Islamic Sciences, Karachi"
        case .ISNA:
            return "Islamic Society of North America"
        case .MWL:
            return "Muslim World League"
        case .UQU:
            return "Umm Al-Qura University, Makkah"
        case .EGAS:
            return "Egyptian General Authority of Survey"
        case .IGUT:
            return "Institute of Geophysics, University of Tehran"
        case .GR:
            return "Gulf Region"
        case .KUWAIT:
            return "Kuwait"
        case .QATAR:
            return "Qatar"
        case .MUIS:
            return "Majlis Ugama Islam Singapura, Singapore"
        case .UQIF:
            return "Union Organization Islamic de France"
        case .DIBT:
            return "Diyanet İşleri Başkanı, Turkey"
        case .SAMR:
            return "Spiritual Administration of Muslims of Russia"
        case .MCW:
            return "Moonsighting Committee Worldwide"
        }
    }
}
