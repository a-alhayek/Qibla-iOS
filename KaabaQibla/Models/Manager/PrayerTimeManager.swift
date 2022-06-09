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
    var prayerTimings: PassthroughSubject<[SalatNameAndTime], NetworkError> { get }
    var currentMehodBS: CurrentValueSubject<PrayerTimeMehod, Never> { get }
    func getPrayerTime(coordinate: CLLocationCoordinate2D, method: PrayerTimeMehod)
    func selectMethod(_ prayerTimeMethod: PrayerTimeMehod)
}

class PrayerTimeManagerIM: PrayerTimeManager {
    typealias MethodRepo = RealmDatabaseRepository<PrayerMethod, Int>
    typealias PrayerRepo = RealmDatabaseRepository<AladahnPrayerTimeAndDate, String>
    private let prayerClient: PrayerTimeClient
    private var subscriptions = Set<AnyCancellable>()
    private let dateFormatter = AladhanDateFormatter()
    let prayerTimings = PassthroughSubject<[SalatNameAndTime], NetworkError>()
    let currentMehodBS = CurrentValueSubject<PrayerTimeMehod, Never>(.ISNA)
    private let repository: PrayerRepo
    private let methodRepository: MethodRepo

    init(prayerClient: PrayerTimeClient, repository: PrayerRepo,
         methodRepository: MethodRepo) {
        self.prayerClient = prayerClient
        self.repository = repository
        self.methodRepository = methodRepository
        methodRepository.getAll(objectsWith: NSPredicate(format: "isSelected == YES"))
            .sink(receiveValue: {[weak self] value in
            guard let selectedMethod = value.first else {
                let methods = PrayerTimeMehod.allCases.map { PrayerMethod(rawValue: $0.rawValue)}
                methods[0].isSelected = true
                self?.methodRepository.add(contentOf: methods)
                return
            }
            self?.currentMehodBS.send(PrayerTimeMehod(rawValue: selectedMethod.rawValue)!)
        }).store(in: &subscriptions)
    }

    func selectMethod(_ prayerTimeMethod: PrayerTimeMehod) {
        methodRepository.getAll(objectsWith: NSPredicate(format: "isSelected == YES"))
            .sink(receiveValue: { [weak self] value in
            if let id = value.first?.rawValue, id != prayerTimeMethod.id {
                self?.methodRepository.updateElement(withId: id, edit: { method in
                    method.isSelected = false
                })

                self?.methodRepository.updateElement(withId: prayerTimeMethod.rawValue, edit: { method in
                    method.isSelected = true
                })
            }
        }).store(in: &subscriptions)
    }

    func getPrayerTime(coordinate: CLLocationCoordinate2D, method: PrayerTimeMehod) {
        let todayDate = dateFormatter.getAladhanString(from: Date())
        repository.queue.async { [weak self]  in
            guard let self = self else { return }
            self.repository.getAll(objectsWith: nil).sink { [weak self]  prayers in
                if let prayer = prayers.first(where: { prayer in
                     return prayer.date?.gregorian?.date == todayDate
                }) {
                    self?.prayerTimings.send(prayer.prayers)
                }
            }.store(in: &self.subscriptions)
        }
        
        prayerClient.getPrayerTime(latitude: coordinate.latitude, longtitude: coordinate.longitude, method: method)
            .sink(receiveCompletion: { [weak self] (completion) in
      //          self?.prayerTimings.send(completion: error)
        }, receiveValue: { [weak self] prayer in
            self?.prayerTimings.send(prayer.data.prayers)
            self?.repository.add(prayer.data)
        }).store(in: &subscriptions)
    }
}



