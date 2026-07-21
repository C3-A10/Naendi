//
//  CloudKitPlaceRepository.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 16/07/26.
//

import Foundation
import CloudKit

final class CloudKitPlaceRepository: PlaceRepository {
    func getAllPlaces() async throws -> [Place] {
        let container = CKContainer(identifier: "iCloud.naendi")
            let database = container.publicCloudDatabase
            let query = CKQuery(recordType: "Places", predicate: NSPredicate(value: true))

            var places: [Place] = []

            let firstPage = try await database.records(matching: query)
            let firstRecords = firstPage.matchResults
            var cursor = firstPage.queryCursor

            addPlaces(from: firstRecords, into: &places)

            while let currentCursor = cursor {
                let nextPage = try await database.records(continuingMatchFrom: currentCursor)
                let nextRecords = nextPage.matchResults
                cursor = nextPage.queryCursor

                addPlaces(from: nextRecords, into: &places)
            }

            return places
    }
    
    @discardableResult
    func incrementReportCount(placeID id: String) async throws -> Int {
        let database = CKContainer(identifier: "iCloud.naendi").publicCloudDatabase

        let record = try await fetchPlace(id: id, in: database)
        let current = (record["jumlah_report"] as? Int)
            ?? (record["jumlah_report"] as? Int64).map(Int.init)
            ?? 0
        let updated = current + 1
        record["jumlah_report"] = updated
        _ = try await database.save(record)
        return updated
    }

    private func fetchPlace(id: String, in database: CKDatabase) async throws -> CKRecord {
        let query = CKQuery(recordType: "Places", predicate: NSPredicate(format: "place_id == %@", id))
        let matches = try await database.records(matching: query, resultsLimit: 1).matchResults
        if let (_, result) = matches.first {
            return try result.get()
        }
        return try await database.record(for: CKRecord.ID(recordName: id))
    }

    private func addPlaces(
        from matchResults: [(CKRecord.ID, Result<CKRecord, Error>)],
        into places: inout [Place]
    ) {
        for (recordID, result) in matchResults {
            switch result {
            case .success(let record):
                if let place = makePlace(from: record) {
                    places.append(place)
                }
            case .failure:
                continue
            }
        }
    }
    
    func makePlace(from record: CKRecord) -> Place? {
        guard let nama = record["nama"] as? String else { return nil }

        let location = record["location"] as? CLLocation
        let jumlahReview = (record["jumlah_review"] as? Int)
            ?? (record["jumlah_review"] as? Int64).map(Int.init)
            ?? 0
        let id = (record["place_id"] as? String) ?? record.recordID.recordName

        return Place(
            id: id,
            nama: nama,
            alamat: (record["alamat"] as? String) ?? "",
            latitude: location?.coordinate.latitude ?? 0,
            longitude: location?.coordinate.longitude ?? 0,
            rangeHarga: (record["range_harga"] as? String) ?? "",
            jamBuka: (record["jam_buka"] as? String) ?? "",
            typeTempat: (record["type_tempat"] as? String) ?? "",
            rating: (record["rating"] as? Double) ?? 0,
            jumlahReview: jumlahReview,
            vibe: (record["vibe"] as? String) ?? "",
            halal: (record["halal"] as? String) ?? "",
            halalEvidence: (record["halal_evidence"] as? String) ?? "",
            reviewPositif: (record["review_positif"] as? String) ?? "",
            reviewNegatif: (record["review_negatif"] as? String) ?? "",
            imgUrl: (record["thumbnail"] as? String) ?? (record["images"] as? String),
            reportCount: 0
        )
    }
    
}
