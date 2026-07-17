//
//  PlaceEntityTests.swift
//  NaendiTests
//
//  Created by Mohammad Rizaldy Ramadhan on 17/07/26.
//

import Testing
@testable import Naendi

struct PlaceEntityTests {
    @Test("a Place round-trips through PlaceEntity preserving every field")
    func roundTripPreservesEveryField() {
        let original = Place(
            name: "Warung Nusantara",
            halalStatus: .halal,
            address: "Jl. Raya Darmo 1",
            halalEvidence: "MUI certificate",
            images: "img1.jpg,img2.jpg",
            openingHours: "08:00 - 22:00",
            reviewCount: 128,
            latitude: -7.2575,
            longitude: 112.7521,
            menuLink: "https://menu.example/warung",
            placeID: "ChIJabc123",
            priceRange: "Rp25.000 - Rp75.000",
            rating: 4.6,
            negativeReview: "Antre panjang saat jam makan siang",
            positiveReview: "Rasa autentik dan porsi besar",
            thumbnail: "thumb.jpg",
            placeType: "Restoran",
            vibe: "Cozy"
        )

        let roundTripped = PlaceEntity(from: original).toPlace()

        #expect(roundTripped == original)
    }

    @Test("nil optional fields survive the round-trip")
    func roundTripPreservesNilFields() {
        let original = Place(name: "Bare Minimum", halalStatus: .unknown)

        let roundTripped = PlaceEntity(from: original).toPlace()

        #expect(roundTripped == original)
    }
}
