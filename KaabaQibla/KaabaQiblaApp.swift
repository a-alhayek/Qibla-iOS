//
//  KaabaQiblaApp.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/10/22.
//
import UIKit
import SwiftUI

@main
@MainActor
struct KaabaQiblaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

@MainActor
class AppDelegate: NSObject, UIApplicationDelegate {
    var notificaitonManager: NotificationManagerImp?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        notificaitonManager = NotificationManagerImp()
        NotificationManagerImp.sharedInstance = notificaitonManager
        notificaitonManager?.registerPushNotificationCatagories()
        notificaitonManager?.checkNotificationStatus()
        return true
    }
}
