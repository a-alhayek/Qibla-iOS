//
//  GBNameView.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 7/12/22.
//

import SwiftUI
import UIKit

struct GBNameView: View {
    @Binding var gbName: GBName
    let nf = NumberFormatter()
    var isLeftToRight: Bool {
        UIApplication.shared
            .userInterfaceLayoutDirection == .leftToRight ? true: false
    }
    var number: String {
        let num = nf.string(from: NSNumber(value: Int32(gbName.number)))!
        return isLeftToRight ?
        num + ")" :  "(" + num
    }

    var name: String {
        isLeftToRight ? gbName.translation : gbName.arabicName
    }
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            numberText
            nameView
            Spacer()
        }.onTapGesture {
            
        }.padding()
    }

    var numberText: some View {
        Text(number)
            .font(.title2)

    }

    var nameView: some View {
        Text(name)
            .font(.title2)
    }
}

struct GBNameView_Previews: PreviewProvider {
    static var previews: some View {
        GBNameView(gbName: .constant(GBName(number: 0, name: "الرحمان", en: Translation(meaning: "The merciful"))))
            .environment(\.locale, .init(identifier: "ar"))
    }
}
