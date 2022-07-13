//
//  GBNamesViewModel.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 7/12/22.
//

import Foundation
import RealmSwift

class GBNamesViewModel: ObservableObject {
    private let gbManager: GBNamesManagerImpl
    private var realmNotificaitonToken: NotificationToken?
    private var gbNames: Results<GBName>? {
        didSet {
            guard let gbNames = gbNames, !gbNames.isEmpty else {
                loadGBNames()
                return
            }
            gbNamesArray = Array(gbNames)
        }
    }
    
    @Published var gbNamesArray: [GBName] = []
    
    init(gbManager: GBNamesManagerImpl = GBNamesManagerImpl()) {
        self.gbManager = gbManager
    }

    private func loadGBNames() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.gbManager.getGBNames()
        }
    }

    func listenToRealm() async throws {
        realmNotificaitonToken?.invalidate()
        realmNotificaitonToken = nil
        let realm = try! await RealmDatabaseRepository.makeRealm()
        let results = realm.objects(GBName.self)
        realmNotificaitonToken = results
            .observe(on: DispatchQueue.main) { [weak self] realmCollection in
            switch realmCollection {
            case .initial(let collection):
                self?.gbNames = collection
            case .update(let collection, _, _, _):
                self?.gbNames = collection
            case .error(let error):
                print(error.localizedDescription)
            }
        }
    }
}
