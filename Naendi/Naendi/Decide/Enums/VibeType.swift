//
//  VibeType.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 26/07/26.
//

import Foundation

enum VibeType: String, CaseIterable {
    case any = "Any"
    case calm = "Calm"
    case balanced = "Balanced"
    case lively = "Lively"

    var description: String {
        switch self {
        case .any:
            return String(localized: "Any kind of atmosphere.")
        case .calm:
            return String(localized: "Quiet and peaceful atmosphere.")
        case .balanced:
            return String(localized: "Not too crowded, not too quiet.")
        case .lively:
            return String(localized: "Energetic, bustling, and crowded.")
        }
    }
}
