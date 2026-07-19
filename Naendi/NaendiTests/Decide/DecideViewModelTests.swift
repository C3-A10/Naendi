//
//  DecideViewModelTests.swift
//  NaendiTests
//

import Testing
@testable import Naendi

@MainActor
struct DecideViewModelTests {
    @Test("loads the top 10 places ranked by review count, descending")
    func loadsTop10ByReviewCount() async {
        // 15 places with review counts 1...15
        let places = (1...15).map { Place.stub(id: "\($0)", nama: "Place \($0)", jumlahReview: $0) }
        let provider = FakePlaceProvider(stubbed: places.shuffled())
        let viewModel = DecideViewModel()

        await viewModel.loadTopPlaces(from: provider)

        #expect(viewModel.places.count == 10)
        #expect(viewModel.places.map(\.jumlahReview) == [15, 14, 13, 12, 11, 10, 9, 8, 7, 6])
        #expect(viewModel.isLoading == false)
    }

    @Test("returns everything when fewer than the limit are available")
    func returnsAllWhenBelowLimit() async {
        let places = (1...3).map { Place.stub(id: "\($0)", jumlahReview: $0) }
        let provider = FakePlaceProvider(stubbed: places)
        let viewModel = DecideViewModel()

        await viewModel.loadTopPlaces(from: provider)

        #expect(viewModel.places.count == 3)
        #expect(viewModel.places.first?.jumlahReview == 3)
    }
}
