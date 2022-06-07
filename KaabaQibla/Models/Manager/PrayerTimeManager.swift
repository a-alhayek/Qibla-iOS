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
    var prayerTimings: PassthroughSubject<AladahnPrayerTimeAndDate, NetworkError> { get }
    func getPrayerTime(coordinate: CLLocationCoordinate2D, method: PrayerTimeMehod)
}

class PrayerTimeManagerIM: PrayerTimeManager {
    private let prayerClient: PrayerTimeClient
    private var subscriptions = Set<AnyCancellable>()
    private let dateFormatter = AladhanDateFormatter()
    var prayerTimings = PassthroughSubject<AladahnPrayerTimeAndDate, NetworkError>()
    private var repository: RealmDatabaseRepository<AladahnPrayerTimeAndDate, String>

    init(prayerClient: PrayerTimeClient,
         repository: RealmDatabaseRepository<AladahnPrayerTimeAndDate, String>) {
        self.prayerClient = prayerClient
        self.repository = repository
    }
    
    func getPrayerTime(coordinate: CLLocationCoordinate2D, method: PrayerTimeMehod) {
        let todayDate = dateFormatter.getAladhanString(from: Date())
        repository.getAll(objectsWith: nil).sink { [weak self] prayers in
            if let prayer = prayers.first(where: { prayer in
                 return prayer.date?.gregorian?.date == todayDate
            }) {
                self?.prayerTimings.send(prayer)            }
        }.store(in: &subscriptions)
        prayerClient.getPrayerTime(latitude: coordinate.latitude, longtitude: coordinate.longitude, method: method)
            .sink(receiveCompletion: { [weak self] (error) in
                self?.prayerTimings.send(completion: error)
        }, receiveValue: { [weak self] prayer in
            self?.prayerTimings.send(prayer.data)
        }).store(in: &subscriptions)
    }
}



