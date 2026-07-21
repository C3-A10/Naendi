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
}
