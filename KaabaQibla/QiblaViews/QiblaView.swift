//
//  QiblaView.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/11/22.
//

import SwiftUI

struct QiblaView: View {
    @EnvironmentObject var qiblaModel: QiblaViewModel
    var kaabaHeading: KaabaHeading? {
        qiblaModel.currentQibla
    }
    var body: some View {
        switch qiblaModel.locationPermissionState {
        case .notDetermined, .restricted, .denied:
            requestAuthorization
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            HStack {
                Text(String(kaabaHeading?.data.direction ?? 0))
            }
        default:
            Text("Unexpected")
        }
        
    }

    var requestAuthorization: some View {
        Button {
            qiblaModel.requestPermission()
        } label: {
            Text("request authorization")
        }
    }
}

struct QiblaView_Previews: PreviewProvider {
    static var previews: some View {
        QiblaView().environmentObject(QiblaViewModel())
    }
}
