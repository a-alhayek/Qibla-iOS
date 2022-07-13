//
//  GBNamesListView.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 7/12/22.
//

import SwiftUI

struct GBNamesListView: View {
    @ObservedObject var viewModel: GBNamesViewModel
    let title = LocalizedStringKey("God Names")
    var body: some View {
        VStack {
            HStack {
                Text(title).font(.title2)
            }.background(.white)
            List {
                ForEach($viewModel.gbNamesArray) { element in
                    GBNameView(gbName: element)
                }
            }
        }.onAppear {
            Task {
                try! await viewModel.listenToRealm()
            }
        }
    }
}

struct GBNamesListView_Previews: PreviewProvider {
    static var previews: some View {
        GBNamesListView(viewModel: .init())
    }
}
