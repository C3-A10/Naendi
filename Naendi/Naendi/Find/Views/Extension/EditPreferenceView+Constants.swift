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
        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .none
        formatter.timeStyle = .short
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
            case .outputResult: "Output Results"
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
                "Choose the atmosphere that fits your mood, from quiet spaces to lively spots."
            case .preferredTime:
                "Select when you plan to visit so we can recommend places that fit your schedule."
            case .outputResult:
                "Set the number of places shown in your results."
            case .sortBy:
                "Choose how your recommendations are sorted."
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
