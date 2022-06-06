//
//  PrayerTime.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 6/1/22.
//

import Foundation
struct SalatNameAndTime: Identifiable {
    var id = UUID()
    private let dateFormatter = AladhanDateFormatter()
    let salatName: String
    let salatTime: String

    var salatTime12: String {
        dateFormatter.convertTimeToTweleveHour(salatTime) ?? salatTime
    }
}
class AladahnTimeResponse: Decodable {
    let data: AladahnPrayerTimeAndDate
}

class AladahnPrayerTimeAndDate: Decodable {
    let timings: PrayerTime
    let date: PrayerDate
    
    var prayerTimings: PrayerTime {
        timings
    }

    var prayerDate: PrayerDate {
        return date
    }
    var prayers: [SalatNameAndTime] {
        [SalatNameAndTime(salatName: PrayerTime.PrayersName.Fajr.rawValue, salatTime: timings.fajr),
         SalatNameAndTime(salatName: PrayerTime.PrayersName.sunrise.rawValue, salatTime: timings.sunrise),
         SalatNameAndTime(salatName: PrayerTime.PrayersName.dhuhr.rawValue, salatTime: timings.dhuhr),
         SalatNameAndTime(salatName: PrayerTime.PrayersName.asr.rawValue, salatTime: timings.asr),
         SalatNameAndTime(salatName: PrayerTime.PrayersName.maghrib.rawValue, salatTime: timings.maghrib),
         SalatNameAndTime(salatName: PrayerTime.PrayersName.isha.rawValue, salatTime: timings.isha),
         SalatNameAndTime(salatName: PrayerTime.PrayersName.imsak.rawValue, salatTime: timings.imsak)
        ]
    }
}


class PrayerTime: Decodable {
    let fajr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String
    let imsak: String

    enum PrayersName: String {
        case Fajr
        case sunrise = "Sunrise"
        case dhuhr = "Dhuhr"
        case asr = "Asr"
        case maghrib = "Maghrib"
        case isha = "Isha"
        case imsak = "Imsak"
    }

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

class PrayerDate: Decodable {
    let readable: String
    let timestamp: String
    
}

class AladahnDate: Decodable {
    let hijri: PrayerDate
    let gregorian: PrayerDate
    
    class PrayerDate: Decodable {
        let date: String
        let format: String
        let day: String
        let weekday: [String: String]
        let month: [String: String]
        let year: String
        let holidays: [String]?
    }
}
