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
            
            HStack {
                Button(action: {
                    prayerViewModel.handleDecrementingDate()
                }, label: {
                    Image.init(systemName: "arrow.backward")
                }).padding(.leading)
                
                Spacer()
                VStack(spacing: 4) {
                    Text(prayerViewModel.day)
                        .font(.title2)
                    Text(prayerViewModel.date)
                
                }
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
        .alertPrayer($prayerViewModel.error)
    }
}

struct PrayerTimeTableView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerTimeTableView().environmentObject(PrayerViewModel())
    }
}

fileprivate extension View {
    func alertPrayer(_ error: Binding<NetworkError?>, buttonTitle: String = "Dismiss") -> some View {
        let qiblaError = error.wrappedValue
        return alert(isPresented: .constant(qiblaError != nil), error: qiblaError) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        } message: { error in
            Text("Please try again")
        }
    }
}
