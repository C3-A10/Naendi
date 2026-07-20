//
//  LocationProvider.swift
//  Naendi
//
//  Wraps CoreLocation so the view model can be tested without a device and so
//  the authorization prompt is never triggered just by constructing an object.
//

import CoreLocation
import Observation

protocol LocationProviding: AnyObject {
    /// The most recent fix, or `nil` when location is unavailable or denied.
    var currentLocation: CLLocation? { get }
    /// Requests authorization and begins updates. Safe to call repeatedly.
    func start()
    func stop()
}

@Observable
final class CoreLocationProvider: NSObject, LocationProviding, CLLocationManagerDelegate {

    private let manager = CLLocationManager()
    private var hasStarted = false

    var currentLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // Only report movement of 10 m or more; set before updates begin so it
        // applies to the first delivery.
        manager.distanceFilter = 10
    }

    /// Deliberately separate from `init` — this is what shows the permission
    /// prompt, so previews and tests that merely build the object stay silent.
    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func stop() {
        manager.stopUpdatingLocation()
        hasStarted = false
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // A transient failure shouldn't discard a good previous fix; keep it.
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied, .restricted:
            currentLocation = nil
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
}
