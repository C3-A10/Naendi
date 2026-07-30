//
//  CloudKitPlaceRepositoryTests.swift
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
        let record = CKRecord(recordType: "Places")
        record["place_id"] = "abc"
        record["nama"] = "Cafe A"
        record["halal"] = "halal"
        record["location"] = CLLocation(latitude: -7.2575, longitude: 112.7521)

        let place = repository.makePlace(from: record)

        #expect(place?.id == "abc")
        #expect(place?.nama == "Cafe A")
        #expect(place?.halal == "halal")
    }

    @Test("a record missing its name maps to nil")
    func mapsInvalidRecordToNil() {
        let repository = CloudKitPlaceRepository()
        let record = CKRecord(recordType: "Places")
        record["halal"] = "halal"

        let place = repository.makePlace(from: record)

        #expect(place == nil)
    }

    @Test("a fully populated record maps every non-metadata column")
    func mapsEveryColumn() {
        let repository = CloudKitPlaceRepository()
        let record = CKRecord(recordType: "Places")
        record["place_id"] = "ChIJabc123"
        record["nama"] = "Warung Nusantara"
        record["alamat"] = "Jl. Raya Darmo 1"
        record["location"] = CLLocation(latitude: -7.2575, longitude: 112.7521)
        record["range_harga"] = "Rp25.000 - Rp75.000"
        record["jam_buka"] = "08:00 - 22:00"
        record["type_tempat"] = "Restoran"
        record["rating"] = 4.6
        record["jumlah_review"] = 128
        record["vibe"] = "Cozy"
        record["halal"] = "halal"
        record["halal_evidence"] = "MUI certificate"
        record["review_positif"] = "Rasa autentik dan porsi besar"
        record["review_negatif"] = "Antre panjang saat jam makan siang"
        record["images"] = "thumb.jpg"

        let place = repository.makePlace(from: record)

        #expect(place?.id == "ChIJabc123")
        #expect(place?.nama == "Warung Nusantara")
        #expect(place?.alamat == "Jl. Raya Darmo 1")
        #expect(place?.latitude == -7.2575)
        #expect(place?.longitude == 112.7521)
        #expect(place?.rangeHarga == "Rp25.000 - Rp75.000")
        #expect(place?.jamBuka == "08:00 - 22:00")
        #expect(place?.typeTempat == "Restoran")
        #expect(place?.rating == 4.6)
        #expect(place?.jumlahReview == 128)
        #expect(place?.vibe == "Cozy")
        #expect(place?.halal == "halal")
        #expect(place?.halalEvidence == "MUI certificate")
        #expect(place?.reviewPositif == "Rasa autentik dan porsi besar")
        #expect(place?.reviewNegatif == "Antre panjang saat jam makan siang")
        #expect(place?.imgUrls == "thumb.jpg")
    }

    @Test("absent optional columns fall back to sensible defaults")
    func missingColumnsUseDefaults() {
        let repository = CloudKitPlaceRepository()
        let record = CKRecord(recordType: "Places")
        record["nama"] = "Bare Minimum"
        record["location"] = CLLocation(latitude: -7.2575, longitude: 112.7521)

        let place = repository.makePlace(from: record)

        #expect(place?.nama == "Bare Minimum")
        // place_id absent -> falls back to the record's own name so id is never empty
        #expect(place?.id.isEmpty == false)
        #expect(place?.alamat == "")
        #expect(place?.latitude == -7.2575)
        #expect(place?.longitude == 112.7521)
        #expect(place?.rangeHarga == "")
        #expect(place?.jamBuka == "")
        #expect(place?.typeTempat == "")
        #expect(place?.rating == 0)
        #expect(place?.jumlahReview == 0)
        #expect(place?.vibe == "")
        #expect(place?.halal == "")
        #expect(place?.halalEvidence == "")
        #expect(place?.reviewPositif == "")
        #expect(place?.reviewNegatif == "")
        #expect(place?.imgUrl == nil)
        #expect(place?.reportCount == 0)
    }

    @Test("a record missing its required location maps to nil")
    func missingLocationMapsToNil() {
        let repository = CloudKitPlaceRepository()
        let record = CKRecord(recordType: "Places")
        record["nama"] = "No Location"

        #expect(repository.makePlace(from: record) == nil)
    }

    @Test("thumbnail is preferred for imgUrl, falling back to images")
    func imgUrlFallsBackToImages() {
        let repository = CloudKitPlaceRepository()
        let record = CKRecord(recordType: "Places")
        record["nama"] = "No Thumb"
        record["images"] = "gallery1.jpg"
        record["location"] = CLLocation(latitude: -7.2575, longitude: 112.7521)

        #expect(repository.makePlace(from: record)?.imgUrls == "gallery1.jpg")
    }
}
