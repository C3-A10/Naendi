//
//  PreferenceCriteria.swift
//  Naendi
//
//  The plain-value form of the user's saved preferences. Keeps SwiftData out
//  of the matching layer, the same way `Place` does for `PlaceEntity`.
//

import CoreLocation
import Foundation

/// A plain, equatable coordinate. `CLLocationCoordinate2D` is neither
/// `Equatable` nor `Codable`, which makes it awkward to compare and to test.
struct Coordinate: Equatable {
    let latitude: Double
    let longitude: Double

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    init(_ coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum HalalPreference: String, CaseIterable {
    case halal
    case nonHalal = "non-halal"
    case any

    var title: String {
        switch self {
        case .halal: String(localized: "Halal")
        case .nonHalal: String(localized: "Non-halal")
        case .any: String(localized: "Any")
        }
    }
}

enum SortOption: String, CaseIterable {
    case surprise
    case distance

    var title: String {
        switch self {
        case .surprise: String(localized: "Surprise Me")
        case .distance: String(localized: "Distance")
        }
    }
}

struct PreferenceCriteria: Equatable {
    /// Display name of the searched location; `nil` when the user never picked one.
    var locationName: String?
    /// Where to measure from. `nil` falls back to the device's GPS location.
    var coordinate: Coordinate?
    var radiusKm: Double
    var budget: BudgetOption
    var customMinBudget: Double?
    var customMaxBudget: Double?
    /// `nil` means "Any" — the criterion is not applied.
    var type: String?
    /// `nil` means "Any" — the criterion is not applied.
    var vibe: String?
    var startMinutes: Int
    var endMinutes: Int
    var halal: HalalPreference
    var outputResult: Int
    var sortBy: SortOption

    init(
        locationName: String? = nil,
        coordinate: Coordinate? = nil,
        radiusKm: Double = 3.0,
        budget: BudgetOption = .any,
        customMinBudget: Double? = nil,
        customMaxBudget: Double? = nil,
        type: String? = nil,
        vibe: String? = nil,
        startMinutes: Int = 11 * 60,
        endMinutes: Int = 13 * 60,
        halal: HalalPreference = .any,
        outputResult: Int = 5,
        sortBy: SortOption = .surprise
    ) {
        self.locationName = locationName
        self.coordinate = coordinate
        self.radiusKm = radiusKm
        self.budget = budget
        self.customMinBudget = customMinBudget
        self.customMaxBudget = customMaxBudget
        self.type = type
        self.vibe = vibe
        self.startMinutes = startMinutes
        self.endMinutes = endMinutes
        self.halal = halal
        self.outputResult = outputResult
        self.sortBy = sortBy
    }

    static let `default` = PreferenceCriteria()

    var timeWindow: MinuteInterval {
        MinuteInterval(start: startMinutes, end: endMinutes)
    }

    /// The price band to match against, or `nil` when budget is unconstrained.
    var budgetRange: PriceRange? {
        guard budget == .custom else { return budget.range }
        guard customMinBudget != nil || customMaxBudget != nil else { return nil }
        return PriceRange(lowerBound: customMinBudget, upperBound: customMaxBudget)
    }
}
