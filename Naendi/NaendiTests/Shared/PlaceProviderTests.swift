//
//  PlaceProviderTests.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 17/07/26.
//

import Testing
@testable import Naendi

struct PlaceProviderTests {

    @Test("when already seeded, load from local store and do NOT fetch remotely")
    func usesCacheWhenSeeded() async throws {
        let remote = FakePlaceRepository(places: [.stub(nama: "From CloudKit")])
        let local = FakePlaceStore()
        local.hasSeededData = true
        local.storedPlaces = [.stub(nama: "From cache")]

        let provider = PlaceProvider(repository: remote, store: local)
        let result = try await provider.places()

        #expect(result.first?.nama == "From cache")
    }

    @Test("when not yet seeded, fetch remotely and save to local store")
    func fetchesAndSeedsWhenNotSeeded() async throws {
        let remote = FakePlaceRepository(places: [.stub(nama: "From CloudKit")])
        let local = FakePlaceStore()

        let provider = PlaceProvider(repository: remote, store: local)
        let result = try await provider.places()

        #expect(result.first?.nama == "From CloudKit")
        #expect(local.savedPlaces?.isEmpty == false)
    }

    @Test("after fetching, the store is marked as seeded")
    func marksSeededAfterFetch() async throws {
        let remote = FakePlaceRepository(places: [.stub(nama: "From CloudKit")])
        let local = FakePlaceStore()

        let provider = PlaceProvider(repository: remote, store: local)
        _ = try await provider.places()

        #expect(local.hasSeededData == true)
    }
}
