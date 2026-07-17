//
//  FindViewModelTests.swift
//  NaendiTests
//
//  Created by Mohammad Rizaldy Ramadhan on 16/07/26.
//

import Foundation

import Testing
@testable import Naendi

struct FindViewModelTests {
    @Test("loading places from the repository fills the view model")
    func loadFillsViewModel() async throws {
        let fake = FakePlaceRepository(places: [
            Place(name: "Cafe A", halalStatus: HalalStatus.halal),
            Place(name: "Cafe B", halalStatus: HalalStatus.nonHalal),
        ])
        let viewModel = FindViewModel(repository: fake)

        try await viewModel.load()

        #expect(viewModel.places.count == 2)
    }
}
