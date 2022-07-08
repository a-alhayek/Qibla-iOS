//
//  QiblaViewModel.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/11/22.
//

import Foundation
import Combine
import UIKit
import CoreLocation
import RealmSwift

class QiblaViewModel: NSObject, ObservableObject {
    @Published private (set) var currentQibla: KaabaHeading?
    @Published private (set) var currentUserHeading: Double?
    @Published private (set) var placemark: CLPlacemark?
    @Published var error: Error?
    let generator = UIImpactFeedbackGenerator(style: .medium)
    var deviceLastLocation: CLLocation? {
        didSet {
            if let location = deviceLastLocation {
                fetchQibla(for: location.coordinate)
            }
        }
    }
    @Published var locationPermissionState: CLAuthorizationStatus
    private var qiblaFetcher: QiblaFetcher
    private let qiblaClient: QiblaClient
    var subscriptions = Set<AnyCancellable>()

    init(locationManager: QiblaFetcher = CLLocationManager(),
         qiblaClient: QiblaClient = QiblaClientImp()) {
        self.qiblaFetcher = locationManager
        self.qiblaClient = qiblaClient
        locationPermissionState = locationManager.authorizationStatus
        super.init()
        self.qiblaFetcher.qiblaFetcherDelegate = self
        UIDevice.current.batteryState == .charging ? (self.qiblaFetcher.desiredAccuracy = kCLLocationAccuracyBestForNavigation)
        : (self.qiblaFetcher.desiredAccuracy = kCLLocationAccuracyBest)
        subscribeToLocationManager()
    }

    func requestPermission() {
        qiblaFetcher.requestWhenInUseAuthorization()
    }

    func subscribeToLocationManager() {
        qiblaFetcher.requestLocation()
        qiblaFetcher.startUpdatingHeading()
    }

    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        true
    }

    private func throwInvalidHeadingError() {
        let qiblaError = (error as? QiblaError)
        guard qiblaError != QiblaError.invalidHeadingAccuracy else { return }
        error = QiblaError.invalidHeadingAccuracy
    }

    private func checkIfQiblaMatchesUserHeadingAndGenerateFeedback() {
        guard let userHeading = currentUserHeading, let kaabaHeading = currentQibla?.data.direction else {
            return
        }

        generateFeedbackIfTwoElementsAreEqual(Int(userHeading), Int(kaabaHeading))
    }

    private func setNewHeadingIfHeadingIsValid(_ newHeading: CLHeading) {
        
        guard ((try? newHeading.headingAccuracy >= 0) != nil) else {
            throwInvalidHeadingError()
            return
        }
        currentUserHeading = newHeading.magneticHeading
    }

    private func generateFeedbackIfTwoElementsAreEqual<T>(_ lhs: T, _ rhs: T) where T: Equatable {
        if lhs == rhs {
            generator.impactOccurred()
        }
    }

    private func fetchQibla(for coordinate: CLLocationCoordinate2D) {
        subscriptions.forEach {
            $0.cancel()
        }
        qiblaClient.getQibla(for: coordinate).receive(on: DispatchQueue.main)
            .receive(on: DispatchQueue.main, options: .none)
            .sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                ()
            case .failure(let error):
                self?.error = error
            }
        }, receiveValue: { [weak self] KaabaHeading in
            self?.currentQibla = KaabaHeading
        }).store(in: &subscriptions)
    }

    private func fetchCountryAndCity(for location: CLLocation?) {
        guard let location = location else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
           self.placemark = placemarks?.first
        }
    }
}

extension QiblaViewModel: QiblaFetcherDelegate {
    func locationManager(_ manager: QiblaFetcher, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async { [weak self] in
            self?.setNewHeadingIfHeadingIsValid(newHeading)
            self?.checkIfQiblaMatchesUserHeadingAndGenerateFeedback()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: QiblaFetcher) {
        DispatchQueue.main.async { [weak self] in
            self?.locationPermissionState = manager.authorizationStatus
            self?.subscribeToLocationManager()
        }
    }

    func locationManager(_ manager: QiblaFetcher, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async { [weak self] in
            self?.deviceLastLocation = locations.first
            self?.fetchCountryAndCity(for: locations.first)
        }
    }
}

extension QiblaViewModel: CLLocationManagerDelegate {
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

enum QiblaError: LocalizedError {
    case invalidHeadingAccuracy

    var errorDescription: String? {
        return description
    }

    var recoverySuggestion: String? {
        switch self {
        case .invalidHeadingAccuracy:
            return "try to stand still or stay away from any strong magnetic field"
        }
    }
}

extension QiblaError: CustomStringConvertible {
    var description: String {
        switch self {
        case .invalidHeadingAccuracy:
            return "the compass cannot get a good reading at the moment."
        }
    }
}
