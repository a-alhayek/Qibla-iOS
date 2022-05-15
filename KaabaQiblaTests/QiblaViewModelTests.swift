//
//  QiblaViewModelTests.swift
//  KaabaQiblaTests
//
//  Created by ahmad alhayek on 5/13/22.
//

import XCTest
import Foundation
import CoreLocation
import Combine
@testable import KaabaQibla

class QiblaViewModelTests: XCTestCase {

    struct MockQiblaFetcher: QiblaFetcher {
        weak var qiblaFetcherDelegate: QiblaFetcherDelegate?

        var desiredAccuracy: CLLocationAccuracy = 1

        var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
        var handleLocation: (() -> CLLocation)?
        func requestLocation() {
            guard let location = handleLocation?() else { return }
            qiblaFetcherDelegate?.locationManager(self, didUpdateLocations: [location])
        }

        func startUpdatingHeading() {
            //qiblaFetcherDelegate?.locationManager(self, didUpdateHeading:  CLHeading.init())
        }
        
        func requestWhenInUseAuthorization() {
            qiblaFetcherDelegate?.locationManagerDidChangeAuthorization(self)
        }
    }

    var cancellable: AnyCancellable?
    var randomCoordinates = [
        CLLocationCoordinate2D(latitude: 42.519539, longitude: -70.896713)
    ]

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        cancellable?.cancel()
        try super.tearDownWithError()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func getCurrentLocation() -> CLLocation {
        let coordinate = randomCoordinates[0]
        return CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    func testQiblaDirection() {
        var qiblaFetcher = MockQiblaFetcher()
        let requestLocationExpectation = expectation(description: "request qibla")
        qiblaFetcher.handleLocation = {
            requestLocationExpectation.fulfill()
            return self.getCurrentLocation()
        }
        let qiblaViewModel = QiblaViewModel(locationManager: qiblaFetcher)
        let completionExpectation = expectation(description: "completion")

        cancellable = qiblaViewModel.$currentQibla.sink { kaabaHeading in
            guard let kaabaHeading = kaabaHeading?.data.direction else { return }
            XCTAssertEqual(kaabaHeading, 60.5391677688285)
            completionExpectation.fulfill()
        }
        wait(for: [requestLocationExpectation, completionExpectation], timeout: 5)
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
