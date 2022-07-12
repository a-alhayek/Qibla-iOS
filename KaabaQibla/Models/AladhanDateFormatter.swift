//
//  AladhanDateFormatter.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/19/22.
//

import Foundation

class AladhanDateFormatter: DateFormatter {
    let calender = Calendar.current
    /// change local to english.
    private func changeLocalToEn() {
        locale = Locale(identifier: "en_us")
    }
    func getAladhanString(from date: Date) -> String {
        changeLocalToEn()
        dateFormat = "dd-MM-yyyy"
        return string(from: date)
    }

    func getDayFrom(date: Date) -> String {
        let weekdayIndex = calendar.dateComponents([.weekday], from: date).weekday!
        
        let weekday = getWeekday(offset: weekdayIndex - 1)
        return weekday
    }

    func getAladhanDate(from string: String) -> Date? {
        changeLocalToEn()
        dateFormat = "dd-MM-yyyy"
        return date(from: string)
    }

    func convertTimeToTweleveHour(_ text: String) -> String? {
        dateFormat = "HH:mm"
        if let date = self.date(from: text) {
            dateFormat = "h:mm a"
            return string(from: date)
        }
        return nil
    }

    func getYear(from date: Date) -> String {
        String(getAladhanString(from: date).split(separator: "-")[2])
    }

    func getWeekday(offset: Int) -> String {
        calender.weekdaySymbols[offset]
    }

    func getMonth(from date: Date) -> String {
        String(getAladhanString(from: date).split(separator: "-")[1])
    }
}
