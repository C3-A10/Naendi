//
//  FakePreferenceStore.swift
//  NaendiTests
//
//  In-memory stand-in for SwiftDataPreferenceStore.
//

@testable import Naendi

final class FakePreferenceStore: PreferenceStoring {
    var stored: PreferenceCriteria?
    var saveCount = 0
    /// Set to make the next load or save throw, to exercise failure paths.
    var errorToThrow: Error?

    init(stored: PreferenceCriteria? = nil) {
        self.stored = stored
    }

    func loadCriteria() throws -> PreferenceCriteria? {
        if let errorToThrow { throw errorToThrow }
        return stored
    }

    func saveCriteria(_ criteria: PreferenceCriteria) throws {
        if let errorToThrow { throw errorToThrow }
        stored = criteria
        saveCount += 1
    }
}
