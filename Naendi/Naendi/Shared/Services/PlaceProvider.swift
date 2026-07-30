//
//  PlaceProvider.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 17/07/26.
//

protocol PlaceProviding {
    func places(onRefreshed: (([Place]) -> Void)?) async throws -> [Place]
}

extension PlaceProviding {
    func places() async throws -> [Place] { try await places(onRefreshed: nil) }
}

final class PlaceProvider: PlaceProviding {
    private let repository: PlaceRepository
    private let store: PlaceStore

    // One background fetch per launch, shared across provider instances.
    // The latest caller's onRefreshed wins, so the screen currently loading
    // is the one refreshed when the full fetch lands.
    static var fetchTask: Task<Void, Never>?
    static var onRefreshed: (([Place]) -> Void)?

    init(repository: PlaceRepository, store: PlaceStore) {
        self.repository = repository
        self.store = store
    }

    func places(onRefreshed: (([Place]) -> Void)?) async throws -> [Place] {
        var local = try store.loadPlaces()
        if local.isEmpty {
            // ponytail: page 1 is refetched by the background stream below; upsert dedupes.
            local = try await repository.fetchFirstPage()
            try store.save(local)
        }
        if let onRefreshed { Self.onRefreshed = onRefreshed }
        startFetchIfNeeded()
        return local
    }

    private func startFetchIfNeeded() {
        guard Self.fetchTask == nil else { return }
        Self.fetchTask = Task { [repository, store] in
            do {
                // ponytail: per-page saves run on the main actor (~100 rows each);
                // move to a background ModelContext if Instruments shows hitches.
                try await repository.streamAllPlaces { try store.save($0) }
                try store.markSeeded()
                Self.onRefreshed?(try store.loadPlaces())
                Self.onRefreshed = nil
            } catch {
                Self.fetchTask = nil // failed: next places() call retries
            }
        }
    }
}
