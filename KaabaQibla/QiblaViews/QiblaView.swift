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
        VStack {
            qibla
        }
    }
    
    var qibla: some View {
        ZStack {
            CompassImage()
            CompassImage().opacity(0).overlay(alignment: .top, content: {
                KabbaImage().position(x: imageWidth / 2, y: 30)
            }).rotationEffect(.degrees(kaabaHeading))
            
        }.rotationEffect(.degrees(imageRotationAngle))
            .overlay(alignment: .center, content: {
                Rectangle().frame(width: imageWidth, height: 1, alignment: .center)
                let verticalRectangle =
                Rectangle().frame(width: 1, height: imageWidth, alignment: .center)
                verticalRectangle.overlay(alignment: .top, content: {
                    Rectangle().frame(width: 4, height: 100, alignment: .top).position(x: 1, y: 0)
                })
                
            })
    }
}

struct QiblaView_Previews: PreviewProvider {
    static var previews: some View {
        QiblaView().environmentObject(QiblaViewModel())
        
    }
}
