//
//  PrayerNotification.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 7/5/22.
//

import Foundation
import UserNotifications

class NotificationManagerImp: NSObject, UNUserNotificationCenterDelegate {
    static var sharedInstance: NotificationManagerImp?
    var settings: UNAuthorizationStatus = .notDetermined

    static func current() -> NotificationManagerImp {
        return NotificationManagerImp.sharedInstance!
    }

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func registerPushNotificationCatagories() {
        let aladahn = UNNotificationCategory(identifier: PrayerNotificationCatagory.aladahn.rawValue,
                               actions: [],
                               intentIdentifiers: [],
                               hiddenPreviewsBodyPlaceholder: "")
        UNUserNotificationCenter.current().setNotificationCategories([aladahn])
    }

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        do {
            let isAuthorized = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            print("Notification is authorized \(isAuthorized.description)")
        } catch {
            print(error)
        }
    }

    func checkNotificationStatus() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] settings in
            self?.settings = settings.authorizationStatus
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        UNNotificationPresentationOptions.init()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print(response.description)
    }

    func registerNotification(with timeAndDate: AladahnPrayerTimeAndDate) async {
        let currentDateText = AladhanDateFormatter().getAladhanString(from: Date())
        guard
            let weekday = timeAndDate.date?.gregorian?.weekday?.weekday?.rawValue,
              let dateText = timeAndDate.exactDate,
                dateText >= currentDateText else { return }
        
        let prayerNotification = PrayerNotification.allCases
        for prayer in prayerNotification {
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            dateComponents.weekday = weekday
            let timeNow = timeAndDate.prayers[prayer.offset].salatTime.split(separator: ":")
            let hour = timeNow[0]
            let min = timeNow[1]
            dateComponents.hour = Int(hour)
            dateComponents.minute = Int(min)

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let id = prayer.notificationIdenifier + dateText
            do {
                let current = UNUserNotificationCenter.current()
                try await current.add(UNNotificationRequest(identifier: id,
                                                                             content: prayer.notification,
                                                                             trigger: trigger))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

enum PrayerNotificationCatagory: String {
    case aladahn
}

enum PrayerNotification: String, CaseIterable {
    case fajer
    case duhar
    case asar
    case maghrib
    case isha

    var notificationIdenifier: String {
        return "KaabaQibla_\(self.rawValue)_!"
    }

    var notification: UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Athan Salat Al\(rawValue)"
        content.body = "Allah Akbar, Allah Akbar"
        content.categoryIdentifier = PrayerNotificationCatagory.aladahn.rawValue
        content.sound = UNNotificationSound(named: .init("Adhan_1.caf"))
        return content
    }

    var offset: Int {
        switch self {
        case .fajer:
            return 0
        case .duhar:
            return 2
        case .asar:
            return 3
        case .maghrib:
            return 4
        case .isha:
            return 5
        }
    }
}

enum PrayerWeekDays: Int {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    init?(string: String) {
        switch string {
        case "Sunday":
            self = .sunday
        case "Monday":
            self = .monday
        case "Tuesday":
            self = .tuesday
        case "Wednesday":
            self = .wednesday
        case "Thursday":
            self = .thursday
        case "Friday":
            self = .friday
        case "Saturday":
            self = .saturday
        default:
            return nil
        }
    }
}
