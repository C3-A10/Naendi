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

    @Test("the landing carousel keeps the 10 most-reviewed places, descending")
    func loadsTop10ByReviewCount() async {
        let places = (1...15).map { Place.stub(id: "\($0)", nama: "Place \($0)", jumlahReview: $0) }
        let provider = FakePlaceProvider(stubbed: places.shuffled())
        let viewModel = makeViewModel()

        await viewModel.loadLandingPlaces(from: provider)

        #expect(viewModel.landingPagePlaces.count == 10)
        #expect(viewModel.landingPagePlaces.map(\.jumlahReview) == [15, 14, 13, 12, 11, 10, 9, 8, 7, 6])
        #expect(viewModel.isLoading == false)
    }

    @Test("the landing carousel returns everything when fewer than the limit exist")
    func returnsAllWhenBelowLimit() async {
        let places = (1...3).map { Place.stub(id: "\($0)", jumlahReview: $0) }
        let viewModel = makeViewModel()

        await viewModel.loadLandingPlaces(from: FakePlaceProvider(stubbed: places))

        #expect(viewModel.landingPagePlaces.count == 3)
        #expect(viewModel.landingPagePlaces.first?.jumlahReview == 3)
    }

    @Test("the landing carousel ignores preferences")
    func landingIgnoresPreferences() async {
        let places = [Place.stub(id: "1", typeTempat: "PKL", jumlahReview: 5)]
        let viewModel = makeViewModel()
        viewModel.criteria = PreferenceCriteria(type: "Cafe")

        await viewModel.loadLandingPlaces(from: FakePlaceProvider(stubbed: places))

        #expect(viewModel.landingPagePlaces.count == 1)
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
}
