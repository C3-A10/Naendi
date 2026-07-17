//
//  SeedState.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 17/07/26.
//

import SwiftData

@Model
final class SeedState {
    var key: String
    var isSeeded: Bool

    init(key: String = SeedState.placesKey, isSeeded: Bool) {
        self.key = key
        self.isSeeded = isSeeded
    }

    static let placesKey = "places"
}
