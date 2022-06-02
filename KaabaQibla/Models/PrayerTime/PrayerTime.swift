//
//  PrayerTime.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 6/1/22.
//

import Foundation
struct SalatNameAndTime: Identifiable {
    var id = UUID()
    
    let salatName: String
    let salatTime: String
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
        []
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
