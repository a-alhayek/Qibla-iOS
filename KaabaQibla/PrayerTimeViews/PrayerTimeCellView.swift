//
//  PrayerTimeCellView.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 6/1/22.
//

import SwiftUI

struct PrayerTimeCellView: View {
    let salatAndTime: SalatNameAndTime
    var body: some View {
        HStack {
            Text(salatAndTime.salatName)
                .font(.title3)
                .padding(.leading)
            Spacer()
            Text(salatAndTime.salatTime12)
                .font(.title3)
                .padding(.trailing)
        }
    }
}

struct PrayerTimeCellView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerTimeCellView(salatAndTime: SalatNameAndTime(salatName:"Fajar", salatTime: "03:34"))
    }
}
