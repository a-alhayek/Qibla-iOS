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
        prayerViewModel.prayerTime
    }
    var body: some View {
        VStack {
            Text(prayerViewModel.date)
            HStack {
                Button(action: {
                    prayerViewModel.handleDecrementingDate()
                }, label: {
                    Image.init(systemName: "arrow.backward")
                }).padding(.leading)
                Spacer()
                Button(action: {
                    prayerViewModel.handleIncrmentingDate()
                }, label: {
                    Image.init(systemName: "arrow.forward")
                }).padding(.trailing)
            }
            List(salat) { salatNameAndTime in
                PrayerTimeCellView(salatAndTime: salatNameAndTime)
            }
            Picker(selection: $prayerViewModel.timeMethod) {
                ForEach(PrayerTimeMehod.allCases) { element in
                    Text(element.textRepresentation)
                        .tag(element.id)
                }
                
            } label: {
                Text(PrayerTimeMehod(rawValue: prayerViewModel.timeMethod)!
                    .textRepresentation)
            }
           
           
        }.onAppear {
            Task {
                await prayerViewModel.listenToRealmUpdate()
                await prayerViewModel.listenToDataUpdate()
            }
        }
    }
}

struct PrayerTimeTableView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerTimeTableView().environmentObject(PrayerViewModel())
    }
}
