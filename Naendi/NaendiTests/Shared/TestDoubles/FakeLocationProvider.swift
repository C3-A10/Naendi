//
//  FakeLocationProvider.swift
//  NaendiTests
//
//  Stand-in for CoreLocationProvider that never touches CoreLocation.
//

import CoreLocation
@testable import Naendi

final class FakeLocationProvider: LocationProviding {
    var currentLocation: CLLocation?
    private(set) var startCallCount = 0
    private(set) var stopCallCount = 0

    init(currentLocation: CLLocation? = nil) {
        self.currentLocation = currentLocation
    }

    convenience init(latitude: Double, longitude: Double) {
        self.init(currentLocation: CLLocation(latitude: latitude, longitude: longitude))
    }

    func start() { startCallCount += 1 }
    func stop() { stopCallCount += 1 }
}
