//
//  PrayerTime.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 6/1/22.
//

import Foundation
import RealmSwift
import SwiftUI
struct SalatNameAndTime: Identifiable {
    var id = UUID()
    private let dateFormatter = AladhanDateFormatter()
    let salatName: LocalizedStringKey
    let salatTime: String

    var salatTime12: String {
        dateFormatter.convertTimeToTweleveHour(salatTime) ?? salatTime
    }
}
class AladahnTimeResponse: Decodable {
    let data: AladahnPrayerTimeAndDate
}

class AladahnCalenderResponse: Decodable {
    let data: [AladahnPrayerTimeAndDate]
}

class AladahnPrayerTimeAndDate: Object, Decodable {
    
    @Persisted var timings: PrayerTime?
    @Persisted var date: PrayerDate?
    @Persisted var method: Int?

    var exactDate: String? {
        date?.gregorian?.date
    }

    var weekday: String? {
        
        guard let prayerWD = date?.gregorian?.weekday?.weekday
        else { return nil}
           
        return AladhanDateFormatter()
            .getWeekday(offset: prayerWD.rawValue - 1)
    }

    var prayerTimings: PrayerTime {
        timings!
    }

    var prayerDate: PrayerDate {
        return date!
    }

    var prayers: [SalatNameAndTime] {
        [SalatNameAndTime(salatName: PrayersName.Fajr.rawValue, salatTime: timings!.fajr),
         SalatNameAndTime(salatName: PrayersName.sunrise.rawValue, salatTime: timings!.sunrise),
         SalatNameAndTime(salatName: PrayersName.dhuhr.rawValue, salatTime: timings!.dhuhr),
         SalatNameAndTime(salatName: PrayersName.asr.rawValue, salatTime: timings!.asr),
         SalatNameAndTime(salatName: PrayersName.maghrib.rawValue, salatTime: timings!.maghrib),
         SalatNameAndTime(salatName: PrayersName.isha.rawValue, salatTime: timings!.isha),
         SalatNameAndTime(salatName: PrayersName.imsak.rawValue, salatTime: timings!.imsak)
        ]
    }
}

enum PrayersName: LocalizedStringKey {
    case Fajr
    case sunrise = "Sunrise"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"
    case imsak = "Imsak"
}


class PrayerTime: Object, Decodable {
    @Persisted var fajr: String
    @Persisted var sunrise: String
    @Persisted var dhuhr: String
    @Persisted var asr: String
    @Persisted var maghrib: String
    @Persisted var isha: String
    @Persisted var imsak: String

    enum CodingKeys: String, CodingKey {
        case fajr = "Fajr"
        case sunrise = "Sunrise"
        case dhuhr = "Dhuhr"
        case asr = "Asr"
        case maghrib = "Maghrib"
        case isha = "Isha"
        case imsak = "Imsak"
    }
}

class PrayerDate: Object, Decodable {
    @Persisted var readable: String
    @Persisted var timestamp: String
    @Persisted var hijri: AladahnDate?
    @Persisted var gregorian: AladahnDate?
    
}

class AladahnDate: Object, Decodable {
    @Persisted var date: String
    @Persisted var format: String
    @Persisted var day: String

    @Persisted var year: String
    @Persisted var month: Month?
    @Persisted var weekday: Weekday?
    //let holidays: [String]?
}

class Month: Object, Decodable {
    @Persisted var number: Int
    @Persisted var en: String
    @Persisted var ar: String?
}

class Weekday: Object, Decodable {
    @Persisted var en: String
    @Persisted var ar: String?
    
    var weekday: PrayerWeekDays? {
        PrayerWeekDays(string: en)
    }
}
