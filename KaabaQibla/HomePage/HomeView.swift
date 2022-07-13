//
//  HomeView.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/18/22.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            QiblaHomeScreen().environmentObject(QiblaViewModel())
                .tabItem {
                    VStack {
                        Image(systemName: "timelapse")
                        Text("Qibla")
                    }
            }
            PrayerTimeTableView(prayerViewModel: PrayerViewModel())
                .tabItem {
                    VStack {
                        Image(systemName: "person.circle")
                        Text("Prayer Time")
                    }
                }
            GBNamesListView(viewModel: GBNamesViewModel())
                .tabItem {
                    VStack {
                        Image(systemName: "list.bullet.rectangle")
                        Text("God Names")
                    }
                }
        }.onAppear {
            let notificationManager = NotificationManagerImp.current()
            switch notificationManager.settings {
            case .denied, .notDetermined:
                Task {
                    await notificationManager.requestAuthorization()
                }
            default:
                ()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
