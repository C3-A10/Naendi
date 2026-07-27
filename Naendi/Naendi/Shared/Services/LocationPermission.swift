//
//  LocationPermission.swift
//  Naendi
//
//  Tracks whether the app may use GPS, so features that depend on it can warn
//  instead of silently doing nothing. Separate from CoreLocationProvider, which
//  delivers fixes: this only ever reads authorization.
//

import CoreLocation
import SwiftUI
import UIKit

@MainActor
@Observable
final class LocationPermission: NSObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    private(set) var status: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        status = manager.authorizationStatus
    }

    /// Prompts when the user has not been asked yet. Returns `false` only when
    /// location is off for good and the user has to change it in Settings.
    func requestIfNeeded() -> Bool {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            return true
        case .denied, .restricted:
            return false
        default:
            return true
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated { status = manager.authorizationStatus }
    }
}

extension View {
    /// The one warning shown wherever a feature needs GPS and cannot have it.
    func locationDeniedAlert(isPresented: Binding<Bool>) -> some View {
        modifier(LocationDeniedAlert(isPresented: isPresented))
    }
}

private struct LocationDeniedAlert: ViewModifier {
    @Binding var isPresented: Bool

    @Environment(\.openURL) private var openURL

    func body(content: Content) -> some View {
        content.alert("Location Access Is Off", isPresented: $isPresented) {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                Button("Open Settings") { openURL(settingsURL) }
            }
            Button("Not Now", role: .cancel) {}
        } message: {
            Text("Naendi needs your location for this. Turn it on in Settings under Privacy & Security, or pick a location instead.")
        }
    }
}
