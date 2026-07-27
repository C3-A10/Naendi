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
            return String(localized: "Includes places with all atmosphere types.")
        case .calm:
            return String(localized: "Places with a quieter and more relaxed atmosphere.")
        case .balanced:
            return String(localized: "Places with a balanced level of activity.")
        case .lively:
            return String(localized: "Places with a more active and social atmosphere.")
        }
    }
}

