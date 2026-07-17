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
        guard let name = record["nama"] as? String else { return nil }

        let halalText = (record["halal"] as? String) ?? ""
        let status: HalalStatus
        switch halalText.lowercased() {
        case "halal":     status = .halal
        case "non-halal": status = .nonHalal
        default:          status = .unknown
        }

        return Place(name: name, halalStatus: status)
    }
    
}
