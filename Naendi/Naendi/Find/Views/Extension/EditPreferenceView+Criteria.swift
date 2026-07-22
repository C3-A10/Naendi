//
//  EditPreferenceView+Criteria.swift
//  Naendi
//
//  Created by Bryan Samuel on 22/07/26.
//

import MapKit
import SwiftUI

// MARK: - Criteria

extension EditPreferenceView {
    /// The placeholder is still showing when the user never picked a location,
    /// in which case matching falls back to their GPS position.
    var hasSelectedLocation: Bool {
        selectedLocationName != Self.locationPlaceholder
    }

    var editedCriteria: PreferenceCriteria {
        PreferenceCriteria(
            locationName: hasSelectedLocation ? selectedLocationName : nil,
            coordinate: hasSelectedLocation ? Coordinate(selectedCoordinate) : nil,
            radiusKm: radius,
            budget: budgetViewModel.selectedBudgetOption,
            customMinBudget: Self.budgetValue(budgetViewModel.minimumBudget),
            customMaxBudget: Self.budgetValue(budgetViewModel.maximumBudget),
            type: selectedType == Self.anyOption ? nil : selectedType,
            vibe: selectedVibe == Self.anyOption ? nil : selectedVibe,
            startMinutes: Self.minutes(from: preferredStartTime),
            endMinutes: Self.minutes(from: preferredEndTime),
            halal: selectedHalalOption,
            outputResult: outputResult,
            sortBy: selectedSortOption
        )
    }

    static func date(fromMinutes minutes: Int) -> Date {
        Calendar.current.date(
            bySettingHour: minutes / 60,
            minute: minutes % 60,
            second: 0,
            of: Date()
        ) ?? Date()
    }

    static func minutes(from date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    static func budgetText(_ value: Double?) -> String {
        guard let value, value > 0 else { return "" }
        return budgetFormatter.string(from: NSNumber(value: Int(value))) ?? ""
    }

    func localizedPreferenceValue(_ value: String) -> String {
        switch value {
        case "Any":
            String(localized: "Any")
        case "Restaurant":
            String(localized: "Restaurant")
        case "Cafe":
            String(localized: "Cafe")
        case "Warkop":
            String(localized: "Warkop")
        case "PKL":
            String(localized: "PKL")
        case "Drinks":
            String(localized: "Drinks")
        case "Bakery":
            String(localized: "Bakery")
        case "Calm":
            String(localized: "Calm")
        case "Balanced":
            String(localized: "Balanced")
        case "Lively":
            String(localized: "Lively")
        default:
            value
        }
    }

    /// Mirrors CustomBudgetRow's grouped formatting by ignoring separators.
    static func budgetValue(_ text: String) -> Double? {
        let digits = text.filter(\.isNumber)
        guard !digits.isEmpty, let value = Int(digits) else { return nil }
        return Double(value)
    }
}
