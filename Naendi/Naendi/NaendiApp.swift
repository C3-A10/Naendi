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
        return try! ModelContainer(for: schema, configurations: [configuration])
    }()

    var body: some Scene {
        WindowGroup {
            ResultView()
        }
        .modelContainer(Self.container)
    }
}
