//
//  PlaceProvider.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 17/07/26.
//

final class PlaceProvider {
    private let repository: PlaceRepository
    private let store: PlaceStore

    init(repository: PlaceRepository, store: PlaceStore) {
        self.repository = repository
        self.store = store
    }

    func places() async throws -> [Place] {
        if store.hasSeededData {
            return try store.loadPlaces()
        }

        let fetched = try await repository.getAllPlaces()
        try store.save(fetched)
        try store.markSeeded()
        return fetched
    }
}
