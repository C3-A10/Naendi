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

    // Seeding state is derived from the persistent store itself, so the local
    // cache survives across app launches: any persisted row means we've seeded.
    var hasSeededData: Bool {
        let count = (try? context.fetchCount(FetchDescriptor<PlaceEntity>())) ?? 0
        return count > 0
    }

    func markSeeded() throws {
        // No-op: presence of persisted rows already marks the store as seeded.
    }

}
