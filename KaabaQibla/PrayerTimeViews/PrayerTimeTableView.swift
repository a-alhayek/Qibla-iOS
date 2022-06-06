//
//  PrayerTimeTableView.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 6/1/22.
//

import SwiftUI
import Combine

struct PrayerTimeTableView: View {
    @EnvironmentObject var prayerViewModel: PrayerViewModel
    var salat: [SalatNameAndTime] {
        prayerViewModel.prayerTime?.prayers ?? []
    }
    var body: some View {
        VStack {
            List(salat) { salatNameAndTime in
                PrayerTimeCellView(salatAndTime: salatNameAndTime)
            }
            Picker("Time methods:", selection: $prayerViewModel.timeMethod) {
                ForEach(PrayerTimeMehod.allCases) { element in
                    Text(element.textRepresentation).tag(element.id)
                }
                
            }.padding(.horizontal)
            
            Spacer()
        }
        
    }
}

struct PrayerTimeTableView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerTimeTableView().environmentObject(PrayerViewModel())
    }
}
