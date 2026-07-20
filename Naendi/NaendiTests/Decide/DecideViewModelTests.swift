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
    
    @Test("selecting two places stores both selected places")
        func selectingTwoPlacesStoresCorrectPlaces() {
            let viewModel = DecideViewModel()

            let place1 = Place.stub(id: "1", nama: "Cafe A")
            let place2 = Place.stub(id: "2", nama: "Cafe B")

            viewModel.toggleSelection(for: place1)
            viewModel.toggleSelection(for: place2)

            #expect(viewModel.selectedPlaces.count == 2)
            #expect(viewModel.selectedPlaces[0].id == place1.id)
            #expect(viewModel.selectedPlaces[1].id == place2.id)
            #expect(viewModel.isCompareLimitReached)
        }

        @Test("selecting the same place twice removes it")
        func selectingSamePlaceTwiceRemovesIt() {
            let viewModel = DecideViewModel()

            let place = Place.stub(id: "1", nama: "Cafe A")

            viewModel.toggleSelection(for: place)
            viewModel.toggleSelection(for: place)

            #expect(viewModel.selectedPlaces.isEmpty)
            #expect(!viewModel.isCompareLimitReached)
        }

        @Test("cannot select more than two places")
        func cannotSelectMoreThanTwoPlaces() {
            let viewModel = DecideViewModel()

            let place1 = Place.stub(id: "1")
            let place2 = Place.stub(id: "2")
            let place3 = Place.stub(id: "3")

            viewModel.toggleSelection(for: place1)
            viewModel.toggleSelection(for: place2)
            viewModel.toggleSelection(for: place3)

            #expect(viewModel.selectedPlaces.count == 2)
            #expect(viewModel.selectedPlaces.contains(where: { $0.id == place1.id }))
            #expect(viewModel.selectedPlaces.contains(where: { $0.id == place2.id }))
            #expect(!viewModel.selectedPlaces.contains(where: { $0.id == place3.id }))
        }

        @Test("clearSelectedPlaces removes all selected places")
        func clearSelectedPlacesRemovesEverything() {
            let viewModel = DecideViewModel()

            viewModel.toggleSelection(for: Place.stub(id: "1"))
            viewModel.toggleSelection(for: Place.stub(id: "2"))

            #expect(viewModel.selectedPlaces.count == 2)

            viewModel.clearSelectedPlaces()

            #expect(viewModel.selectedPlaces.isEmpty)
            #expect(!viewModel.isCompareLimitReached)
        }
}
