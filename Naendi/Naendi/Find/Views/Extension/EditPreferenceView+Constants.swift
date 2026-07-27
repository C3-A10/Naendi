//
//  EditPreferenceView+Constants.swift
//  Naendi
//
//  Created by Bryan Samuel on 22/07/26.
//


import CoreLocation
import SwiftUI

// MARK: - Constants

extension EditPreferenceView {

    static let anyOption = "Any"

    static let locationPlaceholder = String(localized: "Search Location")

    static let defaultCoordinate = CLLocationCoordinate2D(
        latitude: -7.2575,
        longitude: 112.7521
    )

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static let budgetFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    enum PreferredTimeField {
        case start
        case end
    }

    enum PreferenceTooltip: Hashable {
        case type
        case vibe
        case preferredTime
        case outputResult
        case sortBy

        var title: LocalizedStringResource {
            switch self {
            case .type: "Type"
            case .vibe: "Vibe"
            case .preferredTime: "Preferred Time"
            case .outputResult: "Output Result"
            case .sortBy: "Sort By"
            }
        }

        var accessibilityLabel: LocalizedStringResource {
            switch self {
            case .type: "About Type"
            case .vibe: "About Vibe"
            case .preferredTime: "About Preferred Time"
            case .outputResult: "About Output Result"
            case .sortBy: "About Sort By"
            }
        }

        var description: LocalizedStringResource {
            switch self {
            case .type:
                "Choose the type of place you're looking for, such as cafes, restaurants, street food, or more."
            case .vibe:
                "Choose the atmosphere you prefer, from calm and relaxed to lively and energetic."
            case .preferredTime:
                "Set when you plan to visit so the results can match places that are open at that time."
            case .outputResult:
                "Choose how many place recommendations you want to see in your results."
            case .sortBy:
                "Choose how your results are ordered, such as by distance, rating, or review count."
            }
        }
    }

    var typeOptions: [String] {
        [
            Self.anyOption,
            "Restaurant",
            "Cafe",
            "Warkop",
            "PKL",
            "Drinks",
            "Bakery"
        ]
    }

    var vibeOptions: [String] {
        [
            Self.anyOption,
            "Calm",
            "Balanced",
            "Lively"
        ]
    }
}
