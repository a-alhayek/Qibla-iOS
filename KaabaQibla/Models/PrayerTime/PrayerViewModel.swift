//
//  PrayerViewModel.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 6/1/22.
//

import Foundation
import Combine
import CoreLocation
import RealmSwift

class PrayerViewModel: NSObject, ObservableObject {
    private let dateFormmater = AladhanDateFormatter()
    @Published private (set) var prayerTime: [SalatNameAndTime] = []
    private let prayerClient: PrayerTimeClient
    private var locationManager: QiblaFetcher
    let prayerTimeManager: PrayerTimeManager

    @Published var error: NetworkError?
    
    private var realmInit = false
    private var prayerTimeRealm: Results<AladahnPrayerTimeAndDate>?
    private (set) var date: String
    @Published  var timeMethod: Int = 0
    {
        didSet {
            guard realmInit else { return }
            prayerTimeManager.selectMethod(PrayerTimeMehod(rawValue: timeMethod)!)
            setPrayerTime(coordnaite: coordination, date: date)
        }
    }

    private var coordination: CLLocationCoordinate2D?
    {
        didSet {
            setPrayerTime(coordnaite: coordination, date: date)
        }
    }

    var notificationToken: NotificationToken?
    var dateNotificationToken: NotificationToken?

    var subscriptions = Set<AnyCancellable>()
    init (prayerClient: PrayerTimeClient = PrayerTimeClientImp(),
          locationManger: QiblaFetcher = CLLocationManager(), prayerTimeManager: PrayerTimeManager = diContainer.resolve(PrayerTimeManager.self)!) {
        self.prayerClient = prayerClient
        self.locationManager = locationManger
        self.prayerTimeManager = prayerTimeManager
        self.date = dateFormmater.getAladhanString(from: Date())
        super.init()
        self.locationManager.qiblaFetcherDelegate = self
        
        locationManger.requestWhenInUseAuthorization()

        prayerTimeManager.errorPublisher.receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                self?.error = error
            }).store(in: &subscriptions)
    }

    func listenToRealmUpdate() async {
        notificationToken?.invalidate()
        notificationToken = nil
        let realm = try? await RealmDatabaseRepository.makeRealm()
        realmInit = true
        let allPrayerMethods = realm?.objects(PrayerMethod.self)
        if allPrayerMethods!.isEmpty {
            let allMethods = PrayerTimeMehod.allCases.map { PrayerMethod.init(rawValue: $0.rawValue)}
            allMethods.first?.isSelected = true
            try? realm?.write {
                realm?.add(allMethods)
            }
            timeMethod = allMethods.first!.rawValue
        } else {
            if let slected = allPrayerMethods?.first(where: { $0.isSelected }) {
                timeMethod = slected.rawValue
            }
        }

        notificationToken = allPrayerMethods?.observe {[weak self] update in
            switch update {
            case .initial(_):
                print("init prayerTImes")
            case .update(_, _, _, let modifications):
                if let selected = modifications.first(where: { $0 != self?.timeMethod}) {
                    print("selected \(selected)")
                }
            case .error(let error):
                print(error.localizedDescription)
            }
        }
    }

    func listenToDataUpdate() async {
        dateNotificationToken?.invalidate()
        dateNotificationToken = nil
        let realm = try? await RealmDatabaseRepository.makeRealm()
        prayerTimeRealm = realm?.objects(AladahnPrayerTimeAndDate.self)
        dateNotificationToken = prayerTimeRealm?
            .observe(on: .main) {[weak self] updates in
            switch updates {
            case .initial(let collection):
               // self?.prayerTimeRealm = collection
                guard let prayer = collection.first?.prayers else {
                    return
                }
                self?.prayerTime = prayer
            case .update(_, _, let insertions, _):
                guard !insertions.isEmpty else { return }
                let index = insertions[0]
                guard let prayer = self?.prayerTimeRealm?[index], let date = prayer.exactDate else {
                    return
                }
                self?.date = date
                self?.prayerTime = prayer.prayers
            case .error(_):
                ()
            }
        }
    }

    

    func setPrayerTime(coordnaite: CLLocationCoordinate2D?, date: String) {
        guard let coordnaite = coordnaite else {
            return
        }
        DispatchQueue.global(qos: .userInitiated)
            .async { [weak self] in
                guard let self = self else { return }
                self.prayerTimeManager
                    .getPrayerTime(coordinate: coordnaite, method: PrayerTimeMehod(rawValue: self.timeMethod)!, date: date)
            }
    }

    private func getDate() -> Date? {
        dateFormmater.date(from: date)
    }

    func handleIncrmentingDate() {
        guard let date = getDate(), let fixedDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { return }
        setDate(fixedDate: fixedDate)
    }
    
    func handleDecrementingDate() {
        guard let date = getDate(), let fixedDate = Calendar.current.date(byAdding: .day, value: -1, to: date) else { return }
        setDate(fixedDate: fixedDate)
    }

    private func setDate(fixedDate: Date) {
        let fixedDateString = dateFormmater.getAladhanString(from: fixedDate)
        guard let prayerTime = prayerTimeRealm?.first(where: { [weak self] element in
            element.method == self?.timeMethod && fixedDateString == element.exactDate }) else {
            setPrayerTime(coordnaite: coordination, date: fixedDateString)
            return
        }
        self.date = fixedDateString
        self.prayerTime = prayerTime.prayers
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
