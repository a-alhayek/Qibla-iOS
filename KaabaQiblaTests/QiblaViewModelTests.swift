//
//  QiblaViewModelTests.swift
//  KaabaQiblaTests
//
//  Created by ahmad alhayek on 5/13/22.
//

import XCTest
import Foundation
import CoreLocation
@testable import KaabaQibla

class QiblaViewModelTests: XCTestCase {
    struct MockQiblaViewModel: QiblaFetcher {
        weak var qiblaFetcherDelegate: QiblaFetcherDelegate?

        var desiredAccuracy: CLLocationAccuracy = 0

        var authorizationStatus: CLAuthorizationStatus = .denied

        func requestLocation() {
            guard let location = getCurrentLocation() else { return }
            qiblaFetcherDelegate?.locationManager(self, didUpdateLocations: [location])
        }

        func startUpdatingHeading() {
            qiblaFetcherDelegate?.locationManager(self, didUpdateHeading:  CLHeading.init())
        }
        
        func requestWhenInUseAuthorization() {
            sleep(12)
            qiblaFetcherDelegate?.locationManagerDidChangeAuthorization(self)
        }

        func getCurrentLocation() -> CLLocation? {
            guard let coordinate = randomCoordinates.randomElement(), let lat = coordinate?.latitude,
               let long = coordinate?.longitude else {
                return nil
            }
            return CLLocation.init(latitude: lat, longitude: long)
        }

        var randomCoordinates = [
            CLLocationCoordinate2D(latitude: 42.519539, longitude: -70.896713),
            nil
        ]
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
