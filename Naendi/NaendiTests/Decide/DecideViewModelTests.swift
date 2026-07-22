//
//  DecideViewModelTests.swift
//  NaendiTests
//

import Testing
import Foundation
import CoreLocation
@testable import Naendi

@MainActor
struct DecideViewModelTests {

    private func makeViewModel(
        location: CLLocation? = CLLocation(latitude: 0, longitude: 0)
    ) -> DecideViewModel {
        DecideViewModel(locationProvider: FakeLocationProvider(currentLocation: location))
    }

    // MARK: - Landing showcase

    @Test("the landing showcase leads with nearby, then top restaurants, then top cafes")
    func loadsGroupedShowcase() async {
        let places = [
            Place.stub(id: "near-cafe", latitude: 0.001, longitude: 0, typeTempat: "Cafe", jumlahReview: 10),
            Place.stub(id: "top-resto", latitude: 8, longitude: 0, typeTempat: "Restaurant", jumlahReview: 900),
            Place.stub(id: "top-cafe", latitude: 9, longitude: 0, typeTempat: "Cafe", jumlahReview: 500),
        ]
        let viewModel = makeViewModel(location: CLLocation(latitude: 0, longitude: 0))

        await viewModel.loadLandingPlaces(from: FakePlaceProvider(stubbed: places), perGroup: 1)

        // near-cafe is closest → Nearby; then the top restaurant, then the top cafe.
        #expect(viewModel.landingPagePlaces.map(\.id) == ["near-cafe", "top-resto", "top-cafe"])
        #expect(viewModel.landingTag(for: places[0]) == .nearby)
        #expect(viewModel.landingTag(for: places[1]) == .top(type: "Restaurant"))
        #expect(viewModel.landingTag(for: places[2]) == .top(type: "Cafe"))
        #expect(viewModel.isLoading == false)
    }

    @Test("a place appears once, tagged by its highest-priority group")
    func groupsAreDeduped() async {
        // The nearest place is also the top restaurant; Nearby wins and it isn't repeated.
        let places = [
            Place.stub(id: "resto", latitude: 0, longitude: 0, typeTempat: "Restaurant", jumlahReview: 900),
            Place.stub(id: "cafe", latitude: 5, longitude: 0, typeTempat: "Cafe", jumlahReview: 500),
        ]
        let viewModel = makeViewModel(location: CLLocation(latitude: 0, longitude: 0))

        await viewModel.loadLandingPlaces(from: FakePlaceProvider(stubbed: places), perGroup: 1)

        #expect(viewModel.landingPagePlaces.map(\.id) == ["resto", "cafe"])
        #expect(viewModel.landingTag(for: places[0]) == .nearby)
    }

    @Test("without a location the Nearby group is skipped, top groups still show")
    func skipsNearbyWithoutLocation() async {
        let places = [
            Place.stub(id: "resto", typeTempat: "Restaurant", jumlahReview: 900),
            Place.stub(id: "cafe", typeTempat: "Cafe", jumlahReview: 500),
        ]
        let viewModel = makeViewModel(location: nil)

        await viewModel.loadLandingPlaces(from: FakePlaceProvider(stubbed: places), perGroup: 1)

        #expect(viewModel.landingPagePlaces.map(\.id) == ["resto", "cafe"])
        #expect(viewModel.landingTag(for: places[0]) == .top(type: "Restaurant"))
    }

    // MARK: - Recommendations

    @Test("applying preferences filters the catalogue and moves to results")
    func filtersByPreferences() async {
        let places = [
            Place.stub(id: "cafe", typeTempat: "Cafe"),
            Place.stub(id: "pkl", typeTempat: "PKL")
        ]
        let viewModel = makeViewModel()

        await viewModel.loadRecommendations(
            from: FakePlaceProvider(stubbed: places),
            criteria: PreferenceCriteria(type: "Cafe")
        )

        #expect(viewModel.places.map(\.id) == ["cafe"])
        #expect(viewModel.phase == .results)
    }

    @Test("matching nothing stays on results rather than falling back to landing")
    func zeroMatchesStaysOnResults() async {
        // The regression this guards: routing used to switch on places.isEmpty,
        // so a legitimately empty result bounced the user to the landing page.
        let places = [Place.stub(id: "pkl", typeTempat: "PKL")]
        let viewModel = makeViewModel()

        await viewModel.loadRecommendations(
            from: FakePlaceProvider(stubbed: places),
            criteria: PreferenceCriteria(type: "Cafe")
        )

        #expect(viewModel.places.isEmpty)
        #expect(viewModel.phase == .results)
    }

