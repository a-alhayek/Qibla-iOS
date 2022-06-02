//
//  QiblaFetcher.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/13/22.
//

import Foundation
import CoreLocation

protocol QiblaFetcher {
    var qiblaFetcherDelegate: QiblaFetcherDelegate? { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestLocation()
    func startUpdatingHeading()
    func requestWhenInUseAuthorization()
}

extension CLLocationManager: QiblaFetcher {
    var qiblaFetcherDelegate: QiblaFetcherDelegate? {
        get {
            delegate as! QiblaFetcherDelegate?
        }
        set {
            delegate = newValue as! CLLocationManagerDelegate?
        }
    }
}

protocol QiblaFetcherDelegate: AnyObject {
    func locationManager(_ manager: QiblaFetcher, didUpdateHeading newHeading: CLHeading)
    func locationManagerDidChangeAuthorization(_ manager: QiblaFetcher)
    func locationManager(_ manager: QiblaFetcher, didUpdateLocations locations: [CLLocation])
}
