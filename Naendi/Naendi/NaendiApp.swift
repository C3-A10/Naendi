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
    private static let container: ModelContainer = {
        let schema = Schema([PlaceEntity.self, UserPreference.self, SeedState.self])
        let configuration = ModelConfiguration(schema: schema, cloudKitDatabase: .none)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch let initialError {
            do {
                try PersistentStoreRecovery.removeStore(at: configuration.url)
                return try ModelContainer(for: schema, configurations: [configuration])
            } catch let recoveryError {
                fatalError(
                    "Could not recover ModelContainer at \(configuration.url). "
                        + "Initial error: \(initialError). Recovery error: \(recoveryError)"
                )
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            DecideView()
        }
        .modelContainer(Self.container)
    }
}
