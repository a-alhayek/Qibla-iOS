//
//  QiblaFetcher.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/13/22.
//

import Foundation
import CoreLocation

protocol QiblaFetcher {
    var delegate: CLLocationManagerDelegate? { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestLocation()
    func startUpdatingHeading()
    func requestWhenInUseAuthorization()
}

extension CLLocationManager: QiblaFetcher {
}
