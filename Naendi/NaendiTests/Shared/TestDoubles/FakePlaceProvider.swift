//
//  FakePlaceProvider.swift
//  NaendiTests
//

@testable import Naendi

enum FakePlaceProviderError: Error {
    case boom
}

struct FakePlaceProvider: PlaceProviding {
    let stubbed: [Place]
    let error: Error?

    init(stubbed: [Place] = [], error: Error? = nil) {
        self.stubbed = stubbed
        self.error = error
    }

    func places() async throws -> [Place] {
        if let error { throw error }
        return stubbed
    }
}
