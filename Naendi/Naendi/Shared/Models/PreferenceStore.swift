//
//  PreferenceStore.swift
//  Naendi
//
//  Persistence boundary for the user's search preferences. Deals in
//  PreferenceCriteria rather than the SwiftData model, so callers above this
//  line never touch SwiftData.
//

protocol PreferenceStoring {
    /// `nil` when the user has never saved preferences.
    func loadCriteria() throws -> PreferenceCriteria?
    func saveCriteria(_ criteria: PreferenceCriteria) throws
}
