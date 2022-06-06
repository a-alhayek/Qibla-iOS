//
//  AladhanDateFormatter.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/19/22.
//

import Foundation

class AladhanDateFormatter: DateFormatter {
    func getAladhanString(from date: Date) -> String {
        dateFormat = "dd-MM-yyyy"
        return string(from: date)
    }

    func convertTimeToTweleveHour(_ text: String) -> String? {
        dateFormat = "HH:mm"
        if let date = self.date(from: text) {
            dateFormat = "h:mm a"
            return string(from: date)
        }
        return nil
    }
}
