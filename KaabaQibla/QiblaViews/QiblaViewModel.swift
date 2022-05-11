//
//  QiblaViewModel.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/11/22.
//

import Foundation
import Combine
import CoreLocation

class QiblaViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentQibla: KaabaHeading?
    @Published var currentUserHeading: Double?
    @Published var error: Error?
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
        currentUserHeading = newHeading.magneticHeading
    }

    private func fetchQibla(for coordinate: CLLocationCoordinate2D) {
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

    deinit {
        subscriptions.forEach {
            $0.cancel()
        }
    }
}
