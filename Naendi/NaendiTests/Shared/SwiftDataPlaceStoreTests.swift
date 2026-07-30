//
//  SwiftDataPlaceStoreTests.swift
//  NaendiTests
//
//  Exercises the real SwiftData-backed store. SwiftData only tolerates a single
//  ModelContainer per process for a given schema, so the whole suite shares one
//  on-disk container and resets its contents before each test. A "relaunch" is
//  simulated with a fresh ModelContext over that same container.
//

import Testing
import Foundation
import SwiftData
@testable import Naendi

@Suite(.serialized)
@MainActor
struct SwiftDataPlaceStoreTests {

    // One container for the whole process (see file note). On-disk temp store.
    private static let container: ModelContainer = {
        let url = URL.temporaryDirectory.appending(path: "placestore-tests-\(UUID().uuidString).store")
        // cloudKitDatabase: .none — the store is a local cache; with the app's
        // CloudKit entitlement present, .automatic would enable mirroring and
        // reject the schema (non-optional attributes without defaults).
        return try! ModelContainer(
            for: PlaceEntity.self, SeedState.self,
            configurations: ModelConfiguration(url: url, cloudKitDatabase: .none)
        )
    }()

    // Swift Testing makes a fresh struct instance per test, so this clears shared
    // state before every test runs.
    init() throws {
        let context = ModelContext(Self.container)
        try context.delete(model: PlaceEntity.self)
        try context.delete(model: SeedState.self)
        try context.save()
    }

    private func newStore() -> SwiftDataPlaceStore {
        SwiftDataPlaceStore(context: ModelContext(Self.container))
    }

    @Test("a fresh store reports it has not been seeded")
    func freshStoreIsNotSeeded() {
        #expect(newStore().hasSeededData == false)
    }

    @Test("markSeeded persists so a new context on the same store stays seeded")
    func markSeededPersistsAcrossInstances() throws {
        let first = newStore()
        try first.save([.stub(id: "1", nama: "A")])
        try first.markSeeded()

        // Simulate a relaunch: brand-new store/context over the same container.
        let second = newStore()
        #expect(second.hasSeededData == true)
        #expect(try second.loadPlaces().count == 1)
    }

    @Test("saved rows WITHOUT markSeeded do not count as seeded (interrupted fetch)")
    func rowsWithoutMarkAreNotSeeded() throws {
        let store = newStore()
        // Simulate a partial seed: rows landed, but the full fetch never finished
        // so markSeeded() was never called.
        try store.save([.stub(id: "1", nama: "A"), .stub(id: "2", nama: "B")])

        #expect(store.hasSeededData == false)
    }

    @Test("saving a second batch adds to existing rows (per-page seeding)")
    func saveAccumulatesBatches() throws {
        let store = newStore()
        try store.save([.stub(id: "1", nama: "A")])
        try store.save([.stub(id: "2", nama: "B")])

        #expect(try store.loadPlaces().count == 2)
    }

    @Test("re-seeding replaces the dataset instead of duplicating rows")
    func reSaveReplacesInsteadOfDuplicating() throws {
        let store = newStore()
        try store.save([.stub(id: "1", nama: "A")])
        try store.save([.stub(id: "1", nama: "A (updated)")])

        let loaded = try store.loadPlaces()
        #expect(loaded.count == 1)
        #expect(loaded.first?.nama == "A (updated)")
    }
}
