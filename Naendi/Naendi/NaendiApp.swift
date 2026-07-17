//
//  NaendiApp.swift
//  Naendi
//
//  Created by Bryan Samuel on 13/07/26.
//

import SwiftUI
import SwiftData

@main
struct NaendiApp: App {
    var body: some Scene {
        WindowGroup {
            ResultView()
        }
        .modelContainer(for: [PlaceEntity.self, UserPreference.self])
    }
}
