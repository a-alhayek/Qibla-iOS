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

class QiblaViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentQibla: KaabaHeading?
    @Published var currentUserHeading: Double?
    @Published var placemark: CLPlacemark?
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
    private let locationManager: CLLocationManager
    private let qiblaClient: QiblaClient
    var subscriptions = Set<AnyCancellable>()

    init(locationManager: CLLocationManager = CLLocationManager(),
         qiblaClient: QiblaClient = QiblaClientImp()) {
        self.locationManager = locationManager
        self.qiblaClient = qiblaClient
        locationPermissionState = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        deviceLastLocation = locations.first
        fetchCountryAndCity(for: locations.first)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationPermissionState = manager.authorizationStatus
        locationManager.startUpdatingLocation()
        deviceLastLocation = manager.location
    }

    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        true
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let qiblaError = (error as? QiblaError)
        guard newHeading.headingAccuracy > 0 && qiblaError != QiblaError.invalidHeadingAccuracy else {
            if qiblaError != nil { return }
            error = QiblaError.invalidHeadingAccuracy
            return
        }
        error = nil
        currentUserHeading = newHeading.magneticHeading
        guard let userHeading = currentUserHeading, let kaabaHeading = currentQibla?.data.direction else {
            return
        }
        if Int(userHeading) == Int(kaabaHeading) {
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
