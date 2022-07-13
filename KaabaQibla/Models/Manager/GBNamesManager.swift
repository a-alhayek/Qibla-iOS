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
    init (gbNClient: GBNamesClient = QiblaClientImp()) {
        self.gbNClient = gbNClient
    }

    func getGBNames() {
        gbNClient.getGBNames()
            .receive(on: DispatchQueue.global(qos: .background))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print(error.description)
                }
            },receiveValue: { response in
                Task { [weak self] in
                    guard let self = self else { return }
                    await self.saveNames(response.data)
                }
            }).store(in: &cancellables)
    }

    private func saveNames(_ names: [GBName]) async {
        let realm = try! await RealmDatabaseRepository.makeRealm()
        try! realm.write {
            realm.add(names)
        }
        
    }
}
