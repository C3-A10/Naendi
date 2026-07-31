//
//  PlaceMatcher.swift
//  Naendi
//


import CoreLocation
import Foundation

extension Place {
    var coordinate: Coordinate {
        Coordinate(latitude: latitude, longitude: longitude)
    }
}

enum PlaceHalalStatus: Equatable {
    case halal
    case nonHalal
    case unknown

    init(rawValue: String) {
        switch rawValue.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
        case "yes", "halal":
            self = .halal
        case "no", "non-halal", "non halal":
            self = .nonHalal
        default:
            self = .unknown
        }
    }
}

struct PlaceMatcher {
    var calendar: Calendar = .current

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func matches(
        _ place: Place,
        criteria: PreferenceCriteria,
        origin: Coordinate?,
        now: Date
    ) -> Bool {
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
        let status = PlaceHalalStatus(rawValue: place.halal)
        switch criteria.halal {
        case .any:
            return true
        case .halal:
            return status != .nonHalal
        case .nonHalal:
            return status == .nonHalal
        }
    }

    private func matchesRadius(
        _ place: Place,
        criteria: PreferenceCriteria,
        origin: Coordinate?
    ) -> Bool {
        guard let origin else { return false }
        let distance = origin.clLocation.distance(from: place.coordinate.clLocation)
        return distance <= criteria.radiusKm * 1_000
    }

    private func matchesBudget(_ place: Place, criteria: PreferenceCriteria) -> Bool {
        guard let budget = criteria.budgetRange else { return true }
        guard let price = place.priceRange else { return false }
        return price.fits(within: budget)
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
