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
        } catch {
            destroyStore(at: configuration.url)

            do {
                return try ModelContainer(for: schema, configurations: [configuration])
            } catch {
                fatalError("Could not create ModelContainer after resetting the local store: \(error)")
            }
        }
    }()

    private static func destroyStore(at url: URL) {
        let directory = url.deletingLastPathComponent()
        for suffix in ["", "-shm", "-wal"] {
            let file = directory.appendingPathComponent(url.lastPathComponent + suffix)
            try? FileManager.default.removeItem(at: file)
        }
    }

    var body: some Scene {
        WindowGroup {
            DecideView()
        }
        .modelContainer(Self.container)
    }
}
