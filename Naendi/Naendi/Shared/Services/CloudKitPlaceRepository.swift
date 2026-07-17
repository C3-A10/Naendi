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
        let container = CKContainer(identifier: "iCloud.naendi.mozaldy")
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
        // Prefer the stable place_id; fall back to the record's own name so id is never empty.
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
