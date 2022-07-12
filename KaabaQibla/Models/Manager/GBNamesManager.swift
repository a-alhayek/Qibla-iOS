//
//  GBNamesManager.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 7/12/22.
//

import Foundation
import Combine

class GBNamesManagerImpl {
    private let gbNClient: GBNamesClient
    private var cancellables: Set<AnyCancellable> = .init()
    init (gbNClient: GBNamesClient) {
        self.gbNClient = gbNClient
    }

    func getGBNames() {
        gbNClient.getGBNames()
            .receive(on: DispatchQueue.global(qos: .background))
            .sink(receiveValue: { response in
                Task { [weak self] in
                    guard let self = self else { return }
                    await self.saveNames(response.data)
                }
            }).store(in: &cancellables)
    }

    private func saveNames(_ names: [GBName]) async {
        let realm = try? await RealmDatabaseRepository.makeRealm()
        guard let realm = realm else {
            print("failed to create realm in GBNamesManager")
            return
        }
        realm.add(names)
    }
}
