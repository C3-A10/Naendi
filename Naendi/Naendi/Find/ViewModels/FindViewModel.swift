//
//  FindViewModel.swift
//  Naendi
//
//  Created by Bryan Samuel on 14/07/26.
//

import Observation

@Observable
final class FindViewModel {
    private let repository: PlaceRepository
    var places: [Place] = []

    init(repository: PlaceRepository) {
        self.repository = repository
    }

    func load() async throws {
        places = try await repository.getAllPlaces()
    }
}
