//
//  SurabayaRegionTests.swift
//  NaendiTests
//

import MapKit
import Testing
@testable import Naendi

struct SurabayaRegionTests {
    @Test("landmarks inside Surabaya are accepted")
    func acceptsSurabayaLandmarks() {
        let tunjunganPlaza = CLLocationCoordinate2D(latitude: -7.2626, longitude: 112.7383)
        let suramaduBridge = CLLocationCoordinate2D(latitude: -7.1856, longitude: 112.7797)

        #expect(MKCoordinateRegion.surabaya.contains(tunjunganPlaza))
        #expect(MKCoordinateRegion.surabaya.contains(suramaduBridge))
    }

    @Test("landmarks outside Surabaya are rejected")
    func rejectsOutsideLandmarks() {
        let monasJakarta = CLLocationCoordinate2D(latitude: -6.1754, longitude: 106.8272)
        let malangCity = CLLocationCoordinate2D(latitude: -7.9666, longitude: 112.6326)
        let singapore = CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)

        #expect(!MKCoordinateRegion.surabaya.contains(monasJakarta))
        #expect(!MKCoordinateRegion.surabaya.contains(malangCity))
        #expect(!MKCoordinateRegion.surabaya.contains(singapore))
    }
}
