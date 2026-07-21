//
//  SwiftDataPreferenceStore.swift
//  Naendi
//
//  Keeps preferences as a single row, fetched-or-created on save. A uniqueness
//  constraint would express the same intent, but doing it here keeps the rule
//  visible and testable.
//

import Foundation
import SwiftData

final class SwiftDataPreferenceStore: PreferenceStoring {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func loadCriteria() throws -> PreferenceCriteria? {
        try rowsNewestFirst().first?.criteria
    }

    func saveCriteria(_ criteria: PreferenceCriteria) throws {
        let rows = try rowsNewestFirst()

        if let existing = rows.first {
            existing.apply(criteria)
            // Defensive: collapse any duplicates a previous bug may have left.
            for duplicate in rows.dropFirst() {
                context.delete(duplicate)
            }
        } else {
            context.insert(UserPreference(criteria: criteria))
        }

        try context.save()
    }

    private func rowsNewestFirst() throws -> [UserPreference] {
        let descriptor = FetchDescriptor<UserPreference>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
}
