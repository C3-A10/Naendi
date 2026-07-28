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
        var places: [Place] = []
        try await streamAllPlaces { places += $0 }
        return places
    }

    // Most-reviewed first, so the first page shown at launch is the best content.
    // Requires jumlah_review to be marked Sortable in the CloudKit dashboard.
    private var placesQuery: CKQuery {
        let query = CKQuery(recordType: "Places", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "jumlah_review", ascending: false)]
        return query
    }

    func fetchFirstPage() async throws -> [Place] {
        let database = container.publicCloudDatabase
        var places: [Place] = []
        let firstPage = try await database.records(matching: placesQuery)
        addPlaces(from: firstPage.matchResults, into: &places)
        return places
    }

    func streamAllPlaces(onPage: ([Place]) async throws -> Void) async throws {
        let database = container.publicCloudDatabase

        let firstPage = try await database.records(matching: placesQuery)
        var cursor = firstPage.queryCursor

        var places: [Place] = []
        addPlaces(from: firstPage.matchResults, into: &places)
        try await onPage(places)

        while let currentCursor = cursor {
            let nextPage = try await database.records(continuingMatchFrom: currentCursor)
            cursor = nextPage.queryCursor

            var batch: [Place] = []
            addPlaces(from: nextPage.matchResults, into: &batch)
            try await onPage(batch)
        }
    }
    
    private func reportRecordID(placeID: String, userID: CKRecord.ID) -> CKRecord.ID {
        CKRecord.ID(recordName: "report_\(placeID)_\(userID.recordName)")
    }

    func hasReported(placeID: String) async -> Bool {
        guard let userID = try? await container.userRecordID() else { return false }
        let recordID = reportRecordID(placeID: placeID, userID: userID)
        return (try? await container.publicCloudDatabase.record(for: recordID)) != nil
    }

    @discardableResult
    func report(placeID: String) async throws -> Bool {
        let database = container.publicCloudDatabase
        let userID = try await container.userRecordID()
        let recordID = reportRecordID(placeID: placeID, userID: userID)

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
            imgUrls: record["images"] as? String,
            reportCount: 0
        )
    }

}
