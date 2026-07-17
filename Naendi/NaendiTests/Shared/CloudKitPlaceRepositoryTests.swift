//
//  CloudKitPlaceRepository.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 16/07/26.
//

import Testing
import CloudKit
@testable import Naendi

struct CloudKitPlaceRepositoryTests {
    @Test("a well-formed record maps to a Place")
    func mapsValidRecord() {
        let repository = CloudKitPlaceRepository()
        let record = CKRecord(recordType: "Place")
        record["nama"] = "Cafe A"
        record["halal"] = "halal"

        let place = repository.makePlace(from: record)

        #expect(place?.name == "Cafe A")
        #expect(place?.halalStatus == HalalStatus.halal)
    }
    
    @Test("a record missing its name maps to nil")
    func mapsInvalidRecordToNil() {
        let repository = CloudKitPlaceRepository()
        let record = CKRecord(recordType: "Place")
//        record["name"] = "Cafe A"
        record["halal"] = "halal"

        let place = repository.makePlace(from: record)

        #expect(place == nil)
    }
    
    @Test("halal string values map to their cases", arguments: [
        ("halal", HalalStatus.halal),
        ("non-halal", HalalStatus.nonHalal),
        ("unknown", HalalStatus.unknown),
        ("garbage", HalalStatus.unknown),
    ])
    func mapsHalalVariants(input: String, expected: HalalStatus) {
        let repository = CloudKitPlaceRepository()
        let record = CKRecord(recordType: "Places")
        record["nama"] = "X"
        record["halal"] = input

        #expect(repository.makePlace(from: record)?.halalStatus == expected)
    }

    @Test("a fully populated record maps every non-metadata column")
    func mapsEveryColumn() {
        let repository = CloudKitPlaceRepository()
        let record = CKRecord(recordType: "Places")
        record["nama"] = "Warung Nusantara"
        record["halal"] = "halal"
        record["alamat"] = "Jl. Raya Darmo 1"
        record["halal_evidence"] = "MUI certificate"
        record["images"] = "img1.jpg,img2.jpg"
        record["jam_buka"] = "08:00 - 22:00"
        record["jumlah_review"] = 128
        record["location"] = CLLocation(latitude: -7.2575, longitude: 112.7521)
        record["menu_link"] = "https://menu.example/warung"
        record["place_id"] = "ChIJabc123"
        record["range_harga"] = "Rp25.000 - Rp75.000"
        record["rating"] = 4.6
        record["review_negatif"] = "Antre panjang saat jam makan siang"
        record["review_positif"] = "Rasa autentik dan porsi besar"
        record["thumbnail"] = "thumb.jpg"
        record["type_tempat"] = "Restoran"
        record["vibe"] = "Cozy"

        let place = repository.makePlace(from: record)

        #expect(place?.name == "Warung Nusantara")
        #expect(place?.halalStatus == HalalStatus.halal)
        #expect(place?.address == "Jl. Raya Darmo 1")
        #expect(place?.halalEvidence == "MUI certificate")
        #expect(place?.images == "img1.jpg,img2.jpg")
        #expect(place?.openingHours == "08:00 - 22:00")
        #expect(place?.reviewCount == 128)
        #expect(place?.latitude == -7.2575)
        #expect(place?.longitude == 112.7521)
        #expect(place?.menuLink == "https://menu.example/warung")
        #expect(place?.placeID == "ChIJabc123")
        #expect(place?.priceRange == "Rp25.000 - Rp75.000")
        #expect(place?.rating == 4.6)
        #expect(place?.negativeReview == "Antre panjang saat jam makan siang")
        #expect(place?.positiveReview == "Rasa autentik dan porsi besar")
        #expect(place?.thumbnail == "thumb.jpg")
        #expect(place?.placeType == "Restoran")
        #expect(place?.vibe == "Cozy")
    }

    @Test("optional columns default to nil when absent")
    func missingOptionalColumnsDefaultToNil() {
        let repository = CloudKitPlaceRepository()
        let record = CKRecord(recordType: "Places")
        record["nama"] = "Bare Minimum"

        let place = repository.makePlace(from: record)

        #expect(place?.name == "Bare Minimum")
        #expect(place?.halalStatus == HalalStatus.unknown)
        #expect(place?.address == nil)
        #expect(place?.halalEvidence == nil)
        #expect(place?.images == nil)
        #expect(place?.openingHours == nil)
        #expect(place?.reviewCount == nil)
        #expect(place?.latitude == nil)
        #expect(place?.longitude == nil)
        #expect(place?.menuLink == nil)
        #expect(place?.placeID == nil)
        #expect(place?.priceRange == nil)
        #expect(place?.rating == nil)
        #expect(place?.negativeReview == nil)
        #expect(place?.positiveReview == nil)
        #expect(place?.thumbnail == nil)
        #expect(place?.placeType == nil)
        #expect(place?.vibe == nil)
    }
}
