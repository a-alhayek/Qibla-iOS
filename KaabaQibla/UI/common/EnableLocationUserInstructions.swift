//
//  EnableLocationUserInstructions.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 7/12/22.
//

import SwiftUI

struct EnableLocationUserInstructions: View {
    var body: some View {
        VStack (alignment: .leading, spacing: 8){
            Text("App needs to access device location to provide services. To give acess go to:")
            .font(.title3).padding(.horizontal)
            Text("Settings -> Kaaba Qibla -> location")

                .font(.title3)
                .fontWeight(.medium)
                .padding(.horizontal)
        }
        
    }
}

struct EnableLocationUserInstructions_Previews: PreviewProvider {
    static var previews: some View {
        EnableLocationUserInstructions()
    }
}
