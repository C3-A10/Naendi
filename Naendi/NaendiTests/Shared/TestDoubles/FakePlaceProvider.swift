//
//  FakePlaceProvider.swift
//  NaendiTests
//

@testable import Naendi

struct FakePlaceProvider: PlaceProviding {
    let stubbed: [Place]
    func places() async throws -> [Place] { stubbed }
}
