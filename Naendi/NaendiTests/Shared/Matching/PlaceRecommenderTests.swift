//
//  PlaceRecommenderTests.swift
//  NaendiTests
//

import Testing
import Foundation
@testable import Naendi

struct PlaceRecommenderTests {

    private let recommender = PlaceRecommender()
    private let now = Date()

    /// 12 places on a line heading north, each one further away than the last.
    /// Review counts run the other way so a distance sort and a review sort
    /// cannot be confused for one another.
    private static let places: [Place] = (1...12).map { index in
        Place.stub(
            id: "\(index)",
            nama: "Place \(index)",
            latitude: Double(index) * 0.001,
            longitude: 0,
            jumlahReview: index
        )
    }

    private static let origin = Coordinate(latitude: 0, longitude: 0)

    private func recommend(
        _ criteria: PreferenceCriteria,
        origin: Coordinate? = PlaceRecommenderTests.origin,
        seed: UInt64 = 1
    ) -> [Place] {
        recommender.recommend(
            Self.places,
            criteria: criteria,
            origin: origin,
            now: now,
            seed: seed
        )
    }

    @Test("distance sort returns the nearest places, not an arbitrary slice")
    func sortsBeforeApplyingTheLimit() {
        let result = recommend(PreferenceCriteria(radiusKm: 100, outputResult: 3, sortBy: .distance))
        #expect(result.map(\.id) == ["1", "2", "3"])
    }

    @Test("the result never exceeds the requested count")
    func respectsOutputResult() {
        #expect(recommend(PreferenceCriteria(radiusKm: 100, outputResult: 5, sortBy: .distance)).count == 5)
    }

    @Test("asking for more than matched returns everything that matched")
    func returnsAllWhenBelowLimit() {
        let result = recommend(PreferenceCriteria(radiusKm: 100, outputResult: 50, sortBy: .distance))
        #expect(result.count == 12)
    }

    @Test("distance sort falls back to review count when there is no origin")
    func distanceFallsBackWithoutOrigin() {
        let result = recommend(
            PreferenceCriteria(outputResult: 3, sortBy: .distance),
            origin: nil
        )
        #expect(result.map(\.jumlahReview) == [12, 11, 10])
    }

    @Test("the same seed reproduces the same surprise order")
    func surpriseIsStableForASeed() {
        let criteria = PreferenceCriteria(radiusKm: 100, outputResult: 5, sortBy: .surprise)
        let first = recommend(criteria, seed: 42).map(\.id)
        let second = recommend(criteria, seed: 42).map(\.id)
        #expect(first == second)
    }

    @Test("a different seed produces a different surprise order")
    func surpriseVariesBySeed() {
        let criteria = PreferenceCriteria(radiusKm: 100, outputResult: 5, sortBy: .surprise)
        #expect(recommend(criteria, seed: 42).map(\.id) != recommend(criteria, seed: 7).map(\.id))
    }

    @Test("surprise samples the whole match set rather than shuffling a top-N")
    func surpriseSamplesEverything() {
        let criteria = PreferenceCriteria(radiusKm: 100, outputResult: 3, sortBy: .surprise)
        // Across many seeds, every place should be reachable — a shuffled
        // prefix would only ever surface the first three.
        let reachable = Set((0..<200).flatMap { recommend(criteria, seed: UInt64($0)).map(\.id) })
        #expect(reachable.count == 12)
    }

    @Test("filtering runs before sorting and limiting")
    func filtersBeforeOrdering() {
        // ~0.005 degrees of latitude is roughly 556 m, so a 0.7 km radius keeps
        // only the first handful of places.
        let result = recommend(PreferenceCriteria(radiusKm: 0.7, outputResult: 10, sortBy: .distance))
        #expect(result.count == 6)
        #expect(result.map(\.id) == ["1", "2", "3", "4", "5", "6"])
    }

    @Test("no matches yields an empty result rather than a fallback list")
    func noMatchesReturnsEmpty() {
        let result = recommend(PreferenceCriteria(radiusKm: 0.0001, outputResult: 5, sortBy: .distance))
        #expect(result.isEmpty)
    }

    @Test("a zero output count returns nothing")
    func zeroOutputReturnsNothing() {
        #expect(recommend(PreferenceCriteria(radiusKm: 100, outputResult: 0)).isEmpty)
    }
}