    @Test("a fetch failure still lands on results with an error message")
    func failureStaysOnResults() async {
        let provider = FakePlaceProvider(error: FakePlaceProviderError.boom)
        let viewModel = makeViewModel()

        await viewModel.loadRecommendations(from: provider, criteria: .default)

        #expect(viewModel.places.isEmpty)
        #expect(viewModel.phase == .results)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("a legitimate empty result does not report a provider error")
    func emptyResultIsNotAnError() async {
        let viewModel = makeViewModel()

        await viewModel.loadRecommendations(
            from: FakePlaceProvider(stubbed: [Place.stub(typeTempat: "PKL")]),
            criteria: PreferenceCriteria(type: "Cafe")
        )

        #expect(viewModel.places.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("recommendations explain when radius has no origin")
    func missingOriginIsReported() async {
        let viewModel = makeViewModel(location: nil)

        await viewModel.loadRecommendations(
            from: FakePlaceProvider(stubbed: [.stub()]),
            criteria: .default
        )

        #expect(viewModel.places.isEmpty)
        #expect(viewModel.errorMessage?.contains("Location is unavailable") == true)
        #expect(viewModel.phase == .results)
    }

    @Test("the requested output count caps the results")
    func respectsOutputResult() async {
        let places = (1...10).map { Place.stub(id: "\($0)", typeTempat: "Cafe") }
        let viewModel = makeViewModel()

        await viewModel.loadRecommendations(
            from: FakePlaceProvider(stubbed: places),
            criteria: PreferenceCriteria(type: "Cafe", outputResult: 3)
        )

        #expect(viewModel.places.count == 3)
    }

    // MARK: - Origin

    @Test("the searched location wins over GPS")
    func originPrefersSelectedLocation() {
        let viewModel = makeViewModel(location: CLLocation(latitude: 10, longitude: 10))
        viewModel.criteria = PreferenceCriteria(coordinate: Coordinate(latitude: -7.25, longitude: 112.75))

        #expect(viewModel.origin == Coordinate(latitude: -7.25, longitude: 112.75))
    }

    @Test("without a searched location the origin falls back to GPS")
    func originFallsBackToGPS() {
        let viewModel = makeViewModel(location: CLLocation(latitude: 10, longitude: 20))
        viewModel.criteria = PreferenceCriteria(coordinate: nil)

        #expect(viewModel.origin == Coordinate(latitude: 10, longitude: 20))
    }

    @Test("with neither a location nor a fix there is no origin")
    func originIsNilWithoutAnything() {
        let viewModel = makeViewModel(location: nil)
        #expect(viewModel.origin == nil)
    }

    @Test("distance is measured from the same origin the radius filter uses")
    func distanceUsesOrigin() {
        let viewModel = makeViewModel(location: CLLocation(latitude: 50, longitude: 50))
        viewModel.criteria = PreferenceCriteria(coordinate: Coordinate(latitude: 0, longitude: 0))

        // Roughly 111 m north of the selected origin, not of the GPS fix.
        let place = Place.stub(latitude: 0.001, longitude: 0)
        #expect(viewModel.calculateDistance(to: place) == "111 m")
    }

    @Test("distance shows a dash when there is nothing to measure from")
    func distanceWithoutOrigin() {
        let viewModel = makeViewModel(location: nil)
        #expect(viewModel.calculateDistance(to: .stub()) == "-")
    }

    // MARK: - Preference persistence

    @Test("stored preferences are restored without running a search")
    func restoresStoredCriteria() {
        let stored = PreferenceCriteria(radiusKm: 7, type: "Bakery")
        let viewModel = makeViewModel()

        viewModel.restoreCriteria(from: FakePreferenceStore(stored: stored))

        #expect(viewModel.criteria == stored)
        #expect(viewModel.phase == .landing)
        #expect(viewModel.places.isEmpty)
    }

    @Test("restoring from an empty store leaves the defaults in place")
    func restoreFromEmptyStore() {
        let viewModel = makeViewModel()
        viewModel.restoreCriteria(from: FakePreferenceStore(stored: nil))
        #expect(viewModel.criteria == .default)
        #expect(viewModel.persistenceErrorMessage == nil)
    }

    @Test("a restore failure keeps defaults and exposes a persistence warning")
    func restoreFailureIsNonBlocking() {
        let store = FakePreferenceStore()
        store.errorToThrow = FakePlaceProviderError.boom
        let viewModel = makeViewModel()

        viewModel.restoreCriteria(from: store)

        #expect(viewModel.criteria == .default)
        #expect(viewModel.persistenceErrorMessage != nil)
    }

    @Test("applying preferences saves them and searches")
    func applyPersistsAndSearches() async {
        let store = FakePreferenceStore()
        let places = [Place.stub(id: "cafe", typeTempat: "Cafe")]
        let viewModel = makeViewModel()
        let criteria = PreferenceCriteria(type: "Cafe")

        await viewModel.applyPreferences(
            criteria,
            store: store,
            provider: FakePlaceProvider(stubbed: places)
        )

        #expect(store.stored == criteria)
        #expect(store.saveCount == 1)
        #expect(viewModel.places.map(\.id) == ["cafe"])
        #expect(viewModel.phase == .results)
    }

    @Test("a failed save does not block the search")
    func failedSaveStillSearches() async {
        let store = FakePreferenceStore()
        store.errorToThrow = FakePlaceProviderError.boom
        let viewModel = makeViewModel()

        await viewModel.applyPreferences(
            PreferenceCriteria(type: "Cafe"),
            store: store,
            provider: FakePlaceProvider(stubbed: [Place.stub(id: "cafe", typeTempat: "Cafe")])
        )

        #expect(viewModel.places.map(\.id) == ["cafe"])
        #expect(viewModel.phase == .results)
        #expect(viewModel.persistenceErrorMessage != nil)
    }

    @Test("a successful save clears an earlier persistence warning")
    func successfulSaveClearsPersistenceWarning() async {
        let viewModel = makeViewModel()
        viewModel.persistenceErrorMessage = "Old error"

        await viewModel.applyPreferences(
            .default,
            store: FakePreferenceStore(),
            provider: FakePlaceProvider(stubbed: [.stub()])
        )

        #expect(viewModel.persistenceErrorMessage == nil)
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
