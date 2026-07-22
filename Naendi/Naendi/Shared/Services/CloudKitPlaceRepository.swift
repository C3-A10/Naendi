//
//  CloudKitPlaceRepository.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 16/07/26.
//

import Foundation
import CloudKit

final class CloudKitPlaceRepository: PlaceRepository {

    private let containerID = "iCloud.naendi"
    private var container: CKContainer { CKContainer(identifier: containerID) }

    func getAllPlaces() async throws -> [Place] {
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
    func report(placeID: String) async throws -> Bool {
        let database = container.publicCloudDatabase
        let userID = try await container.userRecordID()
        let recordID = CKRecord.ID(recordName: "report_\(placeID)_\(userID.recordName)")

        do {
            _ = try await database.record(for: recordID)
            return false // already reported by this user
        } catch let error as CKError where error.code == .unknownItem {
            let report = CKRecord(recordType: "Report", recordID: recordID)
            report["place_id"] = placeID
            _ = try await database.save(report)
            return true
        }
    }

    func reportCounts() async throws -> [String: Int] {
        let database = container.publicCloudDatabase
        let query = CKQuery(recordType: "Report", predicate: NSPredicate(value: true))
        var counts: [String: Int] = [:]

        func tally(_ matchResults: [(CKRecord.ID, Result<CKRecord, Error>)]) {
            for (_, result) in matchResults {
                if let record = try? result.get(), let placeID = record["place_id"] as? String {
                    counts[placeID, default: 0] += 1
                }
            }
        }

        let firstPage = try await database.records(matching: query, desiredKeys: ["place_id"])
        tally(firstPage.matchResults)
        var cursor = firstPage.queryCursor
        while let currentCursor = cursor {
            let nextPage = try await database.records(continuingMatchFrom: currentCursor, desiredKeys: ["place_id"])
            tally(nextPage.matchResults)
            cursor = nextPage.queryCursor
        }
        return counts
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
        guard let nama = record["nama"] as? String,
              let location = record["location"] as? CLLocation else {
            return nil
        }
        let jumlahReview = (record["jumlah_review"] as? Int)
            ?? (record["jumlah_review"] as? Int64).map(Int.init)
            ?? 0
        let id = (record["place_id"] as? String) ?? record.recordID.recordName

        return Place(
            id: id,
            nama: nama,
            alamat: (record["alamat"] as? String) ?? "",
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
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
            imgUrls: (record["images"] as? String) ?? (record["images"] as? String),
            reportCount: 0
        )
    }
    
}
