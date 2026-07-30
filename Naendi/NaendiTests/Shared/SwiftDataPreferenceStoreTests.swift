//
//  SwiftDataPreferenceStoreTests.swift
//  NaendiTests
//
//  Exercises the real SwiftData-backed preference store. As in
//  SwiftDataPlaceStoreTests, the suite shares one on-disk container for the
//  process and clears it between tests; a "relaunch" is a fresh ModelContext
//  over that same container.
//

import Testing
import Foundation
import SwiftData
@testable import Naendi

@Suite(.serialized)
@MainActor
struct SwiftDataPreferenceStoreTests {

    private static let container: ModelContainer = {
        let url = URL.temporaryDirectory.appending(path: "preferencestore-tests-\(UUID().uuidString).store")
        // cloudKitDatabase: .none for the same reason as the places store — the
        // CloudKit entitlement would otherwise enable mirroring and reject the
        // schema.
        return try! ModelContainer(
            for: UserPreference.self,
            configurations: ModelConfiguration(url: url, cloudKitDatabase: .none)
        )
    }()

    init() throws {
        let context = ModelContext(Self.container)
        try context.delete(model: UserPreference.self)
        try context.save()
    }

    private func newStore() -> SwiftDataPreferenceStore {
        SwiftDataPreferenceStore(context: ModelContext(Self.container))
    }

    @Test("a fresh store has no saved preferences")
    func freshStoreIsEmpty() throws {
        #expect(try newStore().loadCriteria() == nil)
    }

    @Test("saved preferences survive a relaunch")
    func savePersistsAcrossContexts() throws {
        let criteria = PreferenceCriteria(
            locationName: "Tunjungan",
            coordinate: Coordinate(latitude: -7.2625, longitude: 112.7381),
            radiusKm: 5,
            budget: .fiftyToOneHundred,
            type: "Restaurant",
            vibe: "Calm",
            startMinutes: 18 * 60,
            endMinutes: 20 * 60,
            halal: .halal,
            outputResult: 8,
            sortBy: .distance
        )
        try newStore().saveCriteria(criteria)

        // Simulate a relaunch.
        let loaded = try newStore().loadCriteria()
        #expect(loaded == criteria)
    }

    @Test("nil type and vibe round-trip as Any rather than becoming empty strings")
    func anyValuesRoundTrip() throws {
        let criteria = PreferenceCriteria(type: nil, vibe: nil)
        try newStore().saveCriteria(criteria)

        let loaded = try newStore().loadCriteria()
        #expect(loaded?.type == nil)
        #expect(loaded?.vibe == nil)
    }

    @Test("an absent location round-trips as no coordinate")
    func absentLocationRoundTrips() throws {
        try newStore().saveCriteria(PreferenceCriteria(coordinate: nil))
        #expect(try newStore().loadCriteria()?.coordinate == nil)
    }

    @Test("saving twice updates the single row instead of adding another")
    func saveIsASingleton() throws {
        let store = newStore()
        try store.saveCriteria(PreferenceCriteria(radiusKm: 1))
        try store.saveCriteria(PreferenceCriteria(radiusKm: 9))

        let context = ModelContext(Self.container)
        let rows = try context.fetch(FetchDescriptor<UserPreference>())
        #expect(rows.count == 1)
        #expect(try newStore().loadCriteria()?.radiusKm == 9)
    }

    @Test("duplicate rows are collapsed on the next save")
    func collapsesDuplicates() throws {
        // Plant duplicates directly, simulating rows left by an earlier bug.
        let context = ModelContext(Self.container)
        context.insert(UserPreference(criteria: PreferenceCriteria(radiusKm: 1)))
        context.insert(UserPreference(criteria: PreferenceCriteria(radiusKm: 2)))
        try context.save()

        try newStore().saveCriteria(PreferenceCriteria(radiusKm: 7))

        let verifyContext = ModelContext(Self.container)
        let rows = try verifyContext.fetch(FetchDescriptor<UserPreference>())
        #expect(rows.count == 1)
        #expect(rows.first?.radius == 7)
    }

    @Test("an unrecognised stored enum value falls back to its default")
    func unknownRawValuesFallBack() throws {
        let context = ModelContext(Self.container)
        let row = UserPreference(criteria: .default)
        row.sortBy = "not-a-sort-option"
        row.halalPreference = "not-a-halal-option"
        row.budgetOptionID = "not-a-budget"
        context.insert(row)
        try context.save()

        let loaded = try newStore().loadCriteria()
        #expect(loaded?.sortBy == .surprise)
        #expect(loaded?.halal == .any)
        #expect(loaded?.budget == .any)
    }
}
