//
//  AppServices.swift
//  Naendi
//
//  Small factory for the SwiftData-backed services. Views construct these
//  inline from their own model context; keeping the wiring in one place stops
//  the same three-line expression appearing in every screen.
//

import SwiftData

enum AppServices {
    static func placeProvider(context: ModelContext) -> PlaceProviding {
        PlaceProvider(
            repository: CloudKitPlaceRepository(),
            store: SwiftDataPlaceStore(context: context)
        )
    }

    static func preferenceStore(context: ModelContext) -> PreferenceStoring {
        SwiftDataPreferenceStore(context: context)
    }
}
