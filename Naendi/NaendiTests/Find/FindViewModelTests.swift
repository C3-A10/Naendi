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
            .stub(nama: "Cafe A"),
            .stub(nama: "Cafe B"),
        ])
        let viewModel = FindViewModel(repository: fake)

        try await viewModel.load()

        #expect(viewModel.places.count == 2)
    }
}
