//
//  PlaceProviderTests.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 17/07/26.
//

import Testing
@testable import Naendi

@Suite(.serialized)
@MainActor
struct PlaceProviderTests {

    init() {
        // The background fetch task is shared per launch; reset between tests.
        PlaceProvider.fetchTask = nil
        PlaceProvider.onRefreshed = nil
    }

    @Test("when local data exists, return it immediately and refresh in background")
    func returnsLocalDataImmediately() async throws {
        let remote = FakePlaceRepository(places: [.stub(nama: "From CloudKit")])
        let local = FakePlaceStore()
        local.hasSeededData = true
        local.storedPlaces = [.stub(nama: "From cache")]

        let provider = PlaceProvider(repository: remote, store: local)
        let result = try await provider.places()

        #expect(result.first?.nama == "From cache")

        // The background refresh upserts the remote data into the store.
        await PlaceProvider.fetchTask?.value
        #expect(local.storedPlaces.contains { $0.nama == "From CloudKit" })
    }

    @Test("when store is empty, return the first page and save it")
    func fetchesFirstPageWhenEmpty() async throws {
        let remote = FakePlaceRepository(places: [.stub(nama: "From CloudKit")])
        let local = FakePlaceStore()

        let provider = PlaceProvider(repository: remote, store: local)
        let result = try await provider.places()

        #expect(result.first?.nama == "From CloudKit")
        #expect(local.savedPlaces?.isEmpty == false)
    }

    @Test("store is marked seeded only after the full stream completes")
    func marksSeededAfterFullFetch() async throws {
        let remote = FakePlaceRepository(places: [.stub(nama: "From CloudKit")])
        let local = FakePlaceStore()

        let provider = PlaceProvider(repository: remote, store: local)
        _ = try await provider.places()

        await PlaceProvider.fetchTask?.value
        #expect(local.hasSeededData == true)
    }

    @Test("onRefreshed fires with the full dataset when the stream completes")
    func notifiesWhenRefreshCompletes() async throws {
        let remote = FakePlaceRepository(places: [
            .stub(id: "1", nama: "One"),
            .stub(id: "2", nama: "Two"),
        ])
        let local = FakePlaceStore()

        let provider = PlaceProvider(repository: remote, store: local)
        var refreshed: [Place] = []
        _ = try await provider.places { refreshed = $0 }

        await PlaceProvider.fetchTask?.value
        #expect(refreshed.count == 2)
    }
}
