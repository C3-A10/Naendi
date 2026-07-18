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
        let original = Place.stub(
            id: "ChIJabc123",
            nama: "Warung Nusantara",
            alamat: "Jl. Raya Darmo 1",
            latitude: -7.2575,
            longitude: 112.7521,
            rangeHarga: "Rp25.000 - Rp75.000",
            jamBuka: "08:00 - 22:00",
            typeTempat: "Restoran",
            rating: 4.6,
            jumlahReview: 128,
            vibe: "Cozy",
            halal: "halal",
            halalEvidence: "MUI certificate",
            reviewPositif: "Rasa autentik dan porsi besar",
            reviewNegatif: "Antre panjang saat jam makan siang",
            imgUrl: "thumb.jpg",
            reportCount: 3
        )

        let roundTripped = PlaceEntity(from: original).toPlace()

        #expect(roundTripped == original)
    }

    @Test("a nil imgUrl survives the round-trip")
    func roundTripPreservesNilImgUrl() {
        let original = Place.stub(id: "1", nama: "Bare Minimum", imgUrl: nil)

        let roundTripped = PlaceEntity(from: original).toPlace()

        #expect(roundTripped == original)
    }
}
