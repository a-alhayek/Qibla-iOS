//
//  KabbaImage.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/12/22.
//

import SwiftUI

struct KabbaImage: View {
    var body: some View {
        Image("kaaba").frame(width: 80, height: 80, alignment: .init(horizontal: .center, vertical: .center))
            .scaleEffect(0.3).clipShape(Circle())
    }
}

struct KabbaImage_Previews: PreviewProvider {
    static var previews: some View {
        KabbaImage()
    }
}
