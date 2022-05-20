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
            QiblaView().environmentObject(QiblaViewModel())
                .tabItem {
                Image(systemName: "clock.arrow.2.circlepath")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
