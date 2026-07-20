//
//  PlaceMatcher.swift
//  Naendi
//
//  Decides whether a single place satisfies the user's preferences. Every
//  criterion must pass (a strict AND), but missing data is never treated as a
//  mismatch — only a direct contradiction rejects a place. Roughly 21% of the
//  dataset has no price and 75% has an unverified halal status, so excluding
//  unknowns would discard most of the catalogue.
//

import CoreLocation
import Foundation

extension Place {
    var coordinate: Coordinate {
        Coordinate(latitude: latitude, longitude: longitude)
    }
}

struct PlaceMatcher {
    var calendar: Calendar = .current

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// - Parameter origin: where the radius is measured from. When `nil` (no
    ///   selected location and no GPS fix) the radius criterion is skipped.
    func matches(
        _ place: Place,
        criteria: PreferenceCriteria,
        origin: Coordinate?,
        now: Date
    ) -> Bool {
        // Ordered cheapest-first so the price and schedule parsers run on the
        // fewest possible rows.
        matchesType(place, criteria: criteria)
            && matchesVibe(place, criteria: criteria)
            && matchesHalal(place, criteria: criteria)
            && matchesRadius(place, criteria: criteria, origin: origin)
            && matchesBudget(place, criteria: criteria)
            && matchesOpeningHours(place, criteria: criteria, now: now)
    }

    private func matchesType(_ place: Place, criteria: PreferenceCriteria) -> Bool {
        guard let type = criteria.type else { return true }
        return place.typeTempat.caseInsensitiveCompare(type) == .orderedSame
    }

    private func matchesVibe(_ place: Place, criteria: PreferenceCriteria) -> Bool {
        guard let vibe = criteria.vibe else { return true }
        return place.vibe.caseInsensitiveCompare(vibe) == .orderedSame
    }

    private func matchesHalal(_ place: Place, criteria: PreferenceCriteria) -> Bool {
        let status = place.halal.lowercased().trimmingCharacters(in: .whitespaces)
        switch criteria.halal {
        case .any:
            return true
        case .halal:
            // An unverified place is a candidate; only a known non-halal one is
            // a contradiction.
            return status != HalalPreference.nonHalal.rawValue
        case .nonHalal:
            return status == HalalPreference.nonHalal.rawValue
        }
    }

    private func matchesRadius(
        _ place: Place,
        criteria: PreferenceCriteria,
        origin: Coordinate?
    ) -> Bool {
        guard let origin else { return true }
        let distance = origin.clLocation.distance(from: place.coordinate.clLocation)
        return distance <= criteria.radiusKm * 1_000
    }

    private func matchesBudget(_ place: Place, criteria: PreferenceCriteria) -> Bool {
        guard let budget = criteria.budgetRange else { return true }
        guard let price = place.priceRange else { return true }
        return price.overlaps(budget)
    }

    private func matchesOpeningHours(
        _ place: Place,
        criteria: PreferenceCriteria,
        now: Date
    ) -> Bool {
        guard let hours = place.openingHours else { return true }
        let weekday = calendar.component(.weekday, from: now)
        return hours.isOpen(during: criteria.timeWindow, onWeekday: weekday) ?? true
    }
}
