//
//  PlaceRecommender.swift
//  Naendi
//
//  Turns the full catalogue into the handful of places shown on the results
//  screen: filter by preferences, order, then cut to the requested count.
//

import CoreLocation
import Foundation

struct SplitMix64: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

struct PlaceRecommender {
    var matcher: PlaceMatcher

    init(matcher: PlaceMatcher = PlaceMatcher()) {
        self.matcher = matcher
    }

    func recommend(
        _ places: [Place],
        criteria: PreferenceCriteria,
        origin: Coordinate?,
        now: Date,
        seed: UInt64
    ) -> [Place] {
        let matched = places.filter {
            matcher.matches($0, criteria: criteria, origin: origin, now: now)
        }

        let ordered = order(matched, by: criteria.sortBy, origin: origin, seed: seed)
        return Array(ordered.prefix(max(0, criteria.outputResult)))
    }

    private func order(
        _ places: [Place],
        by sortOption: SortOption,
        origin: Coordinate?,
        seed: UInt64
    ) -> [Place] {
        switch sortOption {
        case .surprise:
            var generator = SplitMix64(seed: seed)
            return places.shuffled(using: &generator)

        case .distance:
            guard let origin else {
                return places.sorted { $0.jumlahReview > $1.jumlahReview }
            }
            let originLocation = origin.clLocation
            return places
                .map { ($0, originLocation.distance(from: $0.coordinate.clLocation)) }
                .sorted { $0.1 < $1.1 }
                .map(\.0)
        }
    }
}
