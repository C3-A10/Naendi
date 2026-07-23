//
//  DecidePhase.swift
//  Naendi
//
//  Which screen the Decide flow is showing. Tracked explicitly rather than
//  inferred from `places.isEmpty`, so a preference set that legitimately
//  matches nothing shows an empty result instead of bouncing to the landing page.
//

enum DecidePhase: Equatable {
    case landing
    case loading
    case results
}
