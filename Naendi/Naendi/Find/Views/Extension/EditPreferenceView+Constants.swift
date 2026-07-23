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
