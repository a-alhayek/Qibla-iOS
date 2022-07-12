//
//  CompassImage.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/12/22.
//

import SwiftUI

struct CompassImage: View {
    var imageWidth: CGFloat {
        min(width, height) - 25
    }

    var width: CGFloat {
        UIScreen.main.bounds.width
    }

    var height: CGFloat {
        UIScreen.main.bounds.height
    }
    var body: some View {
        Image("compass")
            .frame(width: imageWidth , height: imageWidth, alignment: .center)
            .scaleEffect(0.6)
            .clipShape(Circle())
    }
}

struct CompassImage_Previews: PreviewProvider {
    static var previews: some View {
        CompassImage()
    }
}
