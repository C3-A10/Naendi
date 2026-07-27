//
//  HalalType.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 27/07/26.
//

import Foundation

enum HalalType: String, CaseIterable {
    case halal = "Halal"
    case nonHalal = "Nonhalal"
    
    var description: String {
        switch self {
        case .halal:
            return String(localized: "No pork no lard.")
        case .nonHalal:
            return String(localized: "Possible pork or lard.")
        }
    }
}
