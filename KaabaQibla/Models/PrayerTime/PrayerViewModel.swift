//
//  PrayerViewModel.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 6/1/22.
//

import Foundation
import Combine
import CoreLocation

class PrayerViewModel: NSObject, ObservableObject {
    @Published private (set) var prayerTime: AladahnPrayerTimeAndDate?
    private let prayerClient: PrayerTimeClient
    private var locationManager: QiblaFetcher
    private var repository: RealmDatabaseRepository<AladahnPrayerTimeAndDate, String>
    @Published  var timeMethod:  Int
    {
        didSet {
            setPrayerTime(coordnaite: coordination)
        }
    }
    private var coordination: CLLocationCoordinate2D?
    {
        didSet {
            setPrayerTime(coordnaite: coordination)
        }
    }
    var subscriptions = Set<AnyCancellable>()
    init (prayerClient: PrayerTimeClient = PrayerTimeClientImp(),
          locationManger: QiblaFetcher = CLLocationManager()) {
        self.prayerClient = prayerClient
        self.locationManager = locationManger
        self.timeMethod = PrayerTimeMehod.ISNA.rawValue
        let migration = AladahnMigration()
        let configration = AladahnRealmConfig.prayerTime.configuration(migration)
        repository = RealmDatabaseRepository(configuration: configration, dispatchQueueLabel: "aladahn.queue")
        super.init()
        self.locationManager.qiblaFetcherDelegate = self
        
        locationManger.requestWhenInUseAuthorization()
        
    }


    func setPrayerTime(coordnaite: CLLocationCoordinate2D?) {
        guard let coordnaite = coordnaite else {
            return
        }
        prayerClient.getPrayerTime(latitude: coordnaite.latitude, longtitude: coordnaite.longitude,
                                   method: PrayerTimeMehod(rawValue: timeMethod)!)
            .receive(on: DispatchQueue.main, options: .none)
            .sink(receiveCompletion: { error in
            print(error)
        }, receiveValue: { [weak self] prayer in
            self?.prayerTime = prayer.data
        }).store(in: &subscriptions)
    }
}
extension PrayerViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.locationManager(manager as QiblaFetcher, didUpdateHeading: newHeading)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.locationManagerDidChangeAuthorization(manager as QiblaFetcher)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager(manager as QiblaFetcher, didUpdateLocations: locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension PrayerViewModel: QiblaFetcherDelegate {
    func locationManager(_ manager: QiblaFetcher, didUpdateHeading newHeading: CLHeading) {
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: QiblaFetcher) {
        switch manager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            ()
        case .authorizedAlways:
            self.locationManager.requestLocation()
        case .authorizedWhenInUse:
            self.locationManager.requestLocation()
        @unknown default:
            ()
        }
    }
    
    func locationManager(_ manager: QiblaFetcher, didUpdateLocations locations: [CLLocation]) {
        self.coordination = locations.first?.coordinate
    }
    
}
