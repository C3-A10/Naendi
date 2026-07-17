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
}
