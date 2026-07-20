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
    // SwiftData is a local cache only; CloudKit is read directly via
    // CloudKitPlaceRepository. cloudKitDatabase: .none keeps the CloudKit
    // entitlement from enabling mirroring, which our schema doesn't satisfy.
    private static let container: ModelContainer = {
        let schema = Schema([PlaceEntity.self, UserPreference.self, SeedState.self])
        let configuration = ModelConfiguration(schema: schema, cloudKitDatabase: .none)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // Everything in this store is rebuildable: places re-seed from
            // CloudKit and preferences are quick to re-enter. A schema change
            // that can't migrate should therefore cost a reset, not a launch
            // crash for anyone with an older build installed.
            destroyStore(at: configuration.url)

            do {
                return try ModelContainer(for: schema, configurations: [configuration])
            } catch {
                fatalError("Could not create ModelContainer after resetting the local store: \(error)")
            }
        }
    }()

    /// Removes the SQLite store along with its write-ahead log and shared memory
    /// companions; leaving those behind would fail the retry.
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
