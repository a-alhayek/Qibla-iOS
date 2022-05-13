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

class QiblaViewModel: NSObject, ObservableObject {
    @Published private (set) var currentQibla: KaabaHeading?
    @Published private (set) var currentUserHeading: Double?
    @Published private (set) var placemark: CLPlacemark?
    @Published private (set) var error: Error?
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
        guard newHeading.headingAccuracy > 0 else {
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
        qiblaClient.getQibla(for: coordinate).receive(on: DispatchQueue.main).sink(receiveCompletion: { [weak self] completion in
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
        setNewHeadingIfHeadingIsValid(newHeading)
        checkIfQiblaMatchesUserHeadingAndGenerateFeedback()
    }

    func locationManagerDidChangeAuthorization(_ manager: QiblaFetcher) {
        locationPermissionState = manager.authorizationStatus
        subscribeToLocationManager()
    }

    func locationManager(_ manager: QiblaFetcher, didUpdateLocations locations: [CLLocation]) {
        deviceLastLocation = locations.first
        fetchCountryAndCity(for: locations.first)
    }
}

extension QiblaViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.locationManager(manager, didUpdateHeading: newHeading)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.locationManagerDidChangeAuthorization(manager)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager(manager, didUpdateLocations: locations)
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
