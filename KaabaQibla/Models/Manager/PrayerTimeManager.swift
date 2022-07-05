//
//  PrayerTimeManager.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 6/6/22.
//

import Foundation
import Combine
import CoreLocation

protocol PrayerTimeManager {
    var errorPublisher: PassthroughSubject<NetworkError, Never> { get }
    func getPrayerTime(coordinate: CLLocationCoordinate2D, method: PrayerTimeMehod, date: String)
    func selectMethod(_ prayerTimeMethod: PrayerTimeMehod)
}

class PrayerTimeManagerIM: PrayerTimeManager {
    let errorPublisher = PassthroughSubject<NetworkError, Never>()
    

    private let prayerClient: PrayerTimeClient
    private var subscriptions = Set<AnyCancellable>()
    private let dateFormatter = AladhanDateFormatter()

    init(prayerClient: PrayerTimeClient) {
        self.prayerClient = prayerClient
    }

    func selectMethod(_ prayerTimeMethod: PrayerTimeMehod) {
        DispatchQueue.global(qos: .default).async {
            Task {
                let realm = try? await RealmDatabaseRepository.makeRealm()
                let allObject = realm?.objects(PrayerMethod.self)
                let timeObject =  realm?.objects(AladahnPrayerTimeAndDate.self).filter { $0.method != prayerTimeMethod.rawValue }
                try? realm?.write {
                    let prevSelected = allObject?.first(where: { $0.isSelected == true} )
                    let selected = allObject?.first(where: { $0.rawValue == prayerTimeMethod.rawValue})
                    prevSelected?.isSelected = false
                    selected?.isSelected = true
                    if let timeObject = timeObject {
                        realm?.delete(timeObject)
                    }
                   
                }
            }
        }
    }

    func getPrayerTime(coordinate: CLLocationCoordinate2D, method: PrayerTimeMehod, date: String) {
        prayerClient.getPrayerTime(latitude: coordinate.latitude,
                                   longtitude: coordinate.longitude, method: method, date: date)
        .receive(on: DispatchQueue.global(qos: .default))
            .sink(receiveCompletion: { [weak self] (completion) in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    self?.errorPublisher.send(error)
                }
        }, receiveValue: { prayer in
            Task {
                let realm = try? await RealmDatabaseRepository.makeRealm()
                try? realm?.write {
                    let data = prayer.data
                    data.method = method.rawValue
                    realm?.add(prayer.data)
                }
            }
        }).store(in: &subscriptions)
    }
}



