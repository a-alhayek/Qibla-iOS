//
//  QiblaView.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/11/22.
//

import SwiftUI
import UIKit
struct QiblaView: View {
    var imageWidth: CGFloat {
        min(width, height) - 25
    }

    var width: CGFloat {
        UIScreen.main.bounds.width
    }

    var height: CGFloat {
        UIScreen.main.bounds.height
    }
    @EnvironmentObject var qiblaModel: QiblaViewModel
    var kaabaHeading: Double {
        qiblaModel.currentQibla?.data.direction ?? 0
    }

    var imageRotationAngle: Double {
        Double(Int((-userHeading + 360) % 360))
    }

    var userHeading: Int {
       Int(qiblaModel.currentUserHeading ?? 0)
    }
    var body: some View {
        switch qiblaModel.locationPermissionState {
        case .notDetermined, .restricted, .denied:
            requestAuthorization
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            qibla
        default:
            Text("Unexpected")
        }
        
    }

    var qibla: some View {
        HStack {
            VStack {
                ZStack {
                    compassImage
                    compassImage.opacity(0).overlay(alignment: .top, content: {
                        kaabbaImage.position(x: imageWidth / 2, y: 30)
                    }).rotationEffect(.degrees(kaabaHeading))
                    
                }.rotationEffect(.degrees(imageRotationAngle))
            }
        }.overlay(alignment: .center, content: {
            Rectangle().frame(width: width, height: 1, alignment: .center)
            Rectangle().frame(width: 1, height: height, alignment: .center)
        })
    }

    var compassImage: some View {
            Image("compass")
                .frame(width: imageWidth , height: imageWidth, alignment: .center)
                .scaleEffect(0.6)
                .clipShape(Circle())
                
    }

    var kaabbaImage: some View {
        Image("kaaba").frame(width: 80, height: 80, alignment: .init(horizontal: .center, vertical: .center))
            .scaleEffect(0.3).clipShape(Circle())
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
