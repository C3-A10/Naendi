//
//  FakePlaceRepository.swift
//  NaendiTests
//
//  Created by Mohammad Rizaldy Ramadhan on 16/07/26.
//

import Foundation

@testable import Naendi

struct FakePlaceRepository: PlaceRepository {
    let places: [Place]
    func getAllPlaces() async throws -> [Place] { places }
    func fetchFirstPage() async throws -> [Place] { Array(places.prefix(1)) }
    func streamAllPlaces(onPage: ([Place]) async throws -> Void) async throws {
        // Two batches to exercise multi-page upsert.
        try await onPage(Array(places.prefix(1)))
        try await onPage(places)
    }
}
