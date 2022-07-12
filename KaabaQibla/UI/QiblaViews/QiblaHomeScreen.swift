//
//  QiblaHomeScreen.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/12/22.
//

import SwiftUI

struct QiblaHomeScreen: View {
    @EnvironmentObject var qiblaModel: QiblaViewModel
    var body: some View {
        switch qiblaModel.locationPermissionState {
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            QiblaView()
        case .denied:
            EnableLocationUserInstructions()
        default:
            requestAuthorization
        }
    }
    
    var requestAuthorization: some View {
        Button {
            /// open settings tab 
            qiblaModel.requestPermission()
        } label: {
            Text("request authorization")
        }
    }
}

struct QiblaHomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        QiblaHomeScreen().environmentObject(QiblaViewModel())
    }
}
