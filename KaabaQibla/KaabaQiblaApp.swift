//
//  KaabaQiblaApp.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/10/22.
//

import SwiftUI

@main
struct KaabaQiblaApp: App {
//    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            QiblaHomeScreen().environmentObject(QiblaViewModel())
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
