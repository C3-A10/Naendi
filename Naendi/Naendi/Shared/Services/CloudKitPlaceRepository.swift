//
//  CloudKitPlaceRepository.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 16/07/26.
//

import Foundation
import CloudKit

final class CloudKitPlaceRepository: PlaceRepository {
    // Single source of truth for the container — reads and report writes must
    // agree, and this value has already drifted once.
    private let containerID = "iCloud.naendiDwinda"
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

    /// Records the current user's report for a place by creating a `Report`
    /// record (public DB, so no write access to the shared `Places` record is
    /// needed). Idempotent: the record name is derived from place + user, so a
    /// user can report a given place at most once. Returns true if this created a
    /// new report, false if the user had already reported it.
    /// ponytail: assumes `placeID` is a CloudKit-safe recordName (Google place_id
    /// is). If a fallback place name with spaces/symbols ever reaches here, the
    /// save will throw — hash the id then.
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

    /// Total report counts per place, keyed by `place_id`. Reads every `Report`
    /// record and tallies client-side.
    /// ponytail: full scan + client-side count. Fine while reports are few; move
    /// to per-place count queries or a server-side aggregate if the type grows large.
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
