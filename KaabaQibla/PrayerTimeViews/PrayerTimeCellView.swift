//
//  PrayerTimeCellView.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 6/1/22.
//

import SwiftUI

struct PrayerTimeCellView: View {
    var body: some View {
        HStack {
            Text("Fajr")
                .font(.title3)
                .padding(.leading)
            Spacer()
            Text("03:57")
                .font(.title3)
                .padding(.trailing)
        }
    }
}

struct PrayerTimeCellView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerTimeCellView()
    }
}
