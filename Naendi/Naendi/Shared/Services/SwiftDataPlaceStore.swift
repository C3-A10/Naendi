//
//  SwiftDataPlaceStore.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 17/07/26.
//
import SwiftData

final class SwiftDataPlaceStore: PlaceStore {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func save(_ places: [Place]) throws {
        for place in places {
            context.insert(PlaceEntity(from: place))
        }
        try context.save()
    }

    func loadPlaces() throws -> [Place] {
        let descriptor = FetchDescriptor<PlaceEntity>()
        let entities = try context.fetch(descriptor)
        return entities.map { $0.toPlace() }
    }

    var hasSeededData: Bool {
        seedState()?.isSeeded ?? false
    }

    func markSeeded() throws {
        if let existing = seedState() {
            existing.isSeeded = true
        } else {
            context.insert(SeedState(isSeeded: true))
        }
        try context.save()
    }

    private func seedState() -> SeedState? {
        try? context.fetch(FetchDescriptor<SeedState>()).first
    }

}
