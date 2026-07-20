//
//  UserPreference.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 14/07/26.
//
//  The persisted form of the user's search preferences. Exactly one row is
//  expected; see SwiftDataPreferenceStore. Enum-backed values are stored as
//  their raw strings so the schema stays free of SwiftData-specific types.
//

import Foundation
import SwiftData

@Model
final class UserPreference {
    var locationName: String?
    /// Latitude and longitude of the location the user searched for. Both nil
    /// means no location was picked, and matching falls back to GPS.
    var latitude: Double?
    var longitude: Double?
    var radius: Double = 3.0
    var budgetOptionID: String = BudgetOption.any.rawValue
    var customMinBudget: Double?
    var customMaxBudget: Double?
    /// nil means "Any" — the criterion is not applied.
    var type: String?
    /// nil means "Any" — the criterion is not applied.
    var vibe: String?
    /// Minutes from midnight. Stored as a plain offset rather than a Date so
    /// there is no stale calendar day to strip on every read.
    var startMinutes: Int = 11 * 60
    var endMinutes: Int = 13 * 60
    var halalPreference: String = HalalPreference.any.rawValue
    var outputResult: Int = 5
    var sortBy: String = SortOption.surprise.rawValue
    /// Used to pick the newest row if duplicates ever appear.
    var updatedAt: Date = Date.now

    init(criteria: PreferenceCriteria = .default) {
        apply(criteria)
    }

    /// Overwrites every field from `criteria` and stamps `updatedAt`.
    func apply(_ criteria: PreferenceCriteria) {
        locationName = criteria.locationName
        latitude = criteria.coordinate?.latitude
        longitude = criteria.coordinate?.longitude
        radius = criteria.radiusKm
        budgetOptionID = criteria.budget.rawValue
        customMinBudget = criteria.customMinBudget
        customMaxBudget = criteria.customMaxBudget
        type = criteria.type
        vibe = criteria.vibe
        startMinutes = criteria.startMinutes
        endMinutes = criteria.endMinutes
        halalPreference = criteria.halal.rawValue
        outputResult = criteria.outputResult
        sortBy = criteria.sortBy.rawValue
        updatedAt = .now
    }

    /// Unrecognised raw strings fall back to the default rather than failing
    /// the read, so a stale row can never block the results screen.
    var criteria: PreferenceCriteria {
        let coordinate: Coordinate? = {
            guard let latitude, let longitude else { return nil }
            return Coordinate(latitude: latitude, longitude: longitude)
        }()

        return PreferenceCriteria(
            locationName: locationName,
            coordinate: coordinate,
            radiusKm: radius,
            budget: BudgetOption(rawValue: budgetOptionID) ?? .any,
            customMinBudget: customMinBudget,
            customMaxBudget: customMaxBudget,
            type: type,
            vibe: vibe,
            startMinutes: startMinutes,
            endMinutes: endMinutes,
            halal: HalalPreference(rawValue: halalPreference) ?? .any,
            outputResult: outputResult,
            sortBy: SortOption(rawValue: sortBy) ?? .surprise
        )
    }
}
